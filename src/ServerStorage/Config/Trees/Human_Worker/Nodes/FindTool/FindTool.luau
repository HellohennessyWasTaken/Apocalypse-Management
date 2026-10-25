const ServerStorage = game:GetService("ServerStorage")

const ItemService = require(ServerStorage.Services.ItemService)

const node = {}

const SUCCESS, FAIL = 1, 2

function node.run(self)
	for _, item in self.NearbyItems do
		if item.PrimaryPart and ItemService:IsUpgrade(self, item.Name) then
			return SUCCESS
		end
	end
	return FAIL
end

return node
