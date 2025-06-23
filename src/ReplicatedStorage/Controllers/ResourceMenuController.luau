--!strict

--< INFO >--

--< TYPES >--
type PlayerResources = {
	[string]: number,
}

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

local ResourceMenuService

--< MAIN >--
local ResourceItemFrame: Frame = ReplicatedStorage.Assets.Gui.ResourceMenu.Resource

local ResourceMenuController = {
	Name = script.Name,
	MainFrame = InterfaceController.ResourceMenuFrame,
	Container = InterfaceController.ResourceMenuFrame:WaitForChild("Main"):WaitForChild("Container") :: ScrollingFrame,
	IsActive = false,
	CurrentResources = {} :: PlayerResources,
}

function ResourceMenuController:ClearMenu()
	for _, child in ResourceMenuController.Container:GetChildren() do
		if not child:IsA("Frame") then continue end
		child:Destroy()
	end
end

function ResourceMenuController:PopulateMenu()
	for resourceName, amount in ResourceMenuController.CurrentResources do
		local resourceItem = ResourceItemFrame:Clone()
		resourceItem.Name = resourceName
		resourceItem.Visible = true
		resourceItem.Parent = ResourceMenuController.Container

		-- local resourceIcon = resourceItem:WaitForChild("Icon") :: ImageLabel
		-- local resourceAmount = resourceItem:WaitForChild("Amount") :: TextLabel

		-- resourceIcon.Image = Assets.Items.Resources[resourceName].Icon
		-- resourceAmount.Text = tostring(amount)

		-- resourceItem.InputBegan:Connect(function()
		-- 	ResourceMenuService:RemoveItem(Player, resourceName)
		-- 	ResourceMenuController:ClearMenu()
		-- 	ResourceMenuController:PopulateMenu()
		-- end)
	end
end

function ResourceMenuController:UpdateMenu()
	if not ResourceMenuService then
		ResourceMenuService = Knit.GetService("ResourceMenuService")
	end

	ResourceMenuService:GetResources(Player):andThen(function(playerResources)
		if playerResources == ResourceMenuController.CurrentResources then
			return
		end
		ResourceMenuController:ClearMenu()
		ResourceMenuController.CurrentResources = playerResources
		ResourceMenuController:PopulateMenu()
	end)
end

function ResourceMenuController:KnitInit()
	ResourceMenuController.MainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
		InterfaceController.UIBlur.Enabled = ResourceMenuController.MainFrame.Visible
		ResourceMenuController.IsActive = ResourceMenuController.MainFrame.Visible
		ResourceMenuController:UpdateMenu()
	end)
end

function ResourceMenuController:KnitStart()
	ResourceMenuService = Knit.GetService("ResourceMenuService")
end

return ResourceMenuController