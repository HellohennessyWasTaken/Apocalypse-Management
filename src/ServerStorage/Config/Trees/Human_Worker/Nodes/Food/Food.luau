local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local PathfindingService = game:GetService("PathfindingService")
local CollectionService = game:GetService("CollectionService")

local Loader = require(ReplicatedStorage.Packages.Loader)
local Resources = Loader.LoadDescendants(ReplicatedStorage.Config.Items.Resources)

local node = {}		

local SUCCESS,FAIL,RUNNING = 1,2,3

function node.start(self) end

function node.finish(self, status) end	

function node.run(self)
	--if not (self.Hunger <= 50) then return FAIL end
	
	local distance = math.huge
	local closestFood = nil :: Model?

	for _, resource: Model in self.NearbyResources do
		if not resource.PrimaryPart then continue end
		if Resources[resource.Name].Category ~= "Food" then continue end

		local newDistance = (resource.PrimaryPart.Position - self.HumanoidRootPart.Position).Magnitude
		if newDistance < distance then
			distance = newDistance
			closestFood = resource
		end
	end
	
	if not closestFood then return FAIL end
	
	local ItemService = require(game:GetService("ServerStorage").Services.ItemService)

	self.RaycastParams.FilterDescendantsInstances = {self.Character, CollectionService:GetTagged("Item")}
	self.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local start = self.HumanoidRootPart.Position
	local destination = closestFood.PrimaryPart.Position
	local result = workspace:Raycast(start, (destination - start), self.RaycastParams)

	if result and result.Instance then
		local path = self.CreatedPath

		local success, errorMessage = pcall(function()
			path:ComputeAsync(self.HumanoidRootPart.Position, destination)
		end)

		if success and path.Status == Enum.PathStatus.Success then
			local waypoints = path:GetWaypoints()

			for i, waypoint: PathWaypoint in waypoints do
				if waypoint.Action == Enum.PathWaypointAction.Jump then
					self.Humanoid.Jump = true
				end
				self.Humanoid:MoveTo(waypoint.Position)
				local timeOut = not self.Humanoid.MoveToFinished:Wait(1)
				if timeOut then
					self.Humanoid.Jump = true
					return FAIL
				end
				if not closestFood or not closestFood.PrimaryPart then
					return FAIL
				end

				if (self.HumanoidRootPart.Position - closestFood.PrimaryPart.Position).Magnitude <= math.abs(self.BaseAttackRange - 0.5) then
					result = ItemService:PickUp(self, closestFood)
					if result then
						return SUCCESS
					else
						return FAIL
					end
				end
			end

			self.WalkRandomlyStartTime = os.clock()
			return FAIL
		else
			self.Humanoid.Jump = true
			task.wait(1)
			return FAIL
		end
	else
		if (self.HumanoidRootPart.Position - closestFood.PrimaryPart.Position).Magnitude <= math.abs(self.BaseAttackRange - 0.5) then
			result = ItemService:PickUp(self, closestFood)
			if result then
				return SUCCESS
			else
				return FAIL
			end
		end

		self.Humanoid:MoveTo(closestFood.PrimaryPart.Position)

		self.WalkRandomlyStartTime = os.clock()
		return FAIL
	end
end

return node
