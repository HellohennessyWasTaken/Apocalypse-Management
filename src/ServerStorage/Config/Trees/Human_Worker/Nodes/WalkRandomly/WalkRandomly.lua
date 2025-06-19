local PathfindingService = game:GetService("PathfindingService")
local CollectionService = game:GetService("CollectionService")

local node = {}		

local SUCCESS,FAIL,RUNNING = 1,2,3

-- Any arguments passed into Tree:run(obj) can be received after the first parameter, obj
-- Example: Tree:run(obj,deltaTime) - > node.start(obj, deltaTime), node.run(obj, deltaTime), node.finish(obj, status, deltaTime)

-- Blackboards
-- objects attached to the tree have tables injected into them called Blackboards.
-- these can be read from and written to by the tree using the Blackboard node, and can be accessed in nodes via object.Blackboard
--

function node.start(obj)
	--print(script.Name)
end

function node.finish(obj, status) end

function node.run(self)
	if self.Threat then return FAIL end
	
	if os.clock() - self.WalkRandomlyStartTime < self.WalkRandomlyCooldown then
		return FAIL
	end
	self.WalkRandomlyCooldown = math.random(self.WalkRandomlyCooldownMin, self.WalkRandomlyCooldownMax)
	
	self.Humanoid.WalkSpeed = self.BaseSpeed * 0.75

	self.RaycastParams.FilterDescendantsInstances = {self.Character, CollectionService:GetTagged("Entity")}
	self.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local start = self.HumanoidRootPart.Position
	local xRand = math.random(-10,10)
	local zRand = math.random(-10,10)
	local destination = Vector3.new(
		math.clamp(self.HumanoidRootPart.Position.X + xRand, -30, 30),
		0,
		math.clamp(self.HumanoidRootPart.Position.Z + zRand, -30, 30)
	)

	local result = workspace:Raycast(start, (destination - start), self.RaycastParams)

	if result and result.Instance then
		local path = self.CreatedPath
		local success, errorMessage = pcall(function()
			path:ComputeAsync(self.HumanoidRootPart.Position, destination)
		end)

		if success and path.Status == Enum.PathStatus.Success then
			local waypoints = path:GetWaypoints()

			for _, waypoint in waypoints do
				if waypoint.Action == Enum.PathWaypointAction.Jump then
					self.Humanoid.Jump = true
				end
				self.Humanoid:MoveTo(waypoint.Position)
				local timeOut = not self.Humanoid.MoveToFinished:Wait(1)
				if timeOut then
					--print("Got stuck")
					self.Humanoid.Jump = true
					return FAIL
				end
				if self.Threat then return FAIL end
			end

			self.WalkRandomlyStartTime = os.clock()
			return SUCCESS
		else
			--print("Path failed")
			self.Humanoid.Jump = true
			task.wait(1)
			return FAIL
		end
	else
		if self.Threat then
			self.Humanoid:MoveTo(self.HumanoidRootPart.Position)
			return FAIL
		end
		
		self.Humanoid:MoveTo(destination)
		
		self.WalkRandomlyStartTime = os.clock()
		return SUCCESS
	end
end

return node