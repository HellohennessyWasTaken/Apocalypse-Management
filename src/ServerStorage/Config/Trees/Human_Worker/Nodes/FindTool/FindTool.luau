const node = {}

const SUCCESS, FAIL = 1, 2

function node.run(self)
	for _, item in self.NearbyItems do
		if item.PrimaryPart then
			return SUCCESS
		end
	end
	return FAIL
end

return node
