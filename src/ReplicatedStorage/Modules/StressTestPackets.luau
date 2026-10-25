--!strict

const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Packet = require(ReplicatedStorage.Modules.Packet)

return {
	Spawn = Packet("StressTestSpawn", Packet.NumberU16, Packet.NumberU16),
	Clear = Packet("StressTestClear"),
}
