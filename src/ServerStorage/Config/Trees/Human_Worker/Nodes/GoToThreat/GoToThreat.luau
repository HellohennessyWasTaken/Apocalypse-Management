const node = {}

const SUCCESS, FAIL = 1, 2

function node.run(self)
	const threat = self.Threat
	if not threat then return SUCCESS end

	const threatPosition = threat.Mover:GetPosition()
	if threat.Health:IsDead() or (self.Mover:GetPosition() - threatPosition).Magnitude <= math.abs(self.GetAttackRange() - 0.5) then
		self.Mover:Stop()
		return SUCCESS
	end

	self.Mover:SetSpeed(self.BaseSpeed * 1.5)
	self.Mover:MoveTo(threatPosition, threat.Character)
	if self.Mover:IsFailed() then return FAIL end

	self.WalkRandomlyStartTime = os.clock()
	return SUCCESS
end

return node
