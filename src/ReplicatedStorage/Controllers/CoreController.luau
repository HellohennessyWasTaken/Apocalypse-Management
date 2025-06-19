--< INFO >--

--< TYPES >--
--!strict

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
local BaseCamera = require(Player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("BaseCamera"))

--< MAIN >--
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local PlayerGui = Player.PlayerGui

local CurrentCamera = workspace.CurrentCamera

local HoveredObject: Instance? = nil
local SelectedObject: Instance? = nil
local HalfClickedHoveredObject: Instance? = nil

local HoveringHighlight: Highlight

local CoreController = {
	Name = script.Name,
}

function CoreController:KnitInit()

end

function CoreController:KnitStart()	
	HoveringHighlight = PlayerGui:WaitForChild("Hovering", 60)
	
	--UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	--	--if gameProcessedEvent then return end
		
	--	--if input.UserInputType == Enum.UserInputType.MouseButton1 then
	--	--	if not HoveredObject then
	--	--		HalfClickedHoveredObject = nil
	--	--	else
	--	--		HalfClickedHoveredObject = HoveredObject
	--	--	end
	--	--end
	--end)
	
	--UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
	--	--if gameProcessedEvent then return end

	--	--if input.UserInputType == Enum.UserInputType.MouseButton1 then
	--	--	if not (HoveredObject and HalfClickedHoveredObject) then
	--	--		print("1")
	--	--		SelectedObject = nil
	--	--	elseif HalfClickedHoveredObject == HoveredObject then
	--	--		print("2")
	--	--		SelectedObject = HoveredObject		
	--	--	else
	--	--		print("3")
	--	--		SelectedObject = nil
	--	--	end
	--	--	PlayerGui.Selecting.Adornee = SelectedObject
	--	--end
	--end)
	
	UserInputService.InputChanged:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then return end

		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local _tempHoveredObject: Instance
			
			local subjectPosition = BaseCamera:GetSubjectPosition() :: Vector3?
			if (not Mouse.Target) or (subjectPosition == nil) or ((Mouse.Target.Position - subjectPosition).Magnitude > 32) then
				HoveringHighlight.Adornee = nil
				HoveredObject = nil
				return
			end
			
			if Mouse.Target.Parent:IsA("Model") and (not Mouse.Target.Parent:IsA("Workspace")) then
				_tempHoveredObject = Mouse.Target.Parent
			else
				_tempHoveredObject = Mouse.Target
			end
			
			if not _tempHoveredObject:HasTag("Draggable") then
				HoveringHighlight.Adornee = nil
				HoveredObject = nil
				return
			end

			if _tempHoveredObject == SelectedObject then
				return
			else
				HoveredObject = _tempHoveredObject
				HoveringHighlight.Adornee = HoveredObject
			end
		end
	end)
end

return CoreController