--!strict

--< INFO >--

--< TYPES >--

--< SERVICES >--
const ReplicatedStorage = game:GetService("ReplicatedStorage")

--< FOLDERS >--
const Assets = ReplicatedStorage.Assets

--< DEPENDENCIES >--
const Knit = require(ReplicatedStorage.Packages.Knit)
const Packet = require(ReplicatedStorage.Modules.Packet)

--< MAIN >--
--[[@ Packet("SoundPacket",
	"SoundName", -- string
	"ParentTo", -- Instance
)]]
const PlaySoundPacket = Packet("PlaySoundPacket", Packet.String, Packet.Instance)

const SoundController = {
	Name = script.Name,
}

function SoundController:PlaySound(soundName: string, parentTo: Instance?)
	const sound = Assets.Sounds:FindFirstChild(soundName) :: Sound?
	if not sound then
		warn("Sound not found:", soundName)
		return
	end
	if not parentTo then return end

	const soundInstance = sound:Clone()
	soundInstance.Parent = parentTo
	-- TimeLength is 0 until the asset loads, so Debris with TimeLength can destroy it before it plays
	soundInstance.Ended:Once(function()
		soundInstance:Destroy()
	end)
	soundInstance:Play()
end

function SoundController:KnitInit() end

function SoundController:KnitStart()
	const SoundService = Knit.GetService("SoundService")
	const PlaySoundSignal = SoundService.PlaySoundSignal

	PlaySoundSignal:Connect(function(...)
		PlaySoundPacket.OnClientEvent:Fire(PlaySoundPacket:Deserialize(...))
	end)

	PlaySoundPacket.Fire = function(packet, ...)
		PlaySoundSignal:FireServer(packet:Serialize(...))
	end

	PlaySoundPacket.OnClientEvent:Connect(function(soundName, parentTo)
		SoundController:PlaySound(soundName, parentTo)
	end)
end

return SoundController
