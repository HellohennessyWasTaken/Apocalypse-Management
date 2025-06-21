--!strict

--< INFO >--

--< TYPES >--

--< SERVICES >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--< FOLDERS >--

--< DEPENDENCIES >--
local Knit = require(ReplicatedStorage.Packages.Knit)

--< MAIN >--
local DragService = {
	Name = script.Name,
	Client = {
		RequestDragRemoteSignal = Knit.CreateSignal()
	},
	Statuses = {
		Start = "Start",
		Continue = "Continue",
		End = "End"
	}
}

function DragService:KnitInit()
	DragService.Client.RequestDragRemoteSignal:Connect(function(player: Player, object: Instance, status: string)
		if (status ~= DragService.Statuses.Start) and (status ~= DragService.Statuses.Continue) and (status ~= DragService.Statuses.End) then
			warn(script.Name, "Unsupported status")
		end
		
		local owner = object:FindFirstChild("Owner") :: StringValue
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

		if not object:IsA("BasePart") then
			return
		end

		if (status == DragService.Statuses.Start) then
			object:SetNetworkOwner(player)
		elseif (status == DragService.Statuses.End) then
			object:SetNetworkOwner(nil)
		end
	end)
end

function DragService:KnitStart() end

return DragService