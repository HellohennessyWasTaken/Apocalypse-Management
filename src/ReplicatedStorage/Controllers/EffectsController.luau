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

local EffectsService

--< MAIN >--
local EffectsController = {
	Name = script.Name,
}

function EffectsController:KnitInit()

end

function EffectsController:KnitStart()
	EffectsService = Knit.GetService("EffectsService")
end

return EffectsController