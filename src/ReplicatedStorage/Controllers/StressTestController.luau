--!strict

const ContextActionService = game:GetService("ContextActionService")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")

const StressTestPackets = require(ReplicatedStorage.Modules.StressTestPackets)

const ZombieBatch = 50
const HumanBatch = 10

const StressTestController = {
	Name = script.Name,
}

local function bind(name: string, key: Enum.KeyCode, callback: () -> ())
	ContextActionService:BindAction(name, function(_, inputState)
		if inputState == Enum.UserInputState.Begin then
			callback()
		end
		return Enum.ContextActionResult.Pass
	end, false, key)
end

function StressTestController:KnitInit() end

function StressTestController:KnitStart()
	if not RunService:IsStudio() then return end

	bind("StressTestZombies", Enum.KeyCode.Z, function()
		StressTestPackets.Spawn:Fire(ZombieBatch, 0)
	end)
	bind("StressTestHumans", Enum.KeyCode.H, function()
		StressTestPackets.Spawn:Fire(0, HumanBatch)
	end)
	bind("StressTestClear", Enum.KeyCode.X, function()
		StressTestPackets.Clear:Fire()
	end)
end

return StressTestController
