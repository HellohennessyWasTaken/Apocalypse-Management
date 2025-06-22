--!strict

--< INFO >--

--< TYPES >--

--< SERVICES >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Player = game:GetService("Players").LocalPlayer

--< FOLDERS >--
local Assets = ReplicatedStorage.Assets
local Packages = ReplicatedStorage.Packages

--< DEPENDENCIES >--
local Knit = require(Packages.Knit)
local Icon = require(ReplicatedStorage.Modules.Icon)


--< MAIN >--
local PlayerGui = Player.PlayerGui
local Core  = PlayerGui:WaitForChild("Core") :: ScreenGui

local InterfaceController = {
	Name = script.Name,

	Core  = Core,
	ResourceMenuFrame = Core:WaitForChild("Resource") :: Frame,
	--ProfessionMenuFrame = Core:WaitForChild("Profession") :: Frame,

	UIBlur = Lighting:WaitForChild("UIBlur") :: BlurEffect,
}

function InterfaceController:KnitInit()
	InterfaceController.UIBlur.Enabled = false
	for	_, frame in InterfaceController.Core:GetChildren() do
		if not frame:IsA("GuiObject") then continue end	
		frame.Visible = false
	end
end

function InterfaceController:KnitStart()	
	Icon.new()
		:setLabel("Inventory")
		:bindToggleItem(InterfaceController.ResourceMenuFrame)
	Icon.new()
		:setLabel("Professions")
end

return InterfaceController