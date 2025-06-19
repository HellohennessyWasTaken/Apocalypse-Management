local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

--Knit.AddControllers(game:GetService("ReplicatedStorage"):WaitForChild("Controllers"));

for _, controller in ReplicatedStorage.Controllers:GetDescendants() do
	if controller:IsA("ModuleScript") and controller.Name:match("Controller$") then
		Knit.CreateController(require(controller))
	end
end

Knit.Start():andThen(function()
	warn("Client: Knit Started")

	for _, component in ReplicatedStorage.Components:GetDescendants() do
		if not component:IsA("ModuleScript") then continue end
		require(component)
	end

end):catch(warn)