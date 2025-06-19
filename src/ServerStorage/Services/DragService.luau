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

--< MAIN >--
local DragService: Service = {
	Name = script.Name,
	Client = {
		RequestDragRemoteSignal = Knit.CreateSignal()
	},
}

function DragService:KnitInit()
	DragService.Client.RequestDragRemoteSignal:Connect(function(player: Player, object: Instance, status: string)
		if status ~= "Start" and status ~= "Conitnue" and status ~= "End" then
			warn(script.Name, "Unsupported status")
		end
		
		local owner = object:FindFirstChild("Owner") :: StringValue?
		if not owner then return end
				
		if (owner.Value == "") then
			owner.Value = player.Name
		elseif owner.Value == "All" then
			-- if ownership is "All" then just do nothing
		elseif (owner.Value ~= player.Name) then
			return
		end
		
		if object:IsA("Model") then
			if object.PrimaryPart then
				object = object.PrimaryPart
			else
				return
			end
		end
		
		if status == "Start" then
			object:SetNetworkOwner(player)
		elseif status == "End" then
			object:SetNetworkOwner(nil)
		end
	end)
end

function DragService:KnitStart() end

return DragService