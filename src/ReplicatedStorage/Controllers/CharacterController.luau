--!strict

--< TYPES >--

--< SERVICES >--
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

--< FOLDERS >--
local Assets = ReplicatedStorage.Assets
local Packages = ReplicatedStorage.Packages

--< DEPENDENCIES >--
local Knit = require(ReplicatedStorage.Packages.Knit)

--< MAIN >--
local CharacterController = {
	Name = script.Name,
}

function CharacterController:KnitInit()

end

function CharacterController:KnitStart()
	
end

return CharacterController