local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

game.Players.CharacterAutoLoads = false

-- Command to choose a team (note the trailing space)
local COMMAND = "/jointeam "

local function hasMatchingCommandName(text, command)
	-- Note: string.sub(message, ...) is the same as text:sub(...)
	return text:sub(1, command:len()):lower() == command:lower()
end

local function hasMatchingTeamName(text, name)
	-- Let's check for case-insensitive partial matches, like "red" for "Red Robins".
	return text:sub(1, name:len()):lower() == name:lower()
end

local function findTeamByName(name)
	-- Return nil if no team found.
	if Teams:FindFirstChild(name) then -- First, check for the exact name of a team.
		return Teams[name] 
	end
	for _, team in pairs(Teams:GetChildren()) do
		if hasMatchingTeamName(team.Name, name) then
			return team
		end
	end
end

local function getTeamFromMessage(message)
	local teamName = message:sub(COMMAND:len() + 1) -- Cut out the "xyz" from "/jointeam xyz".
	local team = findTeamByName(teamName)
	return team
end

local function onPlayerChatted(player, message, recipient)
	if hasMatchingCommandName(message, COMMAND) then
		-- Matched "/JOINTEAM xyz" to our join command prefix "/jointeam "
		local team = getTeamFromMessage(message)
		if team then
			player.Team = team
			player.Neutral = false
		else
			player.Team = nil
			player.Neutral = true
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
