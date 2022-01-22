local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local ForceField = require(ServerScriptService.ForceField)

-- Command to choose a teleport destination (note the trailing space).
local COMMAND = "/teleport "
local COMMAND_2 = "/tp " -- Because it's fewer characters to type.

local AmericanMarshes = workspace.Biomes.AmericanMarshes
local AztecJungle = workspace.Biomes.AztecJungle
local CaribeanBeaches = workspace.Biomes.CaribeanBeaches
local FarEasternMountains = workspace.Biomes.FarEasternMountains

local function hasMatchingCommandName(text, command)
	-- Note: string.sub(message, ...) is the same as text:sub(...)
	return text:sub(1, command:len()):lower() == command:lower()
end

locationNumbers = {
	[1] = "Alligator Tree",
	[2] = "Barricade",
	[3] = "Cabin Clothes Line",
	[4] = "Sinkhole",
	[5] = "Sunken Rock",
	[6] = "Warning Sign",
	[7] = "Hollow Tree",
	[8] = "Leopard Statue",
	[9] = "Ruined Columns",
	[10] = "Stone Rock",
	[11] = "Sunken Altar",
	[12] = "Tree With Vines",
	[13] = "Campfire",
	[14] = "Cave Entrance",
	[15] = "Giant Palm",
	[16] = "Moored Dingy",
	[17] = "Ruined Hut",
	[18] = "Stone Crab",
	[19] = "Broken Cart",
	[20] = "Broken Tower",
	[21] = "Dead Flower Garden",
	[22] = "Stacked Stones",
	[23] = "Sword Stump",
	[24] = "Yin Yang Stone",
}

locationNames = {
	["blue"] = workspace.TeamBlue.SpawnLocation_Blue, -- No location number.
	["red"] = workspace.TeamRed.SpawnLocation_Red, -- No location number.
	["Alligator Tree"] = AmericanMarshes["Alligator Tree"]:FindFirstChild("Tree"),
	["Barricade"] = AmericanMarshes["Barricade"]:FindFirstChild("WoodSpike"),
	["Cabin Clothes Line"] = AmericanMarshes["Cabin Clothes Line"]:FindFirstChild("LineSegment"),
	["Sinkhole"] = AmericanMarshes["Sinkhole"]:FindFirstChild("Grass"),
	["Sunken Rock"] = AmericanMarshes["Sunken Rock"]:FindFirstChild("Grass"),
	["Warning Sign"] = AmericanMarshes["Warning Sign"]:FindFirstChild("WoodSpike"),
	["Hollow Tree"] = AztecJungle["Hollow Tree"].JungleTree:FindFirstChild("Tree"),
	["Leopard Statue"] = AztecJungle["Leopard Statue"]:FindFirstChild("Column"):FindFirstChild("Part"),
	["Ruined Columns"] = AztecJungle["Ruined Columns"]:FindFirstChild("Rock01"),
	["Stone Rock"] = AztecJungle["Stone Rock"]:FindFirstChild("Part"),
	["Sunken Altar"] = AztecJungle["Sunken Altar"]:FindFirstChild("SunkenAltar"):FindFirstChild("Part"),
	["Tree With Vines"] = AztecJungle["Tree With Vines"]:FindFirstChild("JungleTree"):FindFirstChild("Tree"),
	["Campfire"] = CaribeanBeaches["Campfire"]:FindFirstChild("Part"),
	["Cave Entrance"] = CaribeanBeaches["Cave Entrance"]:FindFirstChild("Rock01"),
	["Giant Palm"] = CaribeanBeaches["Giant Palm"]:FindFirstChild("Model"):FindFirstChild("PalmLeaf"),
	["Moored Dingy"] = CaribeanBeaches["Moored Dingy"]:FindFirstChild("Model"):FindFirstChild("Part"),
	["Ruined Hut"] = CaribeanBeaches["Ruined Hut"]:FindFirstChild("Door"),
	["Stone Crab"] = CaribeanBeaches["Stone Crab"]:FindFirstChild("Part"),
	["Broken Cart"] = FarEasternMountains["Broken Cart"]:FindFirstChild("Part"),
	["Broken Tower"] = FarEasternMountains["Broken Tower"]:FindFirstChild("Part"),
	["Dead Flower Garden"] = FarEasternMountains["Dead Flower Garden"]:FindFirstChild("Rock01"),
	["Stacked Stones"] = FarEasternMountains["Stacked Stones"]:FindFirstChild("Model"):FindFirstChild("Rock01"),
	["Sword Stump"] = FarEasternMountains["Sword Stump"]:FindFirstChild("Katana"),
	["Yin Yang Stone"] = FarEasternMountains["Yin Yang Stone"]:FindFirstChild("Model"):FindFirstChild("Rock01"),
}

local function getLocationFromMessage(message, command)
	-- Return nil if no location found.
	local location = nil
	local locationName = message:sub(command:len() + 1) -- Cut out the "red" from "/teleport red".
	local locationNumber = tonumber(locationName)
	if locationNumber then
		locationName = locationNumbers[locationNumber]
		location = locationNames[locationName]
	else
		location = locationNames[locationName]
	end
	return location
end

local function teleport(character, duration, location)
	ForceField.setupForceField(character, duration)
	character.Humanoid.RootPart.CFrame = location.CFrame
end

local function onPlayerChatted(player, message, recipient)
	local character = player.Character or player.CharacterAdded:wait()
	local location
	if hasMatchingCommandName(message, COMMAND) then
		location = getLocationFromMessage(message, COMMAND)
	elseif hasMatchingCommandName(message, COMMAND_2) then
		location = getLocationFromMessage(message, COMMAND_2)
	end
	if location then
		teleport(character, 5, location)
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
