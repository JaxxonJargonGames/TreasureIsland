local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ChooseTeamRemoteEvent = ReplicatedStorage:WaitForChild("ChooseTeamRemoteEvent")
local PlayerEnterRemoteEvent = ReplicatedStorage:WaitForChild("PlayerEnterRemoteEvent")
local SetupMerchandiseRemoteEvent = ReplicatedStorage:WaitForChild("SetupMerchandiseRemoteEvent")

local BLUE_KEYCARD = "Blue Keycard"
local RED_KEYCARD = "Red Keycard"

local function setupKeycard(player)
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

ChooseTeamRemoteEvent.OnServerEvent:Connect(function(player, teamColor)
	player.TeamColor = teamColor
	player:LoadCharacter()
	-- Set up the keycard before any merchanise so it is always in position #1 in the backpack/inventory.
	setupKeycard(player)
	ChooseTeamRemoteEvent:FireClient(player)
	SetupMerchandiseRemoteEvent:FireClient(player)
end)

Players.PlayerAdded:Connect(function(player)
	PlayerEnterRemoteEvent:FireClient(player)
end)
