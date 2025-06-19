local task = {}		

local SUCCESS,FAIL,RUNNING = 1,2,3

-- Any arguments passed into Tree:run(obj) can be received after the first parameter, obj
-- Example: Tree:run(obj,deltaTime) - > task.start(obj, deltaTime), task.run(obj, deltaTime), task.finish(obj, status, deltaTime)

-- Blackboards
	-- objects attached to the tree have tables injected into them called Blackboards.
	-- these can be read from and written to by the tree using the Blackboard node, and can be accessed in tasks via object.Blackboard
--

function task.start(obj)
	local Blackboard = obj.Blackboard
end

function task.finish(obj, status)
	local Blackboard = obj.Blackboard 
end	

function task.run(obj)
	local Blackboard = obj.Blackboard
	
	if not obj.Humanoid then return FAIL end
	
	if obj.Humanoid.Health <= 0 then
		return SUCCESS
	else
		return FAIL
	end
end
return task
