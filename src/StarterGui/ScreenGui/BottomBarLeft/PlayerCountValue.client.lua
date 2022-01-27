local Players = game:GetService("Players")

local player = Players.LocalPlayer

local function updatePlayerCount()
	script.Parent.PlayerCountTextLabel.Text = "Players: " .. #Players:GetPlayers()
end

for _, player in pairs(Players:GetPlayers()) do
	updatePlayerCount()
end

Players.PlayerAdded:Connect(updatePlayerCount)
Players.PlayerRemoving:Connect(updatePlayerCount)
