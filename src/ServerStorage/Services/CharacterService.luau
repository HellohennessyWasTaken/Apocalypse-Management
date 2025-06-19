--< INFO >--

--< TYPES >--

--< SERVICES >--
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

--< FOLDERS >--
local Assets = ReplicatedStorage.Assets
local Packages = ReplicatedStorage.Packages

--< DEPENDENCIES >--
local Knit = require(Packages.Knit)
local PlayerService

--< MAIN >--
local CharacterService = {
	Name = script.Name,
	Client = {}
}

function CharacterService:KnitInit()
	PlayerService = require(script.Parent.PlayerService)
end

function CharacterService:KnitStart()

end

return CharacterService