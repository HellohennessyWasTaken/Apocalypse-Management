--!strict

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
local ItemService: Service = {
	Name = script.Name,
	Client = {
		itemPickUpSignal = Knit.CreateSignal(),
		itemDropSignal = Knit.CreateSignal()
	},
	debounce = {}
}

function ItemService:PickUp(actor: any, item: Model)	
	if table.find(ItemService.debounce, item) then
		return 2
	end
	table.insert(ItemService.debounce, item)
	
	local distance = (actor.HumanoidRootPart.Position - item.PrimaryPart.Position).Magnitude
	if distance <= actor.GetAttackRange() then
		local itemData = require(ReplicatedStorage.Config.Items:FindFirstChild(item.Name, true))
		if actor.Inventory[itemData.Type] then ItemService:Drop(actor, actor.Inventory[itemData.Type].Name) end
		actor.Inventory[itemData.Type] = itemData
		ItemService.Client.itemPickUpSignal:FireAll(actor.Character, item.Name)
		item:Destroy()
		
		local index = table.find(ItemService.debounce, item)
		table.remove(ItemService.debounce, index)
		
		print(`{actor.Character.Name} picked up {item}`)
		print(actor.Inventory)
		
		return 1
	end
	
	local index = table.find(ItemService.debounce, item)
	table.remove(ItemService.debounce, index)
	return 2
end

function ItemService:Drop(actor: any, itemName: string)
	local itemData = require(ReplicatedStorage.Config.Items:FindFirstChild(itemName, true))
	actor.Inventory[itemData.Type] = nil
	ItemService.Client.itemDropSignal:FireAll(actor.Character, itemName)
	
	local model = itemData.Model:Clone()
	
	model:AddTag("Item")
	model:AddTag("Draggable")
	
	model:PivotTo(actor.HumanoidRootPart.CFrame * CFrame.new(0,0,-2))
	model.Parent = workspace
end

function ItemService:KnitInit()
end

function ItemService:KnitStart()
end

return ItemService