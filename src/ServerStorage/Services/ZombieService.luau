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
	local targets: {Model} = {}
	for _, target: Model in CollectionService:GetTagged("Human") do
		if not target:IsDescendantOf(Workspace) then continue end
		table.insert(targets, target)
	end
	return targets
end

local function getZombies() : {Model}
	local threats: {Model} = {}
	for _, threat: Model in CollectionService:GetTagged("Zombie") do
		if not threat:IsDescendantOf(Workspace) then continue end
		table.insert(threats, threat)
	end
	return threats
end

local parameters = RaycastParams.new()
parameters.FilterType = Enum.RaycastFilterType.Exclude
local function raycast(caster: Model, start: Vector3, finish: Vector3)
	parameters.FilterDescendantsInstances = {caster, GetPotentialTargets(), getZombies()}

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

				-- clamped because float error can push the dot past 1, and acos would return NaN
				const angle = math.deg(math.acos(math.clamp(direction:Dot(lookVector), -1, 1)))

				local distance = (myPosition - potentialTargetPosition).Magnitude

				const inView = angle <= zombie.FieldOfView / 2 and distance <= zombie.ViewRange
				const inAlertView = zombie.IsAlert and angle <= zombie.AlertFieldOfView / 2 and distance <= zombie.AlertRange
				if not (inView or inAlertView) then continue end

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

			zombie.IsAlert = false
			zombie.Target = nil
			continue
		end
	end
end

return ZombieService