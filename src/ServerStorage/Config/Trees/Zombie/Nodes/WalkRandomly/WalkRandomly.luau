const node = {}

const SUCCESS, FAIL = 1, 2

function node.run(self)
	if self.Target then return FAIL end
	self.Mover:SetSpeed(self.BaseSpeed * 0.75)

	if os.clock() - self.WalkRandomlyStartTime < self.WalkRandomlyCooldown then
		return FAIL
	end
	self.WalkRandomlyCooldown = math.random(self.WalkRandomlyCooldownMin, self.WalkRandomlyCooldownMax)

	const start = self.Mover:GetPosition()
	const origin = self.WanderOrigin
	const destination = Vector3.new(
		math.clamp(start.X + math.random(-10, 10), origin.X - self.WanderRadius, origin.X + self.WanderRadius),
		start.Y,
		math.clamp(start.Z + math.random(-10, 10), origin.Z - self.WanderRadius, origin.Z + self.WanderRadius)
	)

	self.Mover:MoveTo(destination)
	if self.Mover:IsFailed() then return FAIL end

	self.WalkRandomlyStartTime = os.clock()
	return SUCCESS
end

return node
