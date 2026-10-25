--!strict

const PathfindingService = game:GetService("PathfindingService")
const Workspace = game:GetService("Workspace")

const ArriveDistance = 1.5
const RetargetDistance = 0.5
const RepathDistance = 2
const RepathInterval = 1
const SightCheckInterval = 0.5
-- Humanoid:MoveTo gives up after 8 s
const MoveToRefreshInterval = 6
const StuckDistance = 0.5
const StuckTime = 2
const RetryDelay = 1
const ForcePathTime = 3
const MaxConcurrentPaths = 4
const FaceHoldTime = 0.3
const FaceTorque = Vector3.new(0, math.huge, 0)
const FaceP = 10000
const FaceD = 500

const Mover = {}
Mover.__index = Mover

export type Status = "Idle" | "Moving" | "Waiting" | "Arrived" | "Failed"

export type Mover = typeof(setmetatable({} :: {
	Humanoid: Humanoid,
	Root: BasePart,
	AgentParameters: {[string]: any},
	Status: Status,
	Mode: ("Direct" | "Path")?,
	Goal: Vector3?,
	PathGoal: Vector3?,
	Waypoints: {PathWaypoint},
	WaypointIndex: number,
	LastIssued: Vector3?,
	LastIssueTime: number,
	LastSightCheck: number,
	LastPathRequest: number,
	ProgressPosition: Vector3,
	ProgressTime: number,
	RetryAt: number,
	ForcePathUntil: number,
	PathRequestId: number,
	PathPending: boolean,
	Gyro: BodyGyro?,
	FaceUntil: number,
	Destroyed: boolean,
}, Mover))

type PathRequest = {
	Mover: Mover,
	Id: number,
}

const navParams = RaycastParams.new()
navParams.CollisionGroup = "NavQuery"

const pathQueue: {[number]: PathRequest} = {}
local queueHead, queueTail = 1, 0
local activePaths = 0
const gyroPool: {BodyGyro} = {}

local function horizontalDistance(a: Vector3, b: Vector3): number
	return Vector2.new(a.X - b.X, a.Z - b.Z).Magnitude
end

local function newGyro(): BodyGyro
	const gyro = Instance.new("BodyGyro")
	gyro.MaxTorque = FaceTorque
	gyro.P = FaceP
	gyro.D = FaceD
	return gyro
end

local pumpPaths: () -> ()

local function computePath(request: PathRequest)
	const mover = request.Mover
	const path = PathfindingService:CreatePath(mover.AgentParameters)
	const success = pcall(path.ComputeAsync, path, mover.Root.Position, mover.PathGoal :: Vector3)
	activePaths -= 1

	if not mover.Destroyed and mover.PathRequestId == request.Id then
		mover.PathPending = false
		if success and path.Status == Enum.PathStatus.Success then
			mover:_followPath(path:GetWaypoints())
		else
			mover:_fail(os.clock())
		end
	end
	path:Destroy()
	pumpPaths()
end

function pumpPaths()
	while activePaths < MaxConcurrentPaths and queueHead <= queueTail do
		const request = pathQueue[queueHead]
		pathQueue[queueHead] = nil
		queueHead += 1
		if request.Mover.Destroyed or request.Mover.PathRequestId ~= request.Id then continue end
		activePaths += 1
		task.spawn(computePath, request)
	end
end

function Mover.HasLineOfSight(from: Vector3, to: Vector3, target: Instance?): boolean
	const result = Workspace:Raycast(from, to - from, navParams)
	return result == nil or (target ~= nil and result.Instance:IsDescendantOf(target))
end

function Mover.new(humanoid: Humanoid, root: BasePart, agentParameters: {[string]: any}): Mover
	const self = setmetatable({
		Humanoid = humanoid,
		Root = root,
		AgentParameters = agentParameters,
		Status = "Idle" :: Status,
		Mode = nil :: ("Direct" | "Path")?,
		Goal = nil :: Vector3?,
		PathGoal = nil :: Vector3?,
		Waypoints = {} :: {PathWaypoint},
		WaypointIndex = 1,
		LastIssued = nil :: Vector3?,
		LastIssueTime = 0,
		LastSightCheck = 0,
		LastPathRequest = 0,
		ProgressPosition = root.Position,
		ProgressTime = 0,
		RetryAt = 0,
		ForcePathUntil = 0,
		PathRequestId = 0,
		PathPending = false,
		Gyro = nil :: BodyGyro?,
		FaceUntil = 0,
		Destroyed = false,
	}, Mover)
	return self
end

function Mover.GetPosition(self: Mover): Vector3
	return self.Root.Position
end

function Mover.GetCFrame(self: Mover): CFrame
	return self.Root.CFrame
end

function Mover.IsFailed(self: Mover): boolean
	return self.Status == "Failed" or os.clock() < self.RetryAt
end

function Mover.SetSpeed(self: Mover, speed: number)
	if self.Humanoid.WalkSpeed ~= speed then
		self.Humanoid.WalkSpeed = speed
	end
end

function Mover.Knockback(self: Mover, impulse: Vector3)
	-- NaN when attacker and target overlap (zero vector .Unit)
	if impulse.Magnitude ~= impulse.Magnitude then return end
	self.Root:ApplyImpulse(impulse)
end

