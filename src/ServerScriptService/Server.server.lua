local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

--Knit.AddControllers(game:GetService("ReplicatedStorage"):WaitForChild("Controllers"));

for _, service in ServerStorage.Services:GetDescendants() do
	if service:IsA("ModuleScript") and service.Name:match("Service$") then
		Knit.CreateService(require(service))
	end
end

Knit.Start():andThen(function()
	warn("Server: Knit Started")

	for _, component in ServerStorage.Components:GetDescendants() do
		if not component:IsA("ModuleScript") then continue end
		require(component)
	end

end):catch(warn)