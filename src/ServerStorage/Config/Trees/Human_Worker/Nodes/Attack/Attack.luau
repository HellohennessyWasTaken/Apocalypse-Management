const ServerStorage = game:GetService("ServerStorage")

const ItemService = require(ServerStorage.Services.ItemService)
const SoundService = require(ServerStorage.Services.SoundService)

const node = {}

const SUCCESS, FAIL = 1, 2

function node.run(self)
	const threat = self.Threat
	if not threat or threat.Health:IsDead() then return FAIL end

	const position = self.Mover:GetPosition()
	const threatPosition = threat.Mover:GetPosition()
	if (position - threatPosition).Magnitude > self.GetAttackRange() then
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

	threat.Health:TakeDamage(self.GetDamage())
	threat.Mover:Knockback((threatPosition - position).Unit * self.GetKnockback())

	return SUCCESS
end

return node
