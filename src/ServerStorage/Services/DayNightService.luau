--!strict

--< INFO >--

--< TYPES >--

--< SERVICES >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--< FOLDERS >--
local Assets = ReplicatedStorage.Assets
local Packages = ReplicatedStorage.Packages

--< DEPENDENCIES >--
local Knit = require(ReplicatedStorage.Packages.Knit)
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

--< MAIN >--
local START_TIME: number = 6
local DAY_DURATION: number = 10
local NIGHT_DURATION: number = 10
local TRANSITION_TIME: number = 5

local DayNightService = {
	Name = script.Name,
	IsDay = true :: boolean,
	Client = {
		DayChanged = Knit.CreateSignal(),
		NightChanged = Knit.CreateSignal()
	}
}

function DayNightService:UpdateLighting()
	Lighting.Brightness = DayNightService.IsDay and 1 or 0.2
	Lighting.OutdoorAmbient = DayNightService.IsDay and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 100)
end

function DayNightService:Transition()
end

function DayNightService:Cycle()
	local goal = {}
	local tweenInfo = TweenInfo.new(24, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween: Tween
	
	while true do
		goal = { ClockTime = 23.99 }
		tween = TweenService:Create(Lighting, tweenInfo, goal)
		tween:Play()
		tween.Completed:Wait()
		Lighting.ClockTime = 0
	end
end

function DayNightService:KnitInit()
	Lighting.ClockTime = START_TIME
end

function DayNightService:KnitStart()
	DayNightService:Cycle()
end

return DayNightService