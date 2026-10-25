local PathfindingService = game:GetService("PathfindingService")
local CollectionService = game:GetService("CollectionService")

local node = {}		

local SUCCESS,FAIL,RUNNING = 1,2,3

function node.start(obj)
	--print(script.Name, ' Start')
end

function node.finish(obj, status) end

function node.run(self)
	if not (self.Threat and self.Threat.PrimaryPart) then return SUCCESS end

	self.Humanoid.WalkSpeed = self.BaseSpeed * 1.5
	
	self.RaycastParams.FilterDescendantsInstances = {self.Character, CollectionService:GetTagged("Entity")}
	self.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local start = self.HumanoidRootPart.Position
	const destination = start + (start - self.Threat.PrimaryPart.Position).Unit * 50
	local result = workspace:Raycast(start, (destination - start), self.RaycastParams)
	
	if result and result.Instance then
		local path = self.CreatedPath

		local success, errorMessage = pcall(function()
			path:ComputeAsync(self.HumanoidRootPart.Position, destination)
		end)

		if success and path.Status == Enum.PathStatus.Success then
			local waypoints = path:GetWaypoints()

			for i, waypoint in waypoints do
				if waypoint.Action == Enum.PathWaypointAction.Jump then
					self.Humanoid.Jump = true
				end
				self.Humanoid:MoveTo(waypoint.Position)
				local timeOut = not self.Humanoid.MoveToFinished:Wait(0.5)
				if timeOut then
					self.Humanoid.Jump = true
					if i ~= #waypoints then
						self.Humanoid:MoveTo(waypoints[i+1].Position)
					end
					return FAIL
				end
				if (not self.Threat) or (not self.Threat:FindFirstChild("Humanoid")) or (self.Threat.Humanoid.Health <= 0) then
					return SUCCESS
				end
			end

			if self.Threat then
				return FAIL
			end

			self.WalkRandomlyStartTime = os.clock()
			return SUCCESS
		else
			self.Humanoid.Jump = true
			task.wait(1)
			return FAIL
		end
	else
		self.Humanoid:MoveTo(self.HumanoidRootPart.Position)
		if (not self.Threat) or (not self.Threat:FindFirstChild("Humanoid")) or (self.Threat.Humanoid.Health <= 0) then
			--self.Humanoid:MoveTo(self.HumanoidRootPart.Position)
			return SUCCESS
		end
		
		self.Humanoid:MoveTo(destination)
		
		self.WalkRandomlyStartTime = os.clock()
		return SUCCESS
	end
end

return node
