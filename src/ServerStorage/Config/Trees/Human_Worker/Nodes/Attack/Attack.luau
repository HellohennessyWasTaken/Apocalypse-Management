const ServerStorage = game:GetService("ServerStorage")

const ItemService = require(ServerStorage.Services.ItemService)
const SoundService = require(ServerStorage.Services.SoundService)

local node = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

function node.start(self) end

function node.finish(self, status) end	

function node.run(self)
	if not self.Threat or not self.Threat.PrimaryPart then return FAIL end

	local humanoid = self.Threat:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return FAIL end
	
	if (self.HumanoidRootPart.Position - self.Threat.PrimaryPart.Position).Magnitude > self.GetAttackRange() then
		return FAIL
	end
	if os.clock() - self.LastTimeAttack < self.GetAttackCooldown() then
		return FAIL
	end
	self.LastTimeAttack = os.clock()

	const tool = self.Inventory.Tool
	const toolSound = if tool then ItemService:GetItemData(tool.Name).Sound else nil
	if toolSound then
		SoundService:PlaySound(toolSound, self.HumanoidRootPart)
	end

	humanoid:TakeDamage(self.GetDamage())
	self.Threat.PrimaryPart:ApplyImpulse((self.HumanoidRootPart.Position - self.Threat.PrimaryPart.Position).Unit *  -self.GetKnockback())

	return SUCCESS
end

return node
