const node = {}

const SUCCESS, FAIL = 1, 2

function node.run(self)
	if self.Energy <= self.TiredThreshold then
		self.WantsRest = true
	elseif self.Energy >= self.MaxEnergy then
		self.WantsRest = false
	end
	if not self.WantsRest then return FAIL end

	self.Mover:Stop()
	self.LastTimeRested = os.clock()
	self.WalkRandomlyStartTime = os.clock()
	return SUCCESS
end

return node
