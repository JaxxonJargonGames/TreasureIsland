local Players = game:GetService("Players")

-- Command to choose a jump power (note the trailing space)
local COMMAND = "/jp "

local function hasMatchingCommandName(text, command)
	-- Note: string.sub(message, ...) is the same as text:sub(...)
	return text:sub(1, command:len()):lower() == command:lower()
end

local function getPowerFromMessage(message)
	local powerString = message:sub(COMMAND:len() + 1) -- Cut out the "60" from "/jumppower 60".
	local power = tonumber(powerString)
	return power
end

local function onPlayerChatted(player, message, recipient)
	if hasMatchingCommandName(message, COMMAND) then
		local character = player.Character or player.CharacterAdded:wait()
		local power = getPowerFromMessage(message)
		if power then
			character.Humanoid.JumpPower = power
		else
			print("Jump Power:", character.Humanoid.JumpPower)
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
