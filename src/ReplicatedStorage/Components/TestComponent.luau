--< TYPES >--

--< SERVICES >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--< FOLDERS >--

--< MAIN >--
local Component = require(ReplicatedStorage.Packages.Component)
local Knit = require(ReplicatedStorage.Packages.Knit)

local TestComponent = Component.new({
	Tag = "TestComponent";
})

function TestComponent:Construct()
	
end

function TestComponent:Start()
	
end

function TestComponent:HeartbeatUpdate(dt)
	
end

function TestComponent:SteppedUpdate(dt)
	
end

function TestComponent:RenderSteppedUpdate(dt)
	
end

function TestComponent:Stop()
	
end

return TestComponent