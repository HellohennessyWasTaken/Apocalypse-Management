--< INFO >--

--< TYPES >--

--< SERVICES >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--< FOLDERS >--
local Assets = ReplicatedStorage.Assets
local Packages = ReplicatedStorage.Packages

--< DEPENDENCIES >--
local Knit = require(ReplicatedStorage.Packages.Knit)

--< MAIN >--
local ResourceService: Service = {
	Name = script.Name,
	Client = {
		resourcePickUpSignal = Knit.CreateSignal(),
		itemDropSignal = Knit.CreateSignal()
	},
	debounce = {}
}

function ResourceService:PickUp(obj: any, item: Model)	
	if table.find(ResourceService.debounce, item) then
		return 2
	end
	table.insert(ResourceService.debounce, item)
	
	local distance = (obj.HumanoidRootPart.Position - item.PrimaryPart.Position).Magnitude
	if distance <= obj.GetAttackRange() then
		local itemData = require(ReplicatedStorage.Config.Items:FindFirstChild(item.Name, true))
		if obj.Inventory[itemData.Type] then ResourceService:Drop(obj, obj.Inventory[itemData.Type].Name) end
		obj.Inventory[itemData.Type] = itemData
		ResourceService.Client.itemPickUpSignal:FireAll(obj.Character, item.Name)
		item:Destroy()
		
		local index = table.find(ResourceService.debounce, item)
		table.remove(ResourceService.debounce, index)
		
		return 1
	end
	
	local index = table.find(ResourceService.debounce, item)
	table.remove(ResourceService.debounce, index)
	return 2
end

function ResourceService:Drop(obj: any, itemName: string)
	local itemData = require(ReplicatedStorage.Config.Items:FindFirstChild(itemName, true))
	obj.Inventory[itemData.Type] = nil
	ResourceService.Client.itemDropSignal:FireAll(obj.Character, itemName)
	
	local model = itemData.Model:Clone()
	
	model:AddTag("Item")
	model:AddTag("Draggable")
	
	model:PivotTo(obj.HumanoidRootPart.CFrame * CFrame.new(0,0,-2))
	model.Parent = workspace
end

function ResourceService:KnitInit()
end

function ResourceService:KnitStart()
end

return ResourceService