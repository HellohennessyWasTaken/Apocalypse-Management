const ServerStorage = game:GetService("ServerStorage")

const ItemService = require(ServerStorage.Services.ItemService)
const SoundService = require(ServerStorage.Services.SoundService)

const node = {}

const SUCCESS, FAIL = 1, 2
-- A bit over one tree tick, so the turn starts before the hit lands
const FaceLeadTime = 0.25

function node.run(self)
	const threat = self.Threat
	if not threat or threat.Health:IsDead() then return FAIL end

	const position = self.Mover:GetPosition()
	const threatPosition = threat.Mover:GetPosition()
	if (position - threatPosition).Magnitude > self.GetAttackRange() then
		return FAIL
	end
	const cooldownLeft = self.GetAttackCooldown() - (os.clock() - self.LastTimeAttack)
	if cooldownLeft > 0 then
		if cooldownLeft <= FaceLeadTime then
			self.Mover:Face(threatPosition)
		end
		return FAIL
	end
	self.LastTimeAttack = os.clock()
	self.Mover:Face(threatPosition)

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
