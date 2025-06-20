--!strict

--< INFO >--

--< TYPES >--

--< SERVICES >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

--< FOLDERS >--
local Assets = ReplicatedStorage.Assets
local Packages = ReplicatedStorage.Packages

--< DEPENDENCIES >--
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(Packages.Signal)
local BaseCamera = require(Player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("BaseCamera"))

--< MAIN >--
local Mouse = Player:GetMouse()
local PlayerGui = Player.PlayerGui

local CurrentCamera = workspace.CurrentCamera

local DragController = {
	Name = script.Name,
	Statuses = {
		Start = "Start",
		Continue = "Continue",
		End = "End"
	},
	DragSignal = Signal.new(),
	HoldTarget = ReplicatedStorage.Logic.HoldTarget:Clone(),
	AlignPosition = ReplicatedStorage.Logic.AlignPosition:Clone(),
}

function DragController:KnitInit()
	DragController.HoldTarget.Parent = workspace.Logic
	DragController.AlignPosition.Parent = workspace.Logic
	DragController.AlignPosition.Attachment1 = DragController.HoldTarget.Attachment
end

function DragController:KnitStart()	
	UserInputService.InputChanged:Connect(function(input, gameProcessedEvent)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local subjectPosition = BaseCamera:GetSubjectPosition() :: Vector3?
			if subjectPosition == nil then return end

			local mouseLocation = UserInputService:GetMouseLocation()

			local viewportPointRay = workspace.CurrentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
			local rayOrigin = viewportPointRay.Origin
			local mousePosition = CFrame.new(rayOrigin, rayOrigin + viewportPointRay.Direction):ToWorldSpace(CFrame.new(0, 0, -1000)).Position

			local targetPosition = CFrame.new(CurrentCamera.CFrame.Position, mousePosition):ToWorldSpace(CFrame.new(0, 0, -10)).Position
			--local targetPosition = CFrame.new(subjectPosition, mousePosition):ToWorldSpace(CFrame.new(0, 0, -10)).Position
			DragController.HoldTarget.CFrame = CFrame.new(targetPosition)
		end
	end)
	
	DragController.DragSignal:Connect(function(action: string, obj: Instance, attachment0: Attachment)
		if (action == DragController.Statuses.Start) then
			local DragService = Knit.GetService("DragService")
			if not DragService then return end

			DragController.AlignPosition.Enabled = true
			DragController.AlignPosition.Attachment0 = attachment0

			DragService.RequestDragRemoteSignal:Fire(obj, DragController.Statuses.Start)
		elseif (action == DragController.Statuses.Continue) then
			return
		elseif (action == DragController.Statuses.End) then
			local DragService = Knit.GetService("DragService")
			if not DragService then return end
			
			DragController.AlignPosition.Enabled = false
			DragController.AlignPosition.Attachment0 = nil
			
			DragService.RequestDragRemoteSignal:Fire(obj, DragController.Statuses.End)
		else
			return
		end
	end)
end

return DragController