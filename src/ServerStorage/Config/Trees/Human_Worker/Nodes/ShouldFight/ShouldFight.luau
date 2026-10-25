const node = {}

const SUCCESS, FAIL = 1, 2

function node.run(self)
	local pro = #self.NearbyAllies
	if self.Inventory.Tool then pro *= self.Inventory.Tool.HumanZombieWinRatio end

	local con = #self.NearbyThreats
	if self.Health:Get() <= 10 then con += 1 end

	return if con > pro then FAIL else SUCCESS
end

return node
