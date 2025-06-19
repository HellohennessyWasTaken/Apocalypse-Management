local CollectionService = game:GetService("CollectionService")

local function GetPotentialTargets()
	local targets = {}
	for _, target in CollectionService:GetTagged("Human") do
		if not target:FindFirstAncestorWhichIsA("Workspace") then continue end
		table.insert(targets, target)
	end
	return targets
end

local function raycast(caster: Model, start: Vector3, finish: Vector3)
	local parameters = RaycastParams.new()

	parameters.FilterDescendantsInstances = {caster, GetPotentialTargets()}
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

function task.start(obj) end

function task.finish(obj, status)
	--print(script.Name, " ", status)
end	

function task.run(self)
	--local potentialTargets = {}

	--for _, potentialTarget in GetPotentialTargets() do
	--	table.insert(potentialTargets, potentialTarget)
	--end

	--for index, potentialTarget: Model in potentialTargets do
	--	local humanoid = potentialTarget:FindFirstChild("Humanoid") :: Humanoid
	--	if not humanoid or humanoid.Health <= 0 then continue end
		
	--	local potentialTargetRoot = potentialTarget.PrimaryPart
	--	if not potentialTargetRoot then continue end
		
	--	local PotentialTargetPosition = potentialTargetRoot.Position

	--	local myPosition = self.HumanoidRootPart.Position
	--	local myCFrame = self.HumanoidRootPart.CFrame

	--	local direction = (PotentialTargetPosition - myPosition).Unit
	--	local lookVector = myCFrame.LookVector

	--	local dotProduct = direction:Dot(lookVector)
	--	local angle = math.deg(math.acos(dotProduct))

	--	local distance = (myPosition - PotentialTargetPosition).Magnitude

	--	if self.Alert then
	--		if angle > self.AlertFieldOfView then continue end
	--		if distance > self.AlertViewRange then continue end
	--	else
	--		if angle > self.FieldOfView then continue end
	--		if distance > self.ViewRange then continue end
	--	end
		
	--	self.Target = potentialTarget
	--	self.IsAlert = true
	--	self.LastTimeSawTarget = os.clock()
		
	--	return SUCCESS
	--end
	
	--if self.Target then
	--	if os.clock() - self.LastTimeSawTarget < self.MemoryTime then
	--		return SUCCESS
	--	end
	--end
	
	--self.IsAlert = true
	--self.Target = nil
	--return FAIL
	
	if self.Target then
		return SUCCESS
	else
		return FAIL
	end
end

return task
