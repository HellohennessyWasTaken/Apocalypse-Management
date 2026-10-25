--!strict

const CollectionService = game:GetService("CollectionService")
const RunService = game:GetService("RunService")
const ServerStorage = game:GetService("ServerStorage")
const Workspace = game:GetService("Workspace")

const Mover = require(ServerStorage.Modules.Mover)
const SpatialGrid = require(ServerStorage.Modules.SpatialGrid)

const GridCellSize = 25
const GridRebuildInterval = 0.25
const PerceptionInterval = 0.5
const MoveStepInterval = 0.1
const FrameBudget = 0.004

export type Kind = "Human" | "Zombie"

type Schedule = {
	Kind: Kind,
	Tree: any,
	ThinkInterval: number,
	NextThink: number,
	NextPerception: number,
	NextMoveStep: number,
}

const NPCService = {
	Name = script.Name,
	Client = {},
}

const npcs: {any} = {}
const removals: {any} = {}
const humanGrid = SpatialGrid.new(GridCellSize)
const zombieGrid = SpatialGrid.new(GridCellSize)
const itemGrid = SpatialGrid.new(GridCellSize)
const resourceGrid = SpatialGrid.new(GridCellSize)

local nextGridRebuild = 0
local cursor = 1
local stepTime = 0
local stepFrames = 0

local function isAlive(npc: any): boolean
	return not npc.Mover.Destroyed and not npc.Health:IsDead()
end

local function insertTagged(grid: SpatialGrid.SpatialGrid, tag: string)
	grid:Clear()
	for _, instance in CollectionService:GetTagged(tag) do
		if not instance:IsA("Model") or not instance:IsDescendantOf(Workspace) then continue end
		const primaryPart = (instance :: Model).PrimaryPart
		if primaryPart then
			grid:Insert(instance, primaryPart.Position)
		end
	end
end

local function rebuildGrids()
	humanGrid:Clear()
	zombieGrid:Clear()
	for _, npc in npcs do
		if not isAlive(npc) then continue end
		const grid = if npc.Schedule.Kind == "Human" then humanGrid else zombieGrid
		grid:Insert(npc, npc.Mover:GetPosition())
	end
	insertTagged(itemGrid, "Item")
	insertTagged(resourceGrid, "Resource")
end

local function aliveOnly(candidates: {any}): {any}
	const alive = {}
	for _, npc in candidates do
		if isAlive(npc) then
			table.insert(alive, npc)
		end
	end
	return alive
end

local function findClosestVisible(npc: any, candidates: {any}): any?
	const position = npc.Mover:GetPosition()
	const lookVector = npc.Mover:GetCFrame().LookVector
	local closest = nil
	local closestDistance = math.huge

	for _, other in candidates do
		if not isAlive(other) then continue end

		const otherPosition = other.Mover:GetPosition()
		const offset = otherPosition - position
		const distance = offset.Magnitude
		if distance == 0 or distance >= closestDistance then continue end

		-- clamped because float error can push the dot past 1, and acos would return NaN
		const angle = math.deg(math.acos(math.clamp(offset.Unit:Dot(lookVector), -1, 1)))
		const inView = angle <= npc.FieldOfView / 2 and distance <= npc.ViewRange
		const inAlertView = npc.IsAlert and angle <= npc.AlertFieldOfView / 2 and distance <= npc.AlertRange
		if not (inView or inAlertView) then continue end
		if not Mover.HasLineOfSight(position, otherPosition, other.Character) then continue end

		closest = other
		closestDistance = distance
	end
	return closest
end

local function perceiveHuman(human: any, now: number)
	const position = human.Mover:GetPosition()

	const seen = findClosestVisible(human, zombieGrid:Query(position, human.ViewRange))
	if seen then
		human.Threat = seen
		human.IsAlert = true
		human.LastTimeSawThreat = now
	elseif not (human.Threat and isAlive(human.Threat) and now - human.LastTimeSawThreat < human.MemoryTime) then
		human.Threat = nil
		human.IsAlert = false
	end

	const nearbyRange = human.ViewRange / 2
	human.NearbyThreats = aliveOnly(zombieGrid:Query(position, nearbyRange))
	human.NearbyAllies = aliveOnly(humanGrid:Query(position, nearbyRange))
	human.NearbyItems = itemGrid:Query(position, nearbyRange)
	human.NearbyResources = resourceGrid:Query(position, nearbyRange)
end

local function perceiveZombie(zombie: any, now: number)
	const seen = findClosestVisible(zombie, humanGrid:Query(zombie.Mover:GetPosition(), zombie.ViewRange))
	if seen then
		zombie.Target = seen
		zombie.IsAlert = true
		zombie.LastTimeSawTarget = now
	elseif not (zombie.Target and isAlive(zombie.Target) and now - zombie.LastTimeSawTarget < zombie.MemoryTime) then
		zombie.Target = nil
		zombie.IsAlert = false
	end
end

local function tickNPC(npc: any, now: number)
	const schedule: Schedule = npc.Schedule

	if now >= schedule.NextMoveStep then
		schedule.NextMoveStep = now + MoveStepInterval
		npc.Mover:Step(now)
	end

	if now >= schedule.NextPerception then
		schedule.NextPerception = now + PerceptionInterval
		if schedule.Kind == "Human" then
			perceiveHuman(npc, now)
		else
			perceiveZombie(npc, now)
		end
	end

	if now >= schedule.NextThink then
		schedule.NextThink = now + schedule.ThinkInterval
		schedule.Tree:Run(npc)
	end
end

local function flushRemovals()
	for _, npc in removals do
		const index = table.find(npcs, npc)
		if index then
			npcs[index] = npcs[#npcs]
			npcs[#npcs] = nil
		end
	end
	table.clear(removals)
end

local function step()
	const startTime = os.clock()
	flushRemovals()

	if startTime >= nextGridRebuild then
		nextGridRebuild = startTime + GridRebuildInterval
		debug.profilebegin("NPCService grids")
		rebuildGrids()
		debug.profileend()
	end

	debug.profilebegin("NPCService tick")
	const count = #npcs
	const deadline = os.clock() + FrameBudget
	for _ = 1, count do
		if cursor > count then
			cursor = 1
		end
		const npc = npcs[cursor]
		cursor += 1

		const success, message = xpcall(tickNPC, debug.traceback, npc, startTime)
		if not success then
			warn(`NPC {npc.Character.Name} removed from the scheduler after an error:\n{message}`)
			NPCService:Unregister(npc)
		end

		if os.clock() > deadline then break end
	end
	debug.profileend()

	stepTime += os.clock() - startTime
	stepFrames += 1
end

function NPCService:Register(npc: any, kind: Kind, tree: any, thinkInterval: number, thinkDelay: number)
	const now = os.clock()
	npc.Schedule = {
		Kind = kind,
		Tree = tree,
		ThinkInterval = thinkInterval,
		NextThink = now + thinkDelay + math.random() * thinkInterval,
		NextPerception = now + math.random() * PerceptionInterval,
		NextMoveStep = now + math.random() * MoveStepInterval,
	} :: Schedule
	table.insert(npcs, npc)

	npc.Health.Died:Once(function()
		NPCService:Unregister(npc)
	end)
end

function NPCService:Unregister(npc: any)
	table.insert(removals, npc)
end

function NPCService:GetCount(): number
	return #npcs
end

function NPCService:ConsumeAverageStepTime(): number
	const average = if stepFrames > 0 then stepTime / stepFrames else 0
	stepTime = 0
	stepFrames = 0
	return average
end

function NPCService:KnitInit() end

function NPCService:KnitStart()
	RunService.Heartbeat:Connect(step)
end

return NPCService
