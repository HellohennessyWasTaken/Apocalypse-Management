local node = {}		

local SUCCESS,FAIL,RUNNING = 1,2,3

function node.start(self) end

function node.finish(self, status) end	

function node.run(self)
	return FAIL
end

return node
