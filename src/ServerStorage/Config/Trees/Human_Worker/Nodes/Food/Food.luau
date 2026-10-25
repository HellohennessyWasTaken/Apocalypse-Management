const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerStorage = game:GetService("ServerStorage")

const Loader = require(ReplicatedStorage.Packages.Loader)
const ItemService = require(ServerStorage.Services.ItemService)

const Resources = Loader.LoadDescendants(ReplicatedStorage.Config.Items.Resources)

const node = {}

const SUCCESS, FAIL = 1, 2

function node.run(self)
	if self.Hunger > self.HungryThreshold then return FAIL end

	const position = self.Mover:GetPosition()
	local distance = math.huge
	local closestFood = nil :: Model?

	for _, resource: Model in self.NearbyResources do
		if not resource.PrimaryPart then continue end
		const resourceData = Resources[resource.Name]
		if not (resourceData and resourceData.Category == "Food") then continue end

		const offset = resource.PrimaryPart.Position - position
		const newDistance = Vector3.new(offset.X, 0, offset.Z).Magnitude
		if newDistance < distance then
			distance = newDistance
			closestFood = resource
		end
	end

	if not closestFood then return FAIL end

	-- horizontal reach: the root sits ~2.5 studs above food on the ground
	if distance <= self.BaseAttackRange then
		self.Mover:Stop()
		ItemService:Eat(self, closestFood)
		return SUCCESS
	end

	self.Mover:MoveTo(closestFood.PrimaryPart.Position, closestFood)
	if self.Mover:IsFailed() then return FAIL end

	self.WalkRandomlyStartTime = os.clock()
	return SUCCESS
end

return node
