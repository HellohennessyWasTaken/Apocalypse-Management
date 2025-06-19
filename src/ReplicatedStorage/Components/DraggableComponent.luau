-- CLIENT --

--!strict

--< TYPES >--

--< SERVICES >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players").LocalPlayer

--< FOLDERS >--

--< MAIN >--
local Component = require(ReplicatedStorage.Packages.Component)
local Knit = require(ReplicatedStorage.Packages.Knit)

local Mouse = Knit.Player:GetMouse() :: Mouse

local DraggableComponent = Component.new({
	Tag = "Draggable";
})

function DraggableComponent:Construct()
	local DragController = require(ReplicatedStorage.Controllers.DragController)
	self.OwnerTag = self.Instance:WaitForChild("Owner") :: StringValue
	
	local function setup()
		self.DragDetector = Instance.new("DragDetector")
		self.DragDetector.Parent = self.Instance
		self.DragDetector.DragStyle = Enum.DragDetectorDragStyle.Scriptable
		self.DragDetector.PermissionPolicy = Enum.DragDetectorPermissionPolicy.Everybody
		self.DragDetector.ResponseStyle = Enum.DragDetectorResponseStyle.Custom
		self.DragDetector.RunLocally = true

		self.Attachment = Instance.new("Attachment")
		self.Attachment.Name = "DragAttachment"
		if self.Instance:IsA("Model") then		
			if not self.Instance.PrimaryPart then
				local startTime = os.clock()
				repeat
					task.wait(0.1)
				until self.Instance.PrimaryPart or os.clock() - startTime >= 5	
			end

			self.Attachment.Parent = self.Instance.PrimaryPart
		else
			self.Attachment.Parent = self.Instance
		end

		--self.AlignPosition = Instance.new("AlignPosition")
		--self.AlignPosition.Parent = self.Instance
		--self.AlignPosition.Attachment0 = self.Attachment
		--self.AlignPosition.Enabled = false
		--self.AlignPosition.Responsiveness = 20
		
		self.DragDetector.DragStart:Connect(function(player)
			DragController.DragSignal:Fire("Start", self.Instance, self.Instance:FindFirstChild("DragAttachment", true))
		end)

		self.DragDetector.DragContinue:Connect(function(player)
			DragController.DragSignal:Fire("Continue", self.Instance, self.Instance:FindFirstChild("DragAttachment", true))
		end)

		self.DragDetector.DragEnd:Connect(function(player)
			--self.AlignPosition.Enabled = false
			--self.AlignPosition.Attachment1 = nil
			DragController.DragSignal:Fire("End", self.Instance, self.Instance:FindFirstChild("DragAttachment", true))
		end)
	end
	
	--if self.OwnerTag.Value == Player.Name then
	--	setup()
	--end
	
	--self.OwnerTag.Changed:Connect(function()
	--	if self.OwnerTag.Value == Player.Name then
	--		setup()
	--	else
	--		if self.DragDetector then
	--			self.DragDetector:Destroy()
	--		end
	--		if self.AlignPosition then
	--			self.AlignPosition:Destroy()
	--		end
	--	end
	--end)
	setup()
end

function DraggableComponent:Start()
end

function DraggableComponent:HeartbeatUpdate(dt)
	
end

function DraggableComponent:SteppedUpdate(dt)
	
end

function DraggableComponent:RenderSteppedUpdate(dt)
	
end

function DraggableComponent:Stop()
	
end

return DraggableComponent