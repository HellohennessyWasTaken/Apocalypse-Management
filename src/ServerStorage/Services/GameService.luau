--!strict

--< INFO >--
--[[
	Handles gameplay like waves and so forth
]]--

--< TYPES >--

--< SERVICES >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--< FOLDERS >--
local Assets = ReplicatedStorage.Assets
local Packages = ReplicatedStorage.Packages

--< DEPENDENCIES >--
local Knit = require(ReplicatedStorage.Packages.Knit)

--< MAIN >--
local GameService: Service = {
	Name = script.Name,
	Client = {},
}

function GameService:KnitInit()
end

function GameService:KnitStart()
end

return GameService