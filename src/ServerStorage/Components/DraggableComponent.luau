-- SERVER --

--!strict

--< TYPES >--

--< SERVICES >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--< FOLDERS >--

--< MAIN >--
local Component = require(ReplicatedStorage.Packages.Component)
local Knit = require(ReplicatedStorage.Packages.Knit)

local DraggableComponent = Component.new({
	Tag = "Draggable";
})

function DraggableComponent:Construct()
	if not self.Instance:FindFirstChild("Owner") then
		local ownerValue = Instance.new("StringValue")
		ownerValue.Name = "Owner"
		ownerValue.Parent = self.Instance
	end

	--if not self.Instance:FindFirstChild("DragDetector") then
	--	local dragDetector = Instance.new("DragDetector")
	--	dragDetector.Parent = self.Instance
	--	dragDetector.DragStyle = Enum.DragDetectorDragStyle.Scriptable
	--	dragDetector.PermissionPolicy = Enum.DragDetectorPermissionPolicy.Everybody
	--	dragDetector.ResponseStyle = Enum.DragDetectorResponseStyle.Custom
	--	dragDetector.RunLocally = true
	--end
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