--!strict

--< TYPES >--

--< SERVICES >--
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local Player = game:GetService("Players").LocalPlayer

--< FOLDERS >--
local Assets = ReplicatedStorage.Assets
local Packages = ReplicatedStorage.Packages

--< DEPENDENCIES >--
local Knit = require(ReplicatedStorage.Packages.Knit)

--< MAIN >--
local Mouse = Player:GetMouse()
local TeleportOffset = Vector3.new(0, 3, 0) -- Offset for teleportation height

local CharacterController = {
	Name = script.Name,
}

function CharacterController:KnitInit()
	ContextActionService:BindAction("Teleport", function(action, userInputState, inputObject)
		if not (action == "Teleport") then return Enum.ContextActionResult.Sink end
		if not (userInputState == Enum.UserInputState.Begin) then return Enum.ContextActionResult.Sink end

		local character = Player.Character
		if not character then return Enum.ContextActionResult.Sink end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart
		if not humanoidRootPart then return Enum.ContextActionResult.Sink end
		
		local targetPosition = Mouse.Hit.Position + TeleportOffset
		humanoidRootPart.CFrame = CFrame.new(targetPosition, targetPosition + humanoidRootPart.CFrame.LookVector)

		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.T)
end

function CharacterController:KnitStart()

end

return CharacterController