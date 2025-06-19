--< INFO >--

--< TYPES >--

--< SERVICES >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--< FOLDERS >--
local Assets = ReplicatedStorage.Assets
local Packages = ReplicatedStorage.Packages
local Modules = ReplicatedStorage.Modules

--< DEPENDENCIES >--
local Knit = require(Packages.Knit)

--< MAIN >--
local RagdollController = {
	Name = script.Name,
}

function RagdollController:KnitInit()
end

function RagdollController:KnitStart()
	
end

return RagdollController