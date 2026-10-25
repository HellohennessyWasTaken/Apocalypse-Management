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
local ItemService = {
	Name = script.Name,
	Client = {
		itemPickUpSignal = Knit.CreateSignal(),
		itemDropSignal = Knit.CreateSignal()
	},
	debounce = {}
}

function ItemService:GetItemData(itemName: string): any
	local itemData = require(ReplicatedStorage.Config.Items:FindFirstChild(itemName, true)) :: any
	if not itemData then
		error(`Item {itemName} does not exist in the configuration.`)
	end
	return itemData
end

function ItemService:PickUp(actor: any, item: Model) : boolean
	if not item.PrimaryPart then
		warn("Item does not have a PrimaryPart set.")
		return false
	end
	if table.find(ItemService.debounce, item) then
		return false
	end
	table.insert(ItemService.debounce, item)
	
	local distance = (actor.HumanoidRootPart.Position - item.PrimaryPart.Position).Magnitude
	if distance <= actor.GetAttackRange() then
		const itemData = ItemService:GetItemData(item.Name)
		const heldItem = actor.Inventory[itemData.Type]
		if heldItem then ItemService:Drop(actor, heldItem.Name) end
		const slot = table.clone(itemData.Meta)
		slot.Name = itemData.Name
		actor.Inventory[itemData.Type] = slot
		ItemService.Client.itemPickUpSignal:FireAll(actor.Character, item.Name)
		item:Destroy()
		
		local index = table.find(ItemService.debounce, item)
		table.remove(ItemService.debounce, index)
		
		print(`{actor.Character.Name} picked up {item}`)
		print(actor.Inventory)

		return true
	end
	
	local index = table.find(ItemService.debounce, item)
	table.remove(ItemService.debounce, index)
	return false
end

function ItemService:Drop(actor: any, itemName: string)
	local itemData = ItemService:GetItemData(itemName)
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