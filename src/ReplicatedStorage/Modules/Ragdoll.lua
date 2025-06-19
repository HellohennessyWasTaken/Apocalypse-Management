--[[

	 _   _  ___  ____  ___ ______   _  
	| | | |/ _ \|  _ \|_ _|__  | \ | | 
	| |_| | | | | |_) || |  / /|  \| | 
	|  _  | |_| |  _ < | | / /_| |\  | 
	|_| |_|\___/|_| \_|___/____|_| \_| 
	  ____                             
	 / ___| __ _ _ __ ___   ___ ___    
	| |  _ / _` | '_ ` _ \ / _ / __|   
	| |_| | (_| | | | | | |  __\__ \   
	 \____|\__,_|_| |_| |_|\___|___/  
	 
	HORIZN Games rbx.lua Framework [2024]
	Written by KyleBubble - @Kyl_Bubble
	Developed with coffee and sleepless nights.

	--//	DISCRIPTION		//--
	
	simple ragdoll system, i think its stolen from Reddev :-)
	
	--//	 FUNCTIONS		//--

		im too lazy to type those


]]

----------//	 Library	 //----------

--local _L = shared

----------//	Reference	 //----------


----------//	 Setting	 //----------

local jointLimits = {  -- Limits of how far joints can twist
	Neck 			= {30,-30,30},
	Root 			= {0,0,0},
	Waist 			= {15,-45,45},

	LeftShoulder 	= {45, 45, 45},
	RightShoulder 	= {45, 45, 45},
	LeftElbow		= {15,0,90},
	RightElbow 		= {15,0,90},
	LeftWrist 		= {15,15,15},
	RightWrist 		= {15,15,15},

	LeftHip 		= {15,-20,120},
	RightHip 		= {15,-20,120},
	LeftKnee 		= {15,-120,0},
	RightKnee 		= {15,-120,0},
	LeftAnkle 		= {15,15,15},
	RightAnkle		= {15,15,15}
}

local R6AttachmentCFrames = {
	["Neck"] = {CFrame.new(0, 0.412, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1), CFrame.new(0, -0.206, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1)},
	["Left Shoulder"] = {CFrame.new(-0.5356, 0.309, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1), CFrame.new(0.0824, 0.309, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1)},
	["Right Shoulder"] = {CFrame.new(0.5356, 0.309, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1), CFrame.new(-0.0824, 0.309, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
	["Left Hip"] = {CFrame.new(-0.206, -0.412, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1), CFrame.new(0, 0.412, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1)},
	["Right Hip"] = {CFrame.new(0.206, -0.412, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1), CFrame.new(0, 0.412, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1)},
}

----------// 	 Module	  	 //----------

local Ragdoll = {}

function Ragdoll.ConfigureJoints(character)
	for _, motor in pairs(character:GetDescendants()) do
		if motor:IsA("Motor") and motor.Name ~= "Root" and motor.Name ~= "RootJoint" then
			local ballSocketConstraint = Instance.new("BallSocketConstraint")
			ballSocketConstraint.Name = motor.Name
			ballSocketConstraint.Parent = motor.Parent
			
			if character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
				local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
				a0.CFrame = R6AttachmentCFrames[motor.Name][1]
				a1.CFrame = R6AttachmentCFrames[motor.Name][2]
				a0.Name = "RagdollAttachment"
				a1.Name = "RagdollAttachment"
				a0.Parent = motor.Part0
				a1.Parent = motor.Part1
				
				ballSocketConstraint.Attachment0 = a0
				ballSocketConstraint.Attachment1 = a1
			elseif character.Humanoid.RigType == Enum.HumanoidRigType.R15 then
				ballSocketConstraint.Attachment0 = motor.Part0:FindFirstChild(motor.Name .. "Attachment")
				ballSocketConstraint.Attachment1 = motor.Part1:FindFirstChild(motor.Name .. "Attachment")
			end

			ballSocketConstraint.LimitsEnabled = true
			ballSocketConstraint.TwistLimitsEnabled = true

			if jointLimits[motor.Name] then
				ballSocketConstraint.UpperAngle = jointLimits[motor.Name][1]
				ballSocketConstraint.TwistLowerAngle = jointLimits[motor.Name][2]
				ballSocketConstraint.TwistUpperAngle = jointLimits[motor.Name][3]
			end

			ballSocketConstraint.MaxFrictionTorque = 5
		end
	end 
	
	local rootWeld = Instance.new("WeldConstraint")
	rootWeld.Part0 = character.HumanoidRootPart
	if character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
		rootWeld.Part1 = character.Torso
	elseif character.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		rootWeld.Part1 = character.LowerTorso
	end
	rootWeld.Enabled = false
	rootWeld.Name = "RootWeld"
	rootWeld.Parent = character.HumanoidRootPart
end

function Ragdoll.Toggle(character, bool)
	if character == nil then
		return 
	end
	
	if bool then
		for _, Part in pairs(character:GetChildren()) do
			if Part:IsA("BasePart") then
				Part.CollisionGroup = "Ragdoll"
			end
		end
		
		for _, joint in pairs(character:GetDescendants()) do
			if joint:IsA("Motor6D") then
				if joint.Enabled == false then
					return
				end
			end
		end

		for _, joint in pairs(character:GetDescendants()) do
			if joint:IsA("Motor6D") then
				joint.Enabled = false
			end
		end

		character.HumanoidRootPart.RootWeld.Enabled = true
		character.HumanoidRootPart.CanCollide = false
	else
		for _, joint in pairs(character:GetDescendants()) do
			if joint:IsA("Motor6D") then
				joint.Enabled = true
			end
		end

		character.HumanoidRootPart.RootWeld.Enabled = false
		character.HumanoidRootPart.CanCollide = true
	end
end

return Ragdoll