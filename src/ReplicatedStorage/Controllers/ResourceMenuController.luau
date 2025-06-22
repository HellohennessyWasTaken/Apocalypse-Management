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
local Knit = require(ReplicatedStorage.Packages.Knit)

local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)

--< MAIN >--
local PlayerGui = Player.PlayerGui

local ResourceMenuController = {
	Name = script.Name,
	MainFrame = InterfaceController.ResourceMenuFrame,
	IsActive = false,
}

function ResourceMenuController:KnitInit()
	ResourceMenuController.MainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
		InterfaceController.UIBlur.Enabled = ResourceMenuController.MainFrame.Visible
		ResourceMenuController.IsActive = ResourceMenuController.MainFrame.Visible
	end)
end

function ResourceMenuController:KnitStart() end

return ResourceMenuController