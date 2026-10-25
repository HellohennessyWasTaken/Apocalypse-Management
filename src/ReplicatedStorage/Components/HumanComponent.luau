--!strict

--[[
	Human. Regular ol' human
]]

--< TYPES >--

--< SERVICES >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local ChatService = game:GetService("Chat")
--local DebrisService = game:GetService("Debris")

--< FOLDERS >--
--local Config = ReplicatedStorage.Config
local Assets = ReplicatedStorage.Assets

--< DEPENDENCIES >--
local Component = require(ReplicatedStorage.Packages.Component)
local Knit = require(ReplicatedStorage.Packages.Knit)

local Ragdoll = require(ReplicatedStorage.Modules.Ragdoll)
const HitFlash = require(ReplicatedStorage.Modules.HitFlash)

--< MAIN >--
local HumanModel = Assets.Humans.HumanModel

local SkinColors = {
	BrickColor.new("Dark taupe").Number,
	BrickColor.new("Brick yellow").Number,
	BrickColor.new("Light orange").Number
}

local ShirtColors = {
	BrickColor.new("Cocoa").Number,
	BrickColor.new("Oyster").Number,
	BrickColor.new("Black").Number,
}

local PantsColors = {
	BrickColor.new("Really black").Number,
	BrickColor.new("Really black").Number,
}

local HumanComponent = Component.new({
	Tag = "Human";
})

function HumanComponent:Construct()
	self.Character = self.Instance :: Model
	self.Humanoid = self.Character:WaitForChild("Humanoid", 30) :: Humanoid
	self.HumanoidRootPart = self.Character:WaitForChild("HumanoidRootPart", 30) :: BasePart
	self.RootJoint = self.HumanoidRootPart:WaitForChild("RootJoint", 30) :: Motor6D
	self.Animator = self.Humanoid:WaitForChild("Animator", 30) :: Animator
	
	Knit.GetService("ItemService").itemPickUpSignal:Connect(function(obj: Model, item: string)
		if obj ~= self.Character then return end
		local itemData = require(ReplicatedStorage.Config.Items:FindFirstChild(item, true)) :: any
		local model = itemData.Model:Clone() :: Model
		if not model.PrimaryPart then
			warn(`Item {item} does not have a PrimaryPart set.`)
			model:Destroy()
			return
		end
		model.Parent = self.Character
		local attachment1 = model.PrimaryPart:FindFirstChild("Attachment") :: Attachment

		local weld = Instance.new("Weld")
		weld.Parent = model
		
		if itemData.Type == "Tool" then
			weld.Part0 = self.Character:WaitForChild("Right Arm")
			weld.Part1 = model.PrimaryPart
			weld.C0 = self.Character:WaitForChild("Right Arm").RightGripAttachment.CFrame
			weld.C1 = attachment1.CFrame
			
			local idk = self.Animator:LoadAnimation(Assets.Animations.Human.toolnone.ToolNoneAnim)
			idk.Priority = Enum.AnimationPriority.Action
			idk:Play()
		end
		
		for _,v in model:GetChildren() do
			if v:IsA("BasePart") then v.CanCollide = false; v.CanQuery = false; v.CanTouch = false end
		end
	end)
	
	Knit.GetService("ItemService").itemDropSignal:Connect(function(obj: Model, item: string)
		if obj ~= self.Character then return end
		local equippedItem = obj:FindFirstChild(item)
		if equippedItem then
			equippedItem:Destroy()
		end
	end)
	
	self.IdleAnimation = self.Animator:LoadAnimation(Assets.Animations.Human.idle.Animation1)
	self.RunAnimation = self.Animator:LoadAnimation(Assets.Animations.Human.run.RunAnim)
	self.IdleAnimation.Priority = Enum.AnimationPriority.Idle
	self.RunAnimation.Priority = Enum.AnimationPriority.Movement
end

function HumanComponent:Start()
	local clonedModel = HumanModel:Clone()
	for i,v in clonedModel:GetChildren() do
		v.Parent = self.Character
	end
	self.RootJoint.Part1 = self.Character.Torso
	clonedModel:Destroy()
	
	self.HumanoidRootPart.Transparency = 1
	self.Humanoid.HipHeight = 0

	local skinColor = BrickColor.new(SkinColors[math.random(1, #SkinColors)])
	local shirtColor = BrickColor.new(ShirtColors[math.random(1, #ShirtColors)])
	local pantsColor = BrickColor.new(PantsColors[math.random(1, #PantsColors)])

	local BodyColors = self.Character:FindFirstChildWhichIsA("BodyColors")
	BodyColors.HeadColor = skinColor
	BodyColors.RightArmColor = skinColor
	BodyColors.LeftArmColor = skinColor
	BodyColors.TorsoColor = shirtColor
	BodyColors.RightLegColor = pantsColor
	BodyColors.LeftLegColor = pantsColor
	
	local oldHealth = self.Humanoid.Health
	self.HealthConnection = self.Humanoid.HealthChanged:Connect(function(newHealth: number)
		if oldHealth > newHealth then
			HitFlash.Play(self.Character)
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