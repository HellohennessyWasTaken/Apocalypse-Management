--!strict

--< INFO >--

--< TYPES >--

--< SERVICES >--
local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

--< FOLDERS >--

--< DEPENDENCIES >--

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

local function onEntityAdded(entity: Model)
	setCollisionGroup(entity, "Entity")
	entity.DescendantAdded:Connect(function()
		setCollisionGroup(entity, "Entity")
	end)
end

local function onResourceAdded(resource: Model)
	if resource:HasTag("Entity") then return end
	setCollisionGroup(resource, "Resource")
	resource.DescendantAdded:Connect(function()
		setCollisionGroup(resource, "Resource")
	end)
end

local function onDraggableAdded(draggable: Model)
	if draggable:HasTag("Entity") then return end
	setCollisionGroup(draggable, "Draggable")
	draggable.DescendantAdded:Connect(function()
		setCollisionGroup(draggable, "Draggable")
	end)
end

function CollisionService:KnitInit()
	PhysicsService:RegisterCollisionGroup("Player")
	PhysicsService:RegisterCollisionGroup("Entity")
	PhysicsService:RegisterCollisionGroup("Ragdoll")
	PhysicsService:RegisterCollisionGroup("Resource")
	PhysicsService:RegisterCollisionGroup("Draggable")
	PhysicsService:RegisterCollisionGroup("NavQuery")

	PhysicsService:CollisionGroupSetCollidable("Player", "Entity", false)
	PhysicsService:CollisionGroupSetCollidable("Player", "Ragdoll", false)
	PhysicsService:CollisionGroupSetCollidable("Player", "Resource", false)
	PhysicsService:CollisionGroupSetCollidable("Player", "Draggable", false)

	-- Raycast-only group: sight and navigation rays pass through NPCs and players
	PhysicsService:CollisionGroupSetCollidable("NavQuery", "Entity", false)
	PhysicsService:CollisionGroupSetCollidable("NavQuery", "Player", false)
	PhysicsService:CollisionGroupSetCollidable("NavQuery", "Ragdoll", false)
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
		onEntityAdded(entity)
	end
	CollectionService:GetInstanceAddedSignal("Entity"):Connect(onEntityAdded)

	for _, resource in CollectionService:GetTagged("Resource") do
		onResourceAdded(resource)
	end
	CollectionService:GetInstanceAddedSignal("Resource"):Connect(onResourceAdded)

	for _, draggable in CollectionService:GetTagged("Draggable") do
		onDraggableAdded(draggable)
	end
	CollectionService:GetInstanceAddedSignal("Draggable"):Connect(onDraggableAdded)
end

return CollisionService