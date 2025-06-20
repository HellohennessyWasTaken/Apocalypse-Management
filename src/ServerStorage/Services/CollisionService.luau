--!strict

--< INFO >--

--< TYPES >--

--< SERVICES >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

--< FOLDERS >--
local Assets = ReplicatedStorage.Assets
local Packages = ReplicatedStorage.Packages

--< DEPENDENCIES >--
local Knit = require(ReplicatedStorage.Packages.Knit)

--< MAIN >--
local CollisionService = {
	Name = script.Name,
	Client = {},
}

local function setCollisionGroup(instance: Instance, collisionGroup: string)
	if instance:IsA("Model") then
		for _, descendant in instance:GetDescendants() do
			if not descendant:IsA("BasePart") then continue end
			descendant.CollisionGroup = collisionGroup
		end
	elseif instance:IsA("BasePart") then
		instance.CollisionGroup = collisionGroup
	end
end

local function onCharacterAdded(character: Model)
	setCollisionGroup(character, "Player")
	
	character.DescendantAdded:Connect(function()
		setCollisionGroup(character, "Player")
	end)
end

function CollisionService:KnitInit()
	PhysicsService:RegisterCollisionGroup("Player")
	PhysicsService:RegisterCollisionGroup("Entity")
	PhysicsService:RegisterCollisionGroup("Ragdoll")
	
	PhysicsService:CollisionGroupSetCollidable("Player", "Entity", false)
	PhysicsService:CollisionGroupSetCollidable("Player", "Ragdoll", false)
end

function CollisionService:KnitStart()
	for _, player in Players:GetPlayers() do
		if player.Character then
			onCharacterAdded(player.Character)
		end
	end
	
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(onCharacterAdded)
	end)

	for _, entity in CollectionService:GetTagged("Entity") do
		setCollisionGroup(entity, "Entity")
		
		entity.DescendantAdded:Connect(function()
			setCollisionGroup(entity, "Entity")
		end)
	end
	
	CollectionService:GetInstanceAddedSignal("Entity"):Connect(function(entity)
		setCollisionGroup(entity, "Entity")
		
		entity.DescendantAdded:Connect(function()
			setCollisionGroup(entity, "Entity")
		end)
	end)
end

return CollisionService