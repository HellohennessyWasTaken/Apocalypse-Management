const node = {}

const SUCCESS, FAIL = 1, 2

function node.run(self)
	const target = self.Target
	if not target or target.Health:IsDead() then return FAIL end

	const position = self.Mover:GetPosition()
	const targetPosition = target.Mover:GetPosition()
	if (position - targetPosition).Magnitude > self.GetAttackRange() then
		return FAIL
	end
	if os.clock() - self.LastTimeAttack < self.GetAttackCooldown() then
		return FAIL
	end
	self.LastTimeAttack = os.clock()

	target.Health:TakeDamage(self.GetDamage())
	target.Mover:Knockback((targetPosition - position).Unit * self.GetKnockback())

	return SUCCESS
end

return node
