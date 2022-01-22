Players = game:GetService("Players")

local function onCharacterAdded(character)
	local forceField = Instance.new("ForceField")
	forceField.Visible = true
	forceField.Parent = character
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(character)
	end)
end

for _, player in pairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
game.Players.PlayerAdded:Connect(onPlayerAdded)
