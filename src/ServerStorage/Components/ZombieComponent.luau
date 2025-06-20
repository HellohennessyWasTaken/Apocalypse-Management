--!strict

--[[
	Zombie is an Entity that will target Humans
]]

--< TYPES >--

--< SERVICES >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ChatService = game:GetService("Chat")
local PathfindingService = game:GetService("PathfindingService")

--< FOLDERS >--
local ServerModules = ServerStorage.Modules
local Config = ReplicatedStorage.Config
local ServerConfig = ServerStorage.Config
local TreesFolder = ServerConfig.Trees

--< DEPENDENCIES >--
local Component = require(ReplicatedStorage.Packages.Component)
local Knit = require(ReplicatedStorage.Packages.Knit)

local BehaviorTreeCreator = require(ServerModules.BehaviorTreeCreator)

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
	
	self.ViewRange = 50
	self.FieldOfView = 180
	
	self.AlertRange = 10
	self.AlertFieldOfView = 360
	self.IsAlert = false
	
	self.Target = nil :: Model?
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
	
	self.RaycastParams = RaycastParams.new()
	self.CreatedPath = PathfindingService:CreatePath(self.AgentParameters)
	
	self.Humanoid.WalkSpeed = self.BaseSpeed
	self.Humanoid.JumpPower = 18
end

function ZombieComponent:Start()
	task.wait(3)
	
	while task.wait() do
		local result = Tree:Run(self)
	end
end

function ZombieComponent:HeartbeatUpdate(dt)
	
end

function ZombieComponent:SteppedUpdate(dt)
	
end

function ZombieComponent:RenderSteppedUpdate(dt)
	
end

function ZombieComponent:Stop()
	
end

return ZombieComponent