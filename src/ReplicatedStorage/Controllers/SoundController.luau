--!strict

--< INFO >--

--< TYPES >--

--< SERVICES >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

--< FOLDERS >--
local Assets = ReplicatedStorage.Assets

--< DEPENDENCIES >--
local Knit = require(ReplicatedStorage.Packages.Knit)
local Packet = require(ReplicatedStorage.Modules.Packet)

--< MAIN >--
--[[@ Packet("SoundPacket",
	"SoundName", -- string
	"ParentTo", -- Instance
)]]
local 	PlaySoundPacket = Packet("PlaySoundPacket", Packet.String, Packet.Instance)

local SoundController = {
	Name = script.Name,
}

function SoundController:KnitInit()
	-- SoundController.PlaySoundPacket.OnClientEvent:Connect(function(soundName, parentTo)
	-- 	print("Received sound packet:", soundName, parentTo)

	-- 	local sound = Assets.Sounds:FindFirstChild(soundName) :: Sound
	-- 	if not sound then
	-- 		warn("Sound not found:", soundName)
	-- 		return
	-- 	end

	-- 	local soundInstance = sound:Clone()
	-- 	soundInstance.Parent = parentTo
	-- 	soundInstance:Play()
	-- 	Debris:AddItem(soundInstance, soundInstance.TimeLength)
	-- end)
end

function SoundController:KnitStart()
	local SoundService = Knit.GetService("SoundService")
	local PlaySoundSignal = SoundService.PlaySoundSignal

	PlaySoundSignal:Connect(function(...)
		PlaySoundPacket.OnClientEvent:Fire(PlaySoundPacket:Deserialize(...))
	end)
	
	PlaySoundPacket.Fire = function(packet, ...)
		PlaySoundSignal:FireServer(packet:Serialize(...))
	end

	PlaySoundPacket.OnClientEvent:Connect(function(soundName, parentTo)
		local sound = Assets.Sounds:FindFirstChild(soundName) :: Sound
		if not sound then
			warn("Sound not found:", soundName)
			return
		end

		local soundInstance = sound:Clone()
		soundInstance.Parent = parentTo
		soundInstance:Play()
		Debris:AddItem(soundInstance, soundInstance.TimeLength)
	end)
end

return SoundController