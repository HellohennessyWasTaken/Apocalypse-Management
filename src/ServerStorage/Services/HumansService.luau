--!strict

--< INFO >--

--< TYPES >--

--< SERVICES >--
local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

--< FOLDERS >--

--< DEPENDENCIES >--
local HumanComponent = require(ServerStorage.Components.HumanComponent)

--< MAIN >--
@native
local function checkMagnitudeBelowThreshold(a: Vector3, b: Vector3, threshold: number): boolean
	return (a - b).Magnitude < threshold
end

local function GetPotentialThreats() : {Model}
	local threats = {}
	for _, threat: Model in CollectionService:GetTagged("Zombie") do
		if not threat:IsDescendantOf(Workspace) then continue end
		table.insert(threats, threat)
	end
	return threats
end

local function getHumans() : {Model}
	local targets = {}
	for _, target: Model in CollectionService:GetTagged("Human") do
		if not target:IsDescendantOf(Workspace) then continue end
		table.insert(targets, target)
	end
	return targets
end

local parameters = RaycastParams.new()
parameters.FilterType = Enum.RaycastFilterType.Exclude
local function raycast(caster: Model, start: Vector3, finish: Vector3) : boolean
	parameters.FilterDescendantsInstances = {caster, GetPotentialThreats(), getHumans()}

	local raycast = Workspace:Raycast(start, (finish - start), parameters)

	if raycast then
		return true
	else
		return false
	end
end

local function GetPotentialThreatsNearby(actor: any) : {Model}
	local threats = {}
	for _, threat: Model in GetPotentialThreats() do
		local root = threat:FindFirstChild("HumanoidRootPart") :: BasePart
		if not root then continue end

		local humanoid = threat:FindFirstChild("Humanoid") :: Humanoid
		if not humanoid or (humanoid.Health <= 0) then continue end

		if not checkMagnitudeBelowThreshold(actor.HumanoidRootPart.Position, root.Position, actor.ViewRange/2) then continue end

		table.insert(threats, threat)
	end
	return threats
end

local function GetAlliesNearby(actor: any) : {Model}
	local allies: {Model} = {}
	for _, ally: Model in CollectionService:GetTagged("Human") do
		if not ally:IsDescendantOf(Workspace) then continue end

		local root = ally:FindFirstChild("HumanoidRootPart") :: BasePart
		if not root then continue end

		local humanoid = ally:FindFirstChild("Humanoid") :: Humanoid
		if (not humanoid) or (humanoid.Health <= 0) then continue end

		if not checkMagnitudeBelowThreshold(actor.HumanoidRootPart.Position, root.Position, actor.ViewRange/2) then continue end
		table.insert(allies, ally)
	end
	return allies
end

local function GetItemsNearby(actor: any) : {Model}
	local items: {Model} = {}
	for _, item: Model in CollectionService:GetTagged("Item") do
		if not item:IsDescendantOf(Workspace) then continue end
		if not item.PrimaryPart then continue end
		if not checkMagnitudeBelowThreshold(actor.HumanoidRootPart.Position, item.PrimaryPart.Position, actor.ViewRange/2) then continue end
		table.insert(items, item)
	end
	return items
end

local function GetResourcesNearby(actor: any) : {Model}
	local resources: {Model} = {}
	for _, resource: Model in CollectionService:GetTagged("Resource") do
		if not resource:FindFirstAncestorWhichIsA("Workspace") then continue end
		if not resource.PrimaryPart then continue end
		if not checkMagnitudeBelowThreshold(actor.HumanoidRootPart.Position, resource.PrimaryPart.Position, actor.ViewRange/2) then continue end
		table.insert(resources, resource)
	end
	return resources
end

local HumansService = {
	Name = script.Name,
	Client = {},
	HumanComponents = {}
}

function HumansService:KnitInit()
	--for i, component in HumanComponent:GetAll() do
	--	table.insert(self.HumanComponents, component)
	--end

	--HumanComponent.Started:Connect(function(component)
	--	table.insert(self.HumanComponents, component)
	--end)
	
	--HumanComponent.Stopped:Connect(function(component)
	--	local index = table.find(self.HumanComponents, component)
	--	table.remove(self.HumanComponents, component)
	--end)
end

function HumansService:KnitStart()
	task.spawn(function()
		while task.wait(0.5) do
			for _, human in HumanComponent:GetAll() do
				if not human.Character then continue end
				if not human.Character:FindFirstAncestorWhichIsA("Workspace") then continue end
				if not human.Humanoid or human.Humanoid.Health <= 0 then continue end
				
				local potentialThreats = GetPotentialThreats()
				local prevDist = math.huge

				for _, potentialThreat: Model in potentialThreats do
					local potentialThreatHumanoid = potentialThreat:FindFirstChild("Humanoid") :: Humanoid
					if not potentialThreatHumanoid or (potentialThreatHumanoid.Health <= 0) then
						continue
					end

					local potentialThreatRoot = potentialThreat.PrimaryPart
					if not potentialThreatRoot then continue end

					local potentialThreatPosition = potentialThreatRoot.Position

					local myPosition = human.HumanoidRootPart.Position
					local myCFrame = human.HumanoidRootPart.CFrame

					local direction = (potentialThreatPosition - myPosition).Unit
					local lookVector = myCFrame.LookVector

					local dotProduct = direction:Dot(lookVector)
					local angle = math.deg(math.acos(dotProduct))

					local distance = (myPosition - potentialThreatPosition).Magnitude

					if human.Alert then
						if angle > human.AlertFieldOfView then continue end
						if distance > human.AlertViewRange then continue end
					else
						if angle > human.FieldOfView then continue end
						if distance > human.ViewRange then continue end
					end

					if raycast(human.Character, myPosition, potentialThreatPosition) then
						continue
					end
					
					if distance < prevDist then
						prevDist = distance
						human.Threat = potentialThreat
						human.IsAlert = true
						human.LastTimeSawTarget = os.clock()
					end
				end

				if human.Threat and (human.Threat.Humanoid.Health > 0) and (os.clock() - human.LastTimeSawThreat < human.MemoryTime) then
					continue
				end

				human.IsAlert = false
				human.Threat = nil
			end
		end
	end)
	
	task.spawn(function()
		while task.wait(0.5) do
			for _, human in HumanComponent:GetAll() do
				if not human.Character then continue end
				if not human.Character:IsDescendantOf(Workspace) then continue end
				if not human.Humanoid or (human.Humanoid.Health <= 0) then continue end

				human.NearbyThreats = GetPotentialThreatsNearby(human)
				human.NearbyAllies = GetAlliesNearby(human)
				human.NearbyItems = GetItemsNearby(human)
				human.NearbyResources = GetResourcesNearby(human)
			end
		end
	end)
end

return HumansService