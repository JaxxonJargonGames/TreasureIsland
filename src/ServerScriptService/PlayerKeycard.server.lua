local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local BLUE_KEYCARD = "Blue Keycard"
local RED_KEYCARD = "Red Keycard"

local function onPlayerAdded(player)
	local keycard
	if player.TeamColor == BrickColor.new("Really blue") then
		keycard = ServerStorage:WaitForChild(BLUE_KEYCARD)
	elseif player.TeamColor == BrickColor.new("Really red") then
		keycard = ServerStorage:WaitForChild(RED_KEYCARD)
	end
	if keycard then
		keycard:Clone().Parent = player.Backpack
		keycard:Clone().Parent = player.StarterGear
	end
end

for _, player in pairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
