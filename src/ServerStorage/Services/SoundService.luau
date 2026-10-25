--!strict

--< INFO >--

--< TYPES >--

--< SERVICES >--
const ReplicatedStorage = game:GetService("ReplicatedStorage")

--< DEPENDENCIES >--
const Knit = require(ReplicatedStorage.Packages.Knit)
const Packet = require(ReplicatedStorage.Modules.Packet)

--< MAIN >--
--[[@ Packet("SoundPacket",
	"SoundName", -- string
	"ParentTo", -- Instance
)]]
const PlaySoundPacket = Packet("PlaySoundPacket", Packet.String, Packet.Instance)

const SoundService = {
	Name = script.Name,
	Client = {
		PlaySoundSignal = Knit.CreateUnreliableSignal(),
	},
}

function SoundService:PlaySound(soundName: string, parentTo: Instance)
	PlaySoundPacket:Fire(soundName, parentTo)
end

function SoundService:PlaySoundClient(player: Player, soundName: string, parentTo: Instance)
	PlaySoundPacket:FireClient(player, soundName, parentTo)
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
