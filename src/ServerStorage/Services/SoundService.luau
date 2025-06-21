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
local Packet = require(ReplicatedStorage.Modules.Packet)

--< MAIN >--
local SoundService = {
	Name = script.Name,
	Client = {
		--[[@ Packet("PlaySound",
			"SoundName", -- string
			"Position", -- Vector3
			"Volume", -- number
			"Pitch", -- number
			"Looped" -- boolean
		)]]
		Packet("PlaySound", Packet.String, Packet.Vector3S16, Packet.NumberS8, Packet.NumberS8, Packet.Boolean1),
	},
}

function SoundService:KnitInit()
end

function SoundService:KnitStart()
end

return SoundService