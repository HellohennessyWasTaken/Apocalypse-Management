local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChatService = game:GetService("Chat")

local Config = ReplicatedStorage.Config

local EmotionsList = require(Config.Emotions)

local function GetPotentialThreats()
	local threats = {}
	for _, threat in CollectionService:GetTagged("Zombie") do
		if not threat:FindFirstAncestorWhichIsA("Workspace") then continue end
		table.insert(threats, threat)
	end
	return threats
end

local function raycast(caster: Model, start: Vector3, finish: Vector3)
	local parameters = RaycastParams.new()

	parameters.FilterDescendantsInstances = {caster, GetPotentialThreats()}
	parameters.FilterType = Enum.RaycastFilterType.Exclude

	local raycast = workspace:Raycast(start, (finish - start), parameters)

	if raycast then
		return true
	else
		return false
	end
end

--< MAIN >--
local task = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

function task.start(obj)
	--print(script.Name, " start")
end

function task.finish(self, status)	
	--print(script.Name, " ", status)
	if status == SUCCESS then
		if table.find(self.Emotion, EmotionsList.List.Scared) then
			return
		end
		table.insert(self.Emotion, EmotionsList.List.Scared)
	elseif status == FAIL then
		if self.IsAlert then
			return
		end
		
		local index = table.find(self.Emotion, EmotionsList.List.Scared)
		table.remove(self.Emotion, index)
	end
end	

function task.run(self)
	--local potentialThreats = GetPotentialThreats()
	
	--local lastDistance = math.huge
	
	--for index, potentialThreat: Model in potentialThreats do
	--	local potentialThreatRoot = potentialThreat.PrimaryPart
	--	if not potentialThreatRoot then continue end

	--	local potentialThreatPosition = potentialThreatRoot.Position

	--	local myPosition = self.HumanoidRootPart.Position
	--	local myCFrame = self.HumanoidRootPart.CFrame

	--	local direction = (potentialThreatPosition - myPosition).Unit
	--	local lookVector = myCFrame.LookVector

	--	local dotProduct = direction:Dot(lookVector)
	--	local angle = math.deg(math.acos(dotProduct))

	--	local distance = (myPosition - potentialThreatPosition).Magnitude
		
	--	if self.Alert then
	--		if angle > self.AlertFieldOfView then continue end
	--		if distance > self.AlertViewRange then continue end
	--	else
	--		if angle > self.FieldOfView then continue end
	--		if distance > self.ViewRange then continue end
	--	end
		
	--	if raycast(self.Character, myPosition, potentialThreatPosition) then
	--		continue
	--	end

	--	self.Threat = potentialThreat
	--	self.IsAlert = true
	--	self.LastTimeSawThreat = os.clock()

	--	return SUCCESS
	--end

	--if self.Threat then
	--	if os.clock() - self.LastTimeSawThreat < self.MemoryTime then
	--		return SUCCESS			
	--	end
	--end
	
	--self.IsAlert = false
	--self.Threat = nil
	--return FAIL
	if self.Threat then
		return SUCCESS
	else
		return FAIL
	end
end

return task