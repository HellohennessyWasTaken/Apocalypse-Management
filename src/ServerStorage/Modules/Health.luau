--!strict

const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Signal = require(ReplicatedStorage.Packages.Signal)

const Health = {}
Health.__index = Health

export type Health = typeof(setmetatable({} :: {
	Humanoid: Humanoid,
	Died: typeof(Signal.new()),
	DiedConnection: RBXScriptConnection,
}, Health))

function Health.new(humanoid: Humanoid): Health
	const died = Signal.new()
	return setmetatable({
		Humanoid = humanoid,
		Died = died,
		DiedConnection = humanoid.Died:Connect(function()
			died:Fire()
		end),
	}, Health)
end

function Health.Get(self: Health): number
	return self.Humanoid.Health
end

function Health.GetMax(self: Health): number
	return self.Humanoid.MaxHealth
end

function Health.IsDead(self: Health): boolean
	return self.Humanoid.Health <= 0
end

function Health.TakeDamage(self: Health, amount: number)
	self.Humanoid:TakeDamage(amount)
end

function Health.Destroy(self: Health)
	self.DiedConnection:Disconnect()
	self.Died:Destroy()
end

return Health