function Mover.Face(self: Mover, position: Vector3)
	if not self.Gyro then
		self.Gyro = table.remove(gyroPool) or newGyro()
	end

	const gyro = self.Gyro :: BodyGyro
	const rootPosition = self.Root.Position
	gyro.CFrame = CFrame.lookAt(rootPosition, Vector3.new(position.X, rootPosition.Y, position.Z))
	gyro.Parent = self.Root
	self.FaceUntil = os.clock() + FaceHoldTime
end

function Mover.StopFacing(self: Mover)
	const gyro = self.Gyro
	if not gyro then return end
	self.Gyro = nil
	-- Not parented to the root means it was destroyed along with the model
	if gyro.Parent == self.Root then
		gyro.Parent = nil
		table.insert(gyroPool, gyro)
	end
end

function Mover.MoveTo(self: Mover, destination: Vector3, target: Instance?)
	const now = os.clock()
	if now < self.RetryAt then return end

	self.Goal = destination
	const active = self.Status == "Moving" or self.Status == "Waiting"
	if active and now - self.LastSightCheck < SightCheckInterval then
		if self.Mode == "Direct" then
			self:_retarget(now)
		end
		return
	end

	self.LastSightCheck = now
	if now >= self.ForcePathUntil and Mover.HasLineOfSight(self.Root.Position, destination, target) then
		if not (active and self.Mode == "Direct") then
			self:_resetProgress(now)
		end
		self:_cancelPath()
		self.Mode = "Direct"
		self.Status = "Moving"
		self:_retarget(now)
		return
	end

	if active and self.Mode == "Path" then
		const pathGoal = self.PathGoal :: Vector3
		if (pathGoal - destination).Magnitude < RepathDistance or now - self.LastPathRequest < RepathInterval then
			return
		end
	end
	self:_requestPath(destination, now)
end

function Mover.Stop(self: Mover)
	if self.Status == "Idle" then return end
	self:_cancelPath()
	self.Status = "Idle"
	self.Mode = nil
	self.Goal = nil
	self:_issue(self.Root.Position, os.clock())
end

function Mover.Step(self: Mover, now: number)
	if self.Gyro and now >= self.FaceUntil then
		self:StopFacing()
	end
	if self.Status ~= "Moving" then return end

	const position = self.Root.Position
	if (position - self.ProgressPosition).Magnitude > StuckDistance then
		self.ProgressPosition = position
		self.ProgressTime = now
	elseif now - self.ProgressTime > StuckTime then
		self:_fail(now)
		return
	end

	const target = if self.Mode == "Direct" then self.Goal :: Vector3 else self.Waypoints[self.WaypointIndex].Position
	if horizontalDistance(position, target) <= ArriveDistance then
		if self.Mode == "Direct" then
			self:_arrive()
		else
			self:_advanceWaypoint(now)
		end
	elseif now - self.LastIssueTime > MoveToRefreshInterval then
		self:_issue(target, now)
	end
end

function Mover.Destroy(self: Mover)
	self.Destroyed = true
	self:_cancelPath()
	self:StopFacing()
end

function Mover._cancelPath(self: Mover)
	self.PathRequestId += 1
	self.PathPending = false
end

function Mover._issue(self: Mover, position: Vector3, now: number)
	self.Humanoid:MoveTo(position)
	self.LastIssued = position
	self.LastIssueTime = now
end

function Mover._retarget(self: Mover, now: number)
	const goal = self.Goal :: Vector3
	const lastIssued = self.LastIssued
	if not lastIssued or (goal - lastIssued).Magnitude > RetargetDistance then
		self:_issue(goal, now)
	end
end

function Mover._resetProgress(self: Mover, now: number)
	self.ProgressPosition = self.Root.Position
	self.ProgressTime = now
end

function Mover._requestPath(self: Mover, destination: Vector3, now: number)
	self.PathGoal = destination
	self.LastPathRequest = now
	-- A queued request reads PathGoal when it starts, so it already picks up the new goal
	if self.PathPending then return end

	self.PathRequestId += 1
	self.PathPending = true
	if not (self.Mode == "Path" and self.Status == "Moving") then
		self.Mode = "Path"
		self.Status = "Waiting"
	end
	queueTail += 1
	pathQueue[queueTail] = {Mover = self, Id = self.PathRequestId}
	pumpPaths()
end

function Mover._followPath(self: Mover, waypoints: {PathWaypoint})
	const now = os.clock()
	self.Waypoints = waypoints
	self.WaypointIndex = 1
	self.Status = "Moving"
	self:_resetProgress(now)
	self:_advanceWaypoint(now)
end

function Mover._advanceWaypoint(self: Mover, now: number)
	self.WaypointIndex += 1
	const waypoint = self.Waypoints[self.WaypointIndex]
	if not waypoint then
		self:_arrive()
		return
	end

	if waypoint.Action == Enum.PathWaypointAction.Jump then
		self.Humanoid.Jump = true
	end
	self:_issue(waypoint.Position, now)
end

function Mover._arrive(self: Mover)
	self.Status = "Arrived"
	self.Mode = nil
end

function Mover._fail(self: Mover, now: number)
	if self.Mode == "Direct" then
		self.ForcePathUntil = now + ForcePathTime
	end
	self:_cancelPath()
	self.Status = "Failed"
	self.Mode = nil
	self.RetryAt = now + RetryDelay
	self.Humanoid.Jump = true
end

return Mover
