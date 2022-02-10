local Players = game:GetService("Players")

local player = Players.LocalPlayer

local textLabel = script.Parent

local function update(humanoid)
	textLabel.Text = "Jump Power: " .. tostring(humanoid.JumpPower)
end

local function onCharacterAdded(character)
	local humanoid = character:WaitForChild("Humanoid")
	update(humanoid)
	humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
		update(humanoid)
	end)
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(character)
	end)
end

for _, player in pairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
Players.PlayerAdded:Connect(onPlayerAdded)
