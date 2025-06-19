local PathfindingService = game:GetService("PathfindingService")
local CollectionService = game:GetService("CollectionService")

local node = {}		

local SUCCESS,FAIL,RUNNING = 1,2,3

function node.start(obj) end

function node.finish(obj, status) end

function node.run(self)
	if not self.Threat then return SUCCESS end
	
	self.Humanoid.WalkSpeed = self.BaseSpeed * 1.5
	
	self.RaycastParams.FilterDescendantsInstances = {self.Character, self.Threat, CollectionService:GetTagged("Entity")}
	self.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local start = self.HumanoidRootPart.Position
	local destination = self.Threat.PrimaryPart.Position
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
				if (not self.Threat) or (not self.Threat:FindFirstChild("Humanoid")) or (self.Threat.Humanoid.Health <= 0) then
					--print("Threat Died")
					return SUCCESS
				end
				if (self.HumanoidRootPart.Position - self.Threat.PrimaryPart.Position).Magnitude <= math.abs(self.GetAttackRange() - 0.5) then
					--print("Reached Threat")
					return SUCCESS
				end
				if (self.Threat.PrimaryPart.Position - waypoints[#waypoints].Position).Magnitude > 2 then
					if i ~= #waypoints then
						self.Humanoid:MoveTo(waypoints[i+1].Position)
					end
					--print("Threat Moved")
					return FAIL
				end
			end

			self.WalkRandomlyStartTime = os.clock()
			return SUCCESS
		else
			self.Humanoid.Jump = true
			task.wait(1)
			return FAIL
		end
	else
		if (not self.Threat) or (not self.Threat:FindFirstChild("Humanoid")) or (self.Threat.Humanoid.Health <= 0) then
			self.Humanoid:MoveTo(self.HumanoidRootPart.Position)
			return SUCCESS
		end
		if (self.HumanoidRootPart.Position - self.Threat.PrimaryPart.Position).Magnitude <= math.abs(self.GetAttackRange() - 0.5) then
			self.Humanoid:MoveTo(self.HumanoidRootPart.Position)
			return SUCCESS
		end
		
		self.Humanoid:MoveTo(self.Threat.PrimaryPart.Position)
		
		self.WalkRandomlyStartTime = os.clock()
		return SUCCESS
	end
end

return node