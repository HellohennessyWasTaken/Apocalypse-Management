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
local PlaySoundPacket = Packet("PlaySoundPacket", Packet.String, Packet.Instance)

local SoundService = {
	Name = script.Name,
	Client = {
		PlaySoundSignal = Knit.CreateUnreliableSignal(),
	},
}

function SoundService:PlaySound(soundName: string, parentTo: Instance)
	local sound = Assets.Sounds:FindFirstChild(soundName) :: Sound
	if not sound then
		warn("Sound not found:", soundName)
		return
	end

	local soundInstance = sound:Clone()
	soundInstance.Parent = parentTo
	soundInstance:Play()
	Debris:AddItem(soundInstance, soundInstance.TimeLength)
end

function SoundService:PlaySoundClient(player: Player, soundName: string, parentTo: Instance)
	PlaySoundPacket:FireClient(player, soundName, parentTo)
end

function SoundService:PlaySoundClientAll(soundName: string, parentTo: Instance)
	PlaySoundPacket:Fire(soundName, parentTo)
end

function SoundService:KnitInit()
	SoundService.Client.PlaySoundSignal:Connect(function(player: Player, ...)
		PlaySoundPacket.OnServerEvent:Fire(player, PlaySoundPacket:Deserialize(...))
	end)
	PlaySoundPacket.Fire = function(packet, ...)
		SoundService.Client.PlaySoundSignal:FireAll(packet:Serialize(...))
	end
	PlaySoundPacket.FireClient = function(packet, player, ...)
		SoundService.Client.PlaySoundSignal:Fire(player, packet:Serialize(...))
	end
end

function SoundService:KnitStart() end

return SoundService