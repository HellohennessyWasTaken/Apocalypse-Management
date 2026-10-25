const node = {}

const SUCCESS, FAIL = 1, 2

function node.run(self)
	const threat = self.Threat
	if not threat or threat.Health:IsDead() then return SUCCESS end

	const position = self.Mover:GetPosition()
	const away = position - threat.Mover:GetPosition()
	const direction = if away.Magnitude > 0.01 then away.Unit else -self.Mover:GetCFrame().LookVector
	const destination = position + direction * 50

	self.Mover:SetSpeed(self.BaseSpeed * 1.5)
	self.Mover:MoveTo(destination)
	if self.Mover:IsFailed() then return FAIL end

	self.WalkRandomlyStartTime = os.clock()
	return SUCCESS
end

return node
