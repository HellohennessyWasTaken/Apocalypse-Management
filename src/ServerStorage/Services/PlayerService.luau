--!strict

--< INFO >--

--< TYPES >--

--< SERVICES >--
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

--< FOLDERS >--
local Assets = ReplicatedStorage.Assets
local Packages = ReplicatedStorage.Packages

--< DEPENDENCIES >--
local Knit = require(Packages.Knit)

--< MAIN >--
local PlayerService = {
	Name = script.Name,
	Players = {},
	Client = {}
}

local function PlayerAdded(player: Player)
	PlayerService.Players[player] = player

	--player.CharacterAppearanceLoaded:Connect(function(character)
	--	local humanoid = character:FindFirstChildWhichIsA("Humanoid")

	--	if humanoid and humanoid.Health > 0 then
	--		for _, part in ipairs(Assets.Parts_ClassicS15:GetDescendants()) do
	--			if part:IsA("BasePart") then
	--				humanoid:ReplaceBodyPartR15(part.Name, part:Clone())
	--			end
	--		end
	--	end
	--end)

	--player:LoadCharacter()
end

local function PlayerRemoving(player: Player)
	PlayerService.Players[player] = nil
end

function PlayerService:KnitInit()
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(PlayerAdded, player)
	end
	
	Players.PlayerAdded:Connect(PlayerAdded)
	
	Players.PlayerRemoving:Connect(PlayerRemoving)
end

function PlayerService:KnitStart()

end

return PlayerService