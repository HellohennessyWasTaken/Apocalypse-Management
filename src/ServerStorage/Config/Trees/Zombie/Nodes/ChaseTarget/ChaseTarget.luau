const node = {}

const SUCCESS, FAIL = 1, 2

function node.run(self)
	const target = self.Target
	if not target then return SUCCESS end

	const targetPosition = target.Mover:GetPosition()
	if target.Health:IsDead() or (self.Mover:GetPosition() - targetPosition).Magnitude <= math.abs(self.GetAttackRange() - 0.5) then
		self.Mover:Stop()
		return SUCCESS
	end

	self.Mover:SetSpeed(self.BaseSpeed * 1.5)
	self.Mover:MoveTo(targetPosition, target.Character)
	if self.Mover:IsFailed() then return FAIL end

	self.WalkRandomlyStartTime = os.clock()
	return SUCCESS
end

return node
