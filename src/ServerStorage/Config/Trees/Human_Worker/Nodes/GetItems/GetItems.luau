local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local PathfindingService = game:GetService("PathfindingService")
local CollectionService = game:GetService("CollectionService")

local Loader = require(ReplicatedStorage.Packages.Loader)
local Items = Loader.LoadDescendants(ReplicatedStorage.Config.Items)

local node = {}		

local SUCCESS,FAIL,RUNNING = 1,2,3

function node.start(self)
end

function node.finish(self, status)
	--print(status)
end	

function node.run(self)		
	local distance = math.huge
	local closestItem = nil :: Model?
	
	for _, item: Model in self.NearbyItems do
		if not item.PrimaryPart then continue end
		if Items[item.Name].Type == "Tool" and self.Inventory.Tool then
			if self.Inventory.Tool.Power >= Items[item.Name].Power then
				continue
			end
		end
		if Items[item.Name].Type == "Helmet" and self.Inventory.Helmet then
			if self.Inventory.Helmet.Power >= Items[item.Name].Power then
				continue
			end
		end
		if Items[item.Name].Type == "Armor" and self.Inventory.Armor then
			if self.Inventory.Armor.Power >= Items[item.Name].Power then
				continue
			end
		end
		
		local newDistance = (item.PrimaryPart.Position - self.HumanoidRootPart.Position).Magnitude
		if newDistance < distance then
			distance = newDistance
			closestItem = item
		end
	end
	
	if closestItem then
		if self.Threat then
			self.Humanoid.WalkSpeed = self.BaseSpeed * 1.5
		else
			self.Humanoid.WalkSpeed = self.BaseSpeed
		end
		
		local ItemService = require(game:GetService("ServerStorage").Services.ItemService)

		self.RaycastParams.FilterDescendantsInstances = {self.Character, CollectionService:GetTagged("Item")}
		self.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
		local start = self.HumanoidRootPart.Position
		local destination = closestItem.PrimaryPart.Position
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
					if not closestItem or not closestItem.PrimaryPart then
						return FAIL
					end
					
					if (self.HumanoidRootPart.Position - closestItem.PrimaryPart.Position).Magnitude <= math.abs(self.BaseAttackRange - 0.5) then
						result = ItemService:PickUp(self, closestItem)
						if result then
							return SUCCESS
						else
							return FAIL
						end
					end
				end

				self.WalkRandomlyStartTime = os.clock()
				result = ItemService:PickUp(self, closestItem)
				if result then
					return SUCCESS
				else
					return FAIL
				end
			else
				self.Humanoid.Jump = true
				task.wait(1)
				return FAIL
			end
		else
			if (self.HumanoidRootPart.Position - closestItem.PrimaryPart.Position).Magnitude <= math.abs(self.BaseAttackRange - 0.5) then
				result = ItemService:PickUp(self, closestItem)
				if result then
					return SUCCESS
				else
					return FAIL
				end
			end
			
			self.Humanoid:MoveTo(closestItem.PrimaryPart.Position)
			
			self.WalkRandomlyStartTime = os.clock()
			result = ItemService:PickUp(self, closestItem)
			if result then
				return SUCCESS
			else
				return FAIL
			end
		end
	end
	
	return SUCCESS
end

return node
