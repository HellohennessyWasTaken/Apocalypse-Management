const node = {}

const SUCCESS, FAIL = 1, 2

function node.run(self)
	return if self.Health:IsDead() then SUCCESS else FAIL
end

return node
