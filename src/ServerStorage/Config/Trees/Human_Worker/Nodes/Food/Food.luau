const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerStorage = game:GetService("ServerStorage")

const Loader = require(ReplicatedStorage.Packages.Loader)
const ItemService = require(ServerStorage.Services.ItemService)

const Resources = Loader.LoadDescendants(ReplicatedStorage.Config.Items.Resources)

const node = {}

const SUCCESS, FAIL = 1, 2

function node.run(self)
	const position = self.Mover:GetPosition()
	local distance = math.huge
	local closestFood = nil :: Model?

	for _, resource: Model in self.NearbyResources do
		if not resource.PrimaryPart then continue end
		if Resources[resource.Name].Category ~= "Food" then continue end

		const newDistance = (resource.PrimaryPart.Position - position).Magnitude
		if newDistance < distance then
			distance = newDistance
			closestFood = resource
		end
	end

	if not closestFood then return FAIL end

	if distance <= math.abs(self.BaseAttackRange - 0.5) then
		self.Mover:Stop()
		return if ItemService:PickUp(self, closestFood) then SUCCESS else FAIL
	end

	self.Mover:MoveTo(closestFood.PrimaryPart.Position, closestFood)
	if self.Mover:IsFailed() then return FAIL end

	self.WalkRandomlyStartTime = os.clock()
	return SUCCESS
end

return node
