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
local EffectsService = {
	Name = script.Name,
	Client = {
		ReplicateEffectSignal = Knit.CreateUnreliableSignal()
	},
}

function EffectsService:ReplicateEffectToAll()
	EffectsService.Client.ReplicateEffectSignal:FireAll()
end

function EffectsService:ReplicateEffectToPlayer(player: Player)
	EffectsService.Client.ReplicateEffectSignal:Fire(player)
end

function EffectsService:KnitInit()
end

function EffectsService:KnitStart()
end

return EffectsService