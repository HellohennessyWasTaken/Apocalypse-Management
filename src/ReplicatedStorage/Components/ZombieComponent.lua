--!strict

--[[
	Human. Regular ol' human
]]

--< TYPES >--

--< SERVICES >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisService = game:GetService("Debris")

--< FOLDERS >--
local Config = ReplicatedStorage.Config
local Assets = ReplicatedStorage.Assets

--< DEPENDENCIES >--
local Component = require(ReplicatedStorage.Packages.Component)
local Knit = require(ReplicatedStorage.Packages.Knit)

local Ragdoll = require(ReplicatedStorage.Modules.Ragdoll)

--< MAIN >--
local ZombieModel = Assets.Zombies.ZombieModel

local HumanComponent = Component.new({
	Tag = "Zombie";
})

function HumanComponent:Construct()
	self.Character = self.Instance :: Model
	self.Humanoid = self.Character:WaitForChild("Humanoid", 30) :: Humanoid
	self.HumanoidRootPart = self.Character:WaitForChild("HumanoidRootPart", 30) :: BasePart
	
	self.RootJoint = self.HumanoidRootPart:WaitForChild("RootJoint", 30) :: Motor6D
	self.Animator = self.Humanoid:WaitForChild("Animator", 30) :: Animator
		
	self.IdleAnimation = self.Animator:LoadAnimation(Assets.Animations.Zombie.idle.Animation1)
	self.RunAnimation = self.Animator:LoadAnimation(Assets.Animations.Zombie.run.RunAnim)
	self.ArmsAnimation = self.Animator:LoadAnimation(Assets.Animations.Zombie.arms.ArmsAnim)
	self.IdleAnimation.Priority = Enum.AnimationPriority.Idle
	self.RunAnimation.Priority = Enum.AnimationPriority.Movement
	self.ArmsAnimation.Priority = Enum.AnimationPriority.Action
 end

function HumanComponent:Start()
	local clonedModel = ZombieModel:Clone()
	for i,v in clonedModel:GetChildren() do
		v.Parent = self.Character
	end
	self.RootJoint.Part1 = self.Character.Torso
	clonedModel:Destroy()
	
	self.HumanoidRootPart.Transparency = 1
	self.Humanoid.HipHeight = 0
	
	local oldHealth = self.Humanoid.Health
	self.HealthConnection = self.Humanoid.HealthChanged:Connect(function(newHealth: number)
		if oldHealth > newHealth then
			for i,v in self.Character:GetChildren() do
				if not v:IsA("BasePart") then continue end
				if v.Name == "HumanoidRootPart" then continue end
				local clone = v:Clone()
				clone.BrickColor = BrickColor.new("Maroon")
				clone.Material = Enum.Material.Glass
				clone.Transparency = 0.6
				clone.Size *= 1.1
				clone.CanCollide = false
				clone.Massless = true
				for i,v in clone:GetChildren() do
					if v:IsA("SpecialMesh") then continue end
					task.defer(function() v:Destroy() end)
				end
				local weld = Instance.new("WeldConstraint")
				weld.Parent = clone
				weld.Part0 = clone
				weld.Part1 = v
				clone.Parent = workspace.Debris
				task.delay(0.2, function()
					clone:Destroy()
				end)
			end
		end
		oldHealth = newHealth
		
		if newHealth <= 0 then
			self.HealthConnection:Disconnect()

			local newRoot = self.HumanoidRootPart:Clone()
			newRoot.Parent = self.HumanoidRootPart.Parent
			self.HumanoidRootPart:Destroy()
			self.HumanoidRootPart = newRoot

			Ragdoll.ConfigureJoints(self.Character)
			Ragdoll.Toggle(self.Character, true)
			
			self.HumanoidRootPart:ApplyImpulse(self.HumanoidRootPart.CFrame.LookVector * -10)
		end
	end)
	
	self.IdleAnimation:Play()
	self.ArmsAnimation:Play()
	self.Humanoid.Running:Connect(function(speed)
		if speed <= 0 then
			self.RunAnimation:Stop()
			self.IdleAnimation:Play()
		else
			self.IdleAnimation:Stop()
			self.RunAnimation:Play()
			self.RunAnimation:AdjustSpeed(speed/4)
		end
	end)
end

function HumanComponent:HeartbeatUpdate(dt)
	
end

function HumanComponent:SteppedUpdate(dt)
	
end

function HumanComponent:RenderSteppedUpdate(dt)
	
end

function HumanComponent:Stop()
	if self.HealthConnection then
		self.HealthConnection:Disconnect()
	end
end

return HumanComponent