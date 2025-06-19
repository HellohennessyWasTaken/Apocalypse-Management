local CollectionService = game:GetService("CollectionService")

local function GetPotentialThreats(self)
	local threats = {}
	for _, threat in CollectionService:GetTagged("Zombie") do
		if not threat:FindFirstAncestorWhichIsA("Workspace") then continue end
		local root = threat:FindFirstChild("HumanoidRootPart")
		if not root then continue end
		local humanoid = threat:FindFirstChild("Humanoid") :: Humanoid
		if not humanoid or humanoid.Health <= 0 then continue end
		local distance = (self.HumanoidRootPart.Position - root.Position).Magnitude
		if distance > 10 then continue end
		table.insert(threats, threat)
	end
	return threats
end

local function GetAllies(self)
	local allies = {}
	for _, ally in CollectionService:GetTagged("Human") do
		if not ally:FindFirstAncestorWhichIsA("Workspace") then continue end
		local root = ally:FindFirstChild("HumanoidRootPart")
		if not root then continue end
		local humanoid = ally:FindFirstChild("Humanoid") :: Humanoid
		if not humanoid or humanoid.Health <= 0 then continue end
		local distance = (self.HumanoidRootPart.Position - root.Position).Magnitude
		if distance > 10 then continue end
		table.insert(allies, ally)
	end
	return allies
end

local node = {}		

local SUCCESS,FAIL,RUNNING = 1,2,3


function node.start(self) end

function node.finish(self, status) end	

function node.run(self)
	local pro = #self.NearbyAllies
	if self.Inventory.Tool then pro *= self.Inventory.Tool.HumanZombieWinRatio end
	
	local con = #self.NearbyThreats
	if self.Humanoid.Health <= 10 then con += 1 end
	
	if con > pro then return FAIL end
	
	return SUCCESS
end

return node
