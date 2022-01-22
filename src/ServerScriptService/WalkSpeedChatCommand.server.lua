local Players = game:GetService("Players")

-- Command to choose a walk speed (note the trailing space)
local COMMAND = "/walkspeed "

local function hasMatchingCommandName(text, command)
	-- Note: string.sub(message, ...) is the same as text:sub(...)
	return text:sub(1, command:len()):lower() == command:lower()
end

local function getSpeedFromMessage(message)
	local speedString = message:sub(COMMAND:len() + 1) -- Cut out the "60" from "/walkspeed 60".
	local speed = tonumber(speedString)
	return speed
end

local function onPlayerChatted(player, message, recipient)
	if hasMatchingCommandName(message, COMMAND) then
		local speed = getSpeedFromMessage(message)
		if speed then
			local character = player.Character or player.CharacterAdded:wait()
			character.Humanoid.WalkSpeed = speed
		end
	end
end

local function onPlayerAdded(player)
	if player.UserId == game.CreatorId then -- This command is available only to the game creator.
		player.Chatted:Connect(function(...)
			onPlayerChatted(player, ...)
		end)
	end
end

for _, player in pairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
Players.PlayerAdded:Connect(onPlayerAdded)
