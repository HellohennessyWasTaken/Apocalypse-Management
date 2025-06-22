--!strict

--< INFO >--

--< TYPES >--
type PlayerResources = {
	[string]: number,
}

--< SERVICES >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--< FOLDERS >--
local Assets = ReplicatedStorage.Assets
local Packages = ReplicatedStorage.Packages

--< DEPENDENCIES >--
local Knit = require(ReplicatedStorage.Packages.Knit)

--< MAIN >--
local ResourceMenuService = {
	Name = script.Name,
	Client = {},
	PlayerResources = {} :: { [Player]: PlayerResources },
}

function ResourceMenuService:AddItem(player: Player, resourceName: string)
	if not ResourceMenuService.PlayerResources[player] then
		ResourceMenuService.PlayerResources[player] = {}
	end

	if ResourceMenuService.PlayerResources[player][resourceName] then
 		ResourceMenuService.PlayerResources[player][resourceName] += 1
	else
		ResourceMenuService.PlayerResources[player][resourceName] = 1
	end
end

function ResourceMenuService:RemoveItem(player: Player, resourceName: string)
	if not ResourceMenuService.PlayerResources[player] then return end

	ResourceMenuService.PlayerResources[player][resourceName] -= 1

	if ResourceMenuService.PlayerResources[player][resourceName] <= 0 then
		ResourceMenuService.PlayerResources[player][resourceName] = nil
	end
end

function ResourceMenuService:GetResources(player: Player) : PlayerResources
	if not ResourceMenuService.PlayerResources[player] then
		ResourceMenuService.PlayerResources[player] = {}
	end

	return ResourceMenuService.PlayerResources[player]
end

function ResourceMenuService:ClearResources(player: Player)
	ResourceMenuService.PlayerResources[player] = {}
end

function ResourceMenuService:KnitInit() end

function ResourceMenuService:KnitStart() end

function ResourceMenuService.Client:GetResources(player: Player)
	return ResourceMenuService:GetResources(player)
end
	
return ResourceMenuService