--!strict

--< INFO >--

--< TYPES >--

--< SERVICES >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--< FOLDERS >--
local Assets = ReplicatedStorage.Assets
local Packages = ReplicatedStorage.Packages

--< DEPENDENCIES >--
local Knit = require(ReplicatedStorage.Packages.Knit)

--< MAIN >--
local TestController = {
	Name = script.Name,
}

function TestController:KnitInit()

end

function TestController:KnitStart()

end

return TestController