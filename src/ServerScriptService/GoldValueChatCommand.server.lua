local Players = game:GetService("Players")

-- Command to add an amount of gold. (note the trailing space)
local ADD_COMMAND = "/addgold "
local SET_COMMAND = "/gold "

local function hasMatchingCommandName(text, command)
	-- Note: string.sub(message, ...) is the same as text:sub(...)
	return text:sub(1, command:len()):lower() == command:lower()
end

local function getNumberFromMessage(message)
	local numberString = message:sub(ADD_COMMAND:len() + 1) -- Cut out the "100" from "/addgold 100".
	local number = tonumber(numberString)
	return number
end

local function onPlayerChatted(player, message, recipient)
	if hasMatchingCommandName(message, ADD_COMMAND) then
		local number = getNumberFromMessage(message)
		if number then
			player.leaderstats.Gold.Value += number
		end
	elseif hasMatchingCommandName(message, SET_COMMAND) then
		local number = getNumberFromMessage(message)
		if number then
			player.leaderstats.Gold.Value = number
		end
	end
end

local function onPlayerAdded(player)
	if player.UserId == game.CreatorId or game.CreatorId == 0 then -- This command is available only to the game creator.
		player.Chatted:Connect(function(...)
			onPlayerChatted(player, ...)
		end)
	end
end

for _, player in pairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
Players.PlayerAdded:Connect(onPlayerAdded)
