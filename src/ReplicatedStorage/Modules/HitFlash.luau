--!strict

const HitFlash = {}

const DURATION = 0.2

function HitFlash.Play(character: Model)
	const previous = character:FindFirstChild("HitFlash")
	if previous then
		previous:Destroy()
	end

	const highlight = Instance.new("Highlight")
	highlight.Name = "HitFlash"
	highlight.FillColor = BrickColor.new("Maroon").Color
	highlight.FillTransparency = 0.6
	highlight.OutlineTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Parent = character
	task.delay(DURATION, function()
		highlight:Destroy()
	end)
end

return HitFlash
