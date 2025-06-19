local node = {}		

local SUCCESS,FAIL,RUNNING = 1,2,3

function node.start(self) end

function node.finish(self, status) end	

function node.run(self)
	local distance = math.huge
	local closestItem = nil :: Model?

	for _, item in self.NearbyItems do
		if not item.PrimaryPart then continue end

		local newDistance = (item.PrimaryPart.Position - self.HumanoidRootPart.Position).Magnitude
		if newDistance < distance then
			distance = newDistance
			closestItem = item
		end
	end
	
	if closestItem then
		return SUCCESS
	else
		return FAIL
	end
end

return node
