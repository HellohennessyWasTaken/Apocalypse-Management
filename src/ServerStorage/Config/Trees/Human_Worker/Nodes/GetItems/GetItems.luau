const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerStorage = game:GetService("ServerStorage")

const Loader = require(ReplicatedStorage.Packages.Loader)
const ItemService = require(ServerStorage.Services.ItemService)

const Items = Loader.LoadDescendants(ReplicatedStorage.Config.Items)

const node = {}

const SUCCESS, FAIL = 1, 2

function node.run(self)
	const position = self.Mover:GetPosition()
	local distance = math.huge
	local closestItem = nil :: Model?

	for _, item: Model in self.NearbyItems do
		if not item.PrimaryPart then continue end
		const itemData = Items[item.Name]
		if not itemData then continue end
		const heldItem = self.Inventory[itemData.Type]
		if heldItem and heldItem.Power and heldItem.Power >= itemData.Meta.Power then continue end

		const newDistance = (item.PrimaryPart.Position - position).Magnitude
		if newDistance < distance then
			distance = newDistance
			closestItem = item
		end
	end

	if not closestItem then return SUCCESS end

	if ItemService:PickUp(self, closestItem) then
		self.Mover:Stop()
		return SUCCESS
	end

	self.Mover:SetSpeed(if self.Threat then self.BaseSpeed * 1.5 else self.BaseSpeed)
	self.Mover:MoveTo(closestItem.PrimaryPart.Position, closestItem)
	if self.Mover:IsFailed() then return FAIL end

	self.WalkRandomlyStartTime = os.clock()
	return SUCCESS
end

return node
