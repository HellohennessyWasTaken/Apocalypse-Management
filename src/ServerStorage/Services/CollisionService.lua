--< INFO >--

--< TYPES >--

--< SERVICES >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")

--< FOLDERS >--
local Assets = ReplicatedStorage.Assets
local Packages = ReplicatedStorage.Packages

--< DEPENDENCIES >--
local Knit = require(ReplicatedStorage.Packages.Knit)

--< MAIN >--
local TestService: Service = {
	Name = script.Name,
	Client = {},
}

local function setCollisionGroup(instance: Instance, collisionGroup: string)
	if instance:IsA("Model") then
		for _, descendant in instance:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.CollisionGroup = collisionGroup
			end
		end
	elseif instance:IsA("BasePart") then
		instance.CollisionGroup = collisionGroup
	end
end

function TestService:KnitInit()
	PhysicsService:RegisterCollisionGroup("Player")
	PhysicsService:RegisterCollisionGroup("Entity")
	PhysicsService:RegisterCollisionGroup("Ragdoll")
	
	PhysicsService:CollisionGroupSetCollidable("Player", "Entity", false)
	PhysicsService:CollisionGroupSetCollidable("Player", "Ragdoll", false)
end

function TestService:KnitStart()
	for _, player in game:GetService("Players"):GetPlayers() do
		if player.Character then
			setCollisionGroup(player.Character, "Player")
		end
		
		player.CharacterAdded:Connect(function(character)
			setCollisionGroup(character, "Player")
			
			character.DescendantAdded:Connect(function()
				setCollisionGroup(character, "Player")
			end)
		end)
	end
	
	game:GetService("Players").PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			setCollisionGroup(character, "Player")
			
			character.DescendantAdded:Connect(function()
				setCollisionGroup(character, "Player")
			end)
		end)
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

return TestService