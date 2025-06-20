--!strict

--< INFO >--

--< TYPES >--

--< SERVICES >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

--< FOLDERS >--
local Assets = ReplicatedStorage.Assets

--< DEPENDENCIES >--
local ZombieComponent = require(ServerStorage.Components.ZombieComponent)

--< MAIN >--
local ZombieAssetFolder = Assets.Zombies
local ZombieAsset = ZombieAssetFolder.Zombie

local function GetPotentialTargets() : {Model}
	local targets = {}
	for _, target in CollectionService:GetTagged("Human") do
		if not target:IsDescendantOf(Workspace) then continue end
		table.insert(targets, target)
	end
	return targets
end

local function getZombies() : {Model}
	local threats = {}
	for _, threat in CollectionService:GetTagged("Zombie") do
		if not threat:IsDescendantOf(Workspace) then continue end
		table.insert(threats, threat)
	end
	return threats
end

local parameters = RaycastParams.new()
parameters.FilterType = Enum.RaycastFilterType.Exclude
local function raycast(caster: Model, start: Vector3, finish: Vector3)
	-- local descendantsInstancesToFilter = {caster} :: {Instance}
	-- local temp = GetPotentialTargets()
	-- table.move(temp, 1, #temp, #descendantsInstancesToFilter+1)
	-- temp = getZombies()
	-- table.move(temp, 1, #temp, #descendantsInstancesToFilter+1)
	-- parameters.FilterDescendantsInstances = descendantsInstancesToFilter
	parameters.FilterDescendantsInstances = {caster, GetPotentialTargets(), getZombies()()}

	local raycast = Workspace:Raycast(start, (finish - start), parameters)

	if raycast then
		return true
	else
		return false
	end
end

local ZombieService = {
	Name = script.Name,
	Client = {},
	HumanComponents = {}
}

function ZombieService:SpawnZombie(cFrame: CFrame)
	local clone = ZombieAsset:Clone()
	clone:PivotTo(cFrame)
	clone.Parent = Workspace
end

function ZombieService:KnitInit() end

function ZombieService:KnitStart()
	while task.wait(0.5) do
		for _, zombie in ZombieComponent:GetAll() do
			if not zombie.Character then continue end
			if not zombie.Character:FindFirstAncestorWhichIsA("Workspace") then continue end
			if not zombie.Humanoid or zombie.Humanoid.Health <= 0 then continue end
			
			local potentialTargets = GetPotentialTargets()
			local prevDist = math.huge

			for _, potentialTarget: Model in potentialTargets do
				local humanoid = potentialTarget:FindFirstChild("Humanoid") :: Humanoid
				if not humanoid or humanoid.Health <= 0 then continue end

				local potentialTargetRoot = potentialTarget.PrimaryPart
				if not potentialTargetRoot then continue end

				local potentialTargetPosition = potentialTargetRoot.Position

				local myPosition = zombie.HumanoidRootPart.Position
				local myCFrame = zombie.HumanoidRootPart.CFrame

				local direction = (potentialTargetPosition - myPosition).Unit
				local lookVector = myCFrame.LookVector

				local dotProduct = direction:Dot(lookVector)
				local angle = math.deg(math.acos(dotProduct))

				local distance = (myPosition - potentialTargetPosition).Magnitude

				if zombie.Alert then
					if angle > zombie.AlertFieldOfView then continue end
					if distance > zombie.AlertViewRange then continue end
				else
					if angle > zombie.FieldOfView then continue end
					if distance > zombie.ViewRange then continue end
				end

				if raycast(zombie.Character, myPosition, potentialTargetPosition) then
					continue
				end
				
				if prevDist > distance then
					prevDist = distance
					zombie.Target = potentialTarget
					zombie.IsAlert = true
					zombie.LastTimeSawTarget = os.clock()
				end
			end

			if zombie.Target then
				if os.clock() - zombie.LastTimeSawTarget < zombie.MemoryTime then
					continue
				end
			end

			zombie.IsAlert = true
			zombie.Target = nil
			continue
		end
	end
end

return ZombieService