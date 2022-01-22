local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

-- Tag all players except the LocalPlayer. Update tag when the player changes teams.
local function onPlayerAdded(player)
	player:GetPropertyChangedSignal("Team"):Connect(function()
		if player ~= Players.LocalPlayer then -- Local Player already gets a big icon centered on the minimap.
			local character = player.Character or player.CharacterAdded:Wait()
			local part = character:WaitForChild("HumanoidRootPart")
			if player.Team == Players.LocalPlayer.Team then
				CollectionService:RemoveTag(part, "Enemy")
				CollectionService:AddTag(part, "Teammate")
			else
				CollectionService:RemoveTag(part, "Teammate")
				CollectionService:AddTag(part, "Enemy")
			end
		end
	end)
	if player ~= Players.LocalPlayer then -- Local Player already gets a big icon centered on the minimap.
		player.CharacterAdded:Connect(function(character)
			local part = character:WaitForChild("HumanoidRootPart")
			if player.Team == Players.LocalPlayer.Team then
				CollectionService:AddTag(part, "Teammate")
			else
				CollectionService:AddTag(part, "Enemy")
			end
		end)
	end
end
Players.PlayerAdded:Connect(onPlayerAdded)
