--!strict

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Workspace = game:GetService("Workspace")

const ZombieAsset = ReplicatedStorage.Assets.Zombies.Zombie :: Model

const ZombieService = {
	Name = script.Name,
	Client = {},
}

function ZombieService:SpawnZombie(cFrame: CFrame)
	const clone = ZombieAsset:Clone()
	clone:PivotTo(cFrame)
	clone.Parent = Workspace
end

function ZombieService:KnitInit() end

function ZombieService:KnitStart() end

return ZombieService
