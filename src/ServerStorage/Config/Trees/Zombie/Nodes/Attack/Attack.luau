local node = {}		

local SUCCESS,FAIL,RUNNING = 1,2,3

function node.start(self) end

function node.finish(self, status) end	

function node.run(self)
	if not self.Target or not self.Target.PrimaryPart then return FAIL end
	
	local humanoid = self.Target:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return FAIL end
		
	if (self.HumanoidRootPart.Position - self.Target.PrimaryPart.Position).Magnitude > self.GetAttackRange() then
		return FAIL
	end
	if os.clock() - self.LastTimeAttack < self.GetAttackCooldown() then
		return FAIL
	end
	self.LastTimeAttack = os.clock()
	
	humanoid:TakeDamage(self.GetDamage())
	self.Target.PrimaryPart:ApplyImpulse((self.HumanoidRootPart.Position - self.Target.PrimaryPart.Position).Unit * -self.GetKnockback())
	
	return SUCCESS
end

return node
