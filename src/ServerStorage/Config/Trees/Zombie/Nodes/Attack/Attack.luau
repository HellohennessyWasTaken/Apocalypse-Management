const node = {}

const SUCCESS, FAIL = 1, 2
-- A bit over one tree tick, so the turn starts before the hit lands
const FaceLeadTime = 0.25

function node.run(self)
	const target = self.Target
	if not target or target.Health:IsDead() then return FAIL end

	const position = self.Mover:GetPosition()
	const targetPosition = target.Mover:GetPosition()
	if (position - targetPosition).Magnitude > self.GetAttackRange() then
		return FAIL
	end
	const cooldownLeft = self.GetAttackCooldown() - (os.clock() - self.LastTimeAttack)
	if cooldownLeft > 0 then
		if cooldownLeft <= FaceLeadTime then
			self.Mover:Face(targetPosition)
		end
		return FAIL
	end
	self.LastTimeAttack = os.clock()
	self.Mover:Face(targetPosition)

	target.Health:TakeDamage(self.GetDamage())
	target.Mover:Knockback((targetPosition - position).Unit * self.GetKnockback())

	return SUCCESS
end

return node
