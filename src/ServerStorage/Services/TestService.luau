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
local TestService: Service = {
	Name = script.Name,
	Client = {},
}

function TestService:KnitInit()
	print(TestService.Name, " Initialized")
end

function TestService:KnitStart()
	print(TestService.Name, " Started")
end

return TestService