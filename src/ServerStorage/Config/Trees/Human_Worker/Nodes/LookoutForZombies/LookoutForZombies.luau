const ReplicatedStorage = game:GetService("ReplicatedStorage")

const EmotionsList = require(ReplicatedStorage.Config.Emotions)

const node = {}

const SUCCESS, FAIL = 1, 2

function node.finish(self, status)
	const index = table.find(self.Emotion, EmotionsList.List.Scared)
	if status == SUCCESS then
		if not index then
			table.insert(self.Emotion, EmotionsList.List.Scared)
		end
	elseif status == FAIL and not self.IsAlert and index then
		table.remove(self.Emotion, index)
	end
end

function node.run(self)
	return if self.Threat then SUCCESS else FAIL
end

return node
