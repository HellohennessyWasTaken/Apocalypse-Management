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

local RessourceMenuController

--< MAIN >--
local PlayerGui = Player.PlayerGui
local Core: ScreenGui
local UIBlur: BlurEffect

local ResourceMenuFrame: Frame

local ResourceController = {
	Name = script.Name,
}

function ResourceController:KnitInit()
	Core  = PlayerGui:WaitForChild("Core")
	UIBlur = Lighting:WaitForChild("UIBlur")
	ResourceMenuFrame = Core:WaitForChild("Resource")
	
	UIBlur.Enabled = false
	for	_, frame in Core:GetChildren() do
		if not frame:IsA("GuiObject") then continue end	
		frame.Visible = false
	end
end

function ResourceController:KnitStart()	
	Icon.new()
		:setLabel("Inventory")
		:bindToggleItem(ResourceMenuFrame)
	Icon.new()
		:setLabel("Professions")
end

return ResourceController