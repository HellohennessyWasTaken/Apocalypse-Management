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

--< MAIN >--
local PlayerGui = Player.PlayerGui
local Core: ScreenGui
local UIBlur: BlurEffect
local ResourceMenuFrame: Frame

local ResourceMenuController = {
	Name = script.Name,
}

function ResourceMenuController:KnitInit()
	Core  = PlayerGui:WaitForChild("Core")
	UIBlur = Lighting:WaitForChild("UIBlur")

	ResourceMenuFrame = Core.Resource 

	ResourceMenuFrame:GetPropertyChangedSignal("Visible"):Connect(function(visible: boolean)
		UIBlur.Enabled = ResourceMenuFrame.Visible
	end)
end

function ResourceMenuController:KnitStart()
	
end

return ResourceMenuController