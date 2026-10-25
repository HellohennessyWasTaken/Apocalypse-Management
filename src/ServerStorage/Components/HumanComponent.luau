--!strict

--[[
	Human. Regular ol' human
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

local BehaviorTreeCreator = require(ServerModules.BehaviorTreeCreator)

local Names = require(Config.Names)
local MoodsList = require(Config.Moods)
local EmotionsList = require(Config.Emotions)
local StatesList = require(Config.States)

--< MAIN >--

local AgentParameters = {
	AgentRadius = 1,
	AgentHeight = 1,
	AgentCanJump = false,
}

local Tree = BehaviorTreeCreator:Create(TreesFolder.Human_Worker)

local HumanComponent = Component.new({
	Tag = "Human";
})

function HumanComponent:Construct()
	self.Character = self.Instance :: Model
	self.Humanoid = self.Character:WaitForChild("Humanoid") :: Humanoid
	self.HumanoidRootPart = self.Character:WaitForChild("HumanoidRootPart") :: BasePart
	if not (self.Humanoid and self.HumanoidRootPart) then
		self.Instance:Destroy()
		return
	end
	
	self.Character.PrimaryPart = self.HumanoidRootPart

	--self.Head = self.Character:WaitForChild("Head")
		
	self.Gender = math.random(1, 2)
	if self.Gender == 1 then
		self.Character.Name = Names.Boys[math.random(1, #Names.Boys)]
	else
		self.Character.Name = Names.Girls[math.random(1, #Names.Girls)]
	end
	
	self.Mood = MoodsList.List.Meh
	self.Emotion = {} :: {string}
	self.State = {} :: {string}
	
	self.Traits = {}
	
	self.MaxHunger = 100
	self.Hunger = math.random(1, self.MaxHunger)
	self.MaxEnergy = 100
	self.Energy = math.random(1, self.MaxEnergy)
	
	self.AgentParameters = AgentParameters
	self.WalkRandomlyStartTime = os.clock()
	self.WalkRandomlyCooldownMin = 7
	self.WalkRandomlyCooldownMax = 15
	self.WalkRandomlyCooldown = math.random(self.WalkRandomlyCooldownMin, self.WalkRandomlyCooldownMax)
	self.WanderOrigin = self.HumanoidRootPart.Position
	self.WanderRadius = 30
	
	self.ViewRange = 50
	self.FieldOfView = 210
	
	self.Threat = nil :: Model?
	self.LastTimeSawThreat = math.huge
	self.MemoryTime = 10

	self.AlertRange = 10
	self.AlertFieldOfView = 360
	self.IsAlert = false

	self.NearbyThreats = {}
	self.NearbyAllies = {}
	self.NearbyItems = {}
	
	self.BaseDamage = 5
	self.BaseAttackRange = 3
	self.BaseAttackCooldown = 1.5
	self.BaseSpeed = 3
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
	self.Humanoid.JumpPower = 20
	
	self.Humanoid.Died:Connect(function()
		local ItemService = require(game:GetService("ServerStorage").Services.ItemService)
		for _, v in self.Inventory do
			if not v then continue end
			ItemService:Drop(self, v.Name)
		end
	end)
end

function HumanComponent:Start()
	task.wait(3)

	local min, max = 10, 25
	coroutine.resume(coroutine.create(function()
		task.wait(math.random(min,max))
		while task.wait() do			
			if self.Mood then
				if self.Humanoid.Health <= 0 then break end
				if self.Character:FindFirstChild("HumanoidRootPart") then
					ChatService:Chat(self.HumanoidRootPart, self.Mood)
				end
				task.wait(math.random(min,max))
			end
			
			if (#self.Emotion >= 1) then
				if self.Humanoid.Health <= 0 then break end
				if self.Character:FindFirstChild("HumanoidRootPart") then
					ChatService:Chat(self.HumanoidRootPart, self.Emotion[math.random(1, #self.Emotion)])
				end
				task.wait(math.random(min,max))
			end
			
			if (#self.State >= 1) then
				if self.Humanoid.Health <= 0 then break end
				if self.Character:FindFirstChild("HumanoidRootPart") then
					ChatService:Chat(self.HumanoidRootPart, self.State[math.random(1, #self.State)])
				end
				task.wait(math.random(min,max))
			end
		end
	end))
	
	coroutine.resume(coroutine.create(function()
		while task.wait(4) do
			if self.Humanoid.Health <= 0 then break end
			
			if self.Hunger <= 50 then
				table.insert(self.State, StatesList.List.Hungry)
			else
				local index = table.find(self.State, StatesList.List.Hungry)
				table.remove(self.State, index)
			end
			
			if self.Energy <= 50 then
				table.insert(self.State, StatesList.List.Tired)
			else
				local index = table.find(self.State, StatesList.List.Tired)
				table.remove(self.State, index)
			end
			
			self.Hunger = math.clamp(self.Hunger-1, 0, self.MaxHunger)
			self.Energy = math.clamp(self.Energy-1, 0, self.MaxEnergy)
		end
	end))
	
	local _result
	while task.wait(0.2) do
		_result = Tree:Run(self)
	end
end

function HumanComponent:HeartbeatUpdate(dt)
	
end

function HumanComponent:SteppedUpdate(dt)
	
end

function HumanComponent:RenderSteppedUpdate(dt)
	
end

function HumanComponent:Stop()
end

return HumanComponent