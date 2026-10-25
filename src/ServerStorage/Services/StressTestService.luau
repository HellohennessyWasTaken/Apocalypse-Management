--!strict

const CollectionService = game:GetService("CollectionService")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")
const Stats = game:GetService("Stats")
const Workspace = game:GetService("Workspace")

const StressTestPackets = require(ReplicatedStorage.Modules.StressTestPackets)

const Rig = ReplicatedStorage.Assets.Zombies.Zombie :: Model
const MaxSpawned = 1000
const Spacing = 4
const ReportInterval = 5

const StressTestService = {
	Name = script.Name,
	Client = {},
}

const folder = Instance.new("Folder")
folder.Name = "StressTest"

const groundParams = RaycastParams.new()

local function getOrigin(player: Player): Vector3
	const character = player.Character
	const position = if character then character:GetPivot().Position else Vector3.zero
	groundParams.ExcludeInstances = if character then {folder, character} else {folder}
	const result = Workspace:Raycast(position + Vector3.new(0, 50, 0), Vector3.new(0, -500, 0), groundParams)
	return if result then result.Position else position
end

local function spawnNPC(position: Vector3, tag: string)
	const npc = Rig:Clone()
	npc:AddTag("Entity")
	if tag ~= "Zombie" then
		npc:RemoveTag("Zombie")
		npc:AddTag(tag)
	end
	npc:PivotTo(CFrame.new(position + Vector3.new(0, 3, 0)) * CFrame.Angles(0, math.random() * math.pi * 2, 0))
	npc.Parent = folder
end

local function spawnBatch(player: Player, zombies: number, humans: number)
	const total = math.min(zombies + humans, MaxSpawned - #folder:GetChildren())
	if total <= 0 then return end

	const origin = getOrigin(player)
	const side = math.ceil(math.sqrt(total))
	for i = 0, total - 1 do
		const offset = Vector3.new(i % side - side / 2, 0, i // side - side / 2) * Spacing
		const jitter = Vector3.new(math.random() - 0.5, 0, math.random() - 0.5) * Spacing * 0.5
		spawnNPC(origin + offset + jitter, if i < zombies then "Zombie" else "Human")
	end
end

local function countTagged(tag: string): number
	local count = 0
	for _, npc in CollectionService:GetTagged(tag) do
		if npc:IsDescendantOf(Workspace) then
			count += 1
		end
	end
	return count
end

local function report(frameTimes: {number})
	if #frameTimes == 0 then return end

	local total, worst = 0, 0
	for _, dt in frameTimes do
		total += dt
		worst = math.max(worst, dt)
	end

	print(string.format(
		"[StressTest] zombies %d, humans %d | server %.0f fps (worst frame %.1f ms) | heartbeat %.2f ms | physics %.0f fps | send %.1f KB/s",
		countTagged("Zombie"),
		countTagged("Human"),
		#frameTimes / total,
		worst * 1000,
		Stats.HeartbeatTime * 1000,
		Workspace:GetRealPhysicsFPS(),
		Stats.DataSendKbps
	))
end

function StressTestService:KnitInit() end

function StressTestService:KnitStart()
	if not RunService:IsStudio() then return end

	folder.Parent = Workspace

	StressTestPackets.Spawn.OnServerEvent:Connect(spawnBatch)
	StressTestPackets.Clear.OnServerEvent:Connect(function()
		folder:ClearAllChildren()
	end)

	local frameTimes: {number} = {}
	local elapsed = 0
	RunService.Heartbeat:Connect(function(dt)
		if #folder:GetChildren() == 0 then
			table.clear(frameTimes)
			elapsed = 0
			return
		end

		table.insert(frameTimes, dt)
		elapsed += dt
		if elapsed >= ReportInterval then
			report(frameTimes)
			table.clear(frameTimes)
			elapsed = 0
		end
	end)
end

return StressTestService
