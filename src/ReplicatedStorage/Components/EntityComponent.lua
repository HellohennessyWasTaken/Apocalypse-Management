--!strict

--< TYPES >--

--< SERVICES >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--< FOLDERS >--

--< MAIN >--
local Component = require(ReplicatedStorage.Packages.Component)
local Knit = require(ReplicatedStorage.Packages.Knit)

local EntityComponent = Component.new({
	Tag = "Entity";
})

function EntityComponent:Construct()
	
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