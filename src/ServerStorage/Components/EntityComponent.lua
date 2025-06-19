--!strict

--[[
	Anything with a Humanoid, that can die, be destroyed etc
]]

--< TYPES >--

--< SERVICES >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--< FOLDERS >--

--< DEPENDENCIES >--
local Component = require(ReplicatedStorage.Packages.Component)
local Knit = require(ReplicatedStorage.Packages.Knit)

--< MAIN >--
local EntityComponent = Component.new({
	Tag = "Entity";
})

function EntityComponent:Construct()
	self.Model = self.Instance :: Model
	self.Humanoid = self.Model:FindFirstChildOfClass("Humanoid") :: Humanoid
	
	self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
	self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
	self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
end

function EntityComponent:Start()
	
end

function EntityComponent:HeartbeatUpdate(dt)
	
end

function EntityComponent:SteppedUpdate(dt)
	
end

function EntityComponent:RenderSteppedUpdate(dt)
	
end

function EntityComponent:Stop()
	
end

return EntityComponent