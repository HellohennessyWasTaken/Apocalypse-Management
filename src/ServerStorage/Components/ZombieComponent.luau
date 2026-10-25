--!strict

--[[
	Zombie is an Entity that will target Humans
]]

--< TYPES >--

--< SERVICES >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--< FOLDERS >--
local ServerModules = ServerStorage.Modules
local Config = ReplicatedStorage.Config
local ServerConfig = ServerStorage.Config
local TreesFolder = ServerConfig.Trees

--< DEPENDENCIES >--
local Component = require(ReplicatedStorage.Packages.Component)

local BehaviorTreeCreator = require(ServerModules.BehaviorTreeCreator)
const Health = require(ServerModules.Health)
const Mover = require(ServerModules.Mover)
const NPCService = require(ServerStorage.Services.NPCService)

local AgentParameters = {
	AgentRadius = 1,
	AgentHeight = 1,
	AgentCanJump = false,
}

local Tree = BehaviorTreeCreator:Create(TreesFolder.Zombie)

--< MAIN >--
local ZombieComponent = Component.new({
	Tag = "Zombie";
})

function ZombieComponent:Construct()
	self.Character = self.Instance :: Model
	self.Humanoid = self.Character:WaitForChild("Humanoid") :: Humanoid
	self.HumanoidRootPart = self.Character:WaitForChild("HumanoidRootPart") :: BasePart
	if not (self.Humanoid and self.HumanoidRootPart) then
		self.Instance:Destroy()
		return
	end
	
	self.Character.PrimaryPart = self.HumanoidRootPart
	
	self.AgentParameters = AgentParameters
	self.WalkRandomlyStartTime = os.clock()
	self.WalkRandomlyCooldownMin = 7
	self.WalkRandomlyCooldownMax = 15
	self.WalkRandomlyCooldown = math.random(self.WalkRandomlyCooldownMin, self.WalkRandomlyCooldownMax)
	self.WanderOrigin = self.HumanoidRootPart.Position
	self.WanderRadius = 30
	
	self.ViewRange = 50
	self.FieldOfView = 180
	
	self.AlertRange = 10
	self.AlertFieldOfView = 360
	self.IsAlert = false
	
	self.Target = nil
	self.LastTimeSawTarget = os.clock()
	self.MemoryTime = 7
	
	self.BaseDamage = 7
	self.BaseAttackRange = 3
	self.BaseAttackCooldown = 1.5
	self.BaseSpeed = 2.5
	self.BaseKnockback = 3

	self.GetDamage = function ()
		local addedStat = 0
		for _, v in self.Inventory do
			if v.Damage then
				addedStat = v.Damage
			end
		end
		
		return self.BaseDamage + addedStat
	end
	self.GetAttackRange = function ()
		local addedStat = 0
		for _, v in self.Inventory do
			if v.AttackRange then
				addedStat = v.AttackRange
			end
		end

		return self.BaseAttackRange + addedStat
	end
	self.GetAttackCooldown = function ()
		local addedStat = 0
		for _, v in self.Inventory do
			if v.AttackCooldown then
				addedStat = v.AttackCooldown
			end
		end

		return self.BaseAttackCooldown + addedStat
	end
	self.GetSpeed = function ()
		local addedStat = 0
		for _, v in self.Inventory do
			if v.Speed then
				addedStat = v.Speed
			end
		end

		return self.BaseSpeed + addedStat
	end
	self.GetKnockback = function ()
		local addedStat = 0
		for _, v in self.Inventory do
			if v.Knockback then
				addedStat = v.Knockback
			end
		end

		return self.BaseKnockback + addedStat
	end

	self.LastTimeAttack = os.clock()

	self.Inventory = {
		["Helmet"] = nil,
		["Armor"] = nil,
		["Tool"] = nil,
		["Resource"] = nil
	}
	
	self.Health = Health.new(self.Humanoid)
	self.Mover = Mover.new(self.Humanoid, self.HumanoidRootPart, self.AgentParameters)
	self.Mover:SetSpeed(self.BaseSpeed)
	self.Humanoid.JumpPower = 18
end

function ZombieComponent:Start()
	NPCService:Register(self, "Zombie", Tree, 0.2, 3)
end

function ZombieComponent:Stop()
	self.IsStopped = true
	NPCService:Unregister(self)
	self.Mover:Destroy()
	self.Health:Destroy()
end

return ZombieComponent