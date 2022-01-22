local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local FeatureDataEvent = ServerStorage:WaitForChild("FeatureDataEvent")
local FeatureFoundRemoteEvent = ReplicatedStorage:WaitForChild("FeatureFoundRemoteEvent")
local GoldFoundRemoteEvent = ReplicatedStorage:WaitForChild("GoldFoundRemoteEvent")
local JumpingBootsRemoteEvent = ReplicatedStorage:WaitForChild("JumpingBootsRemoteEvent")
local StatusRemoteEvent = ReplicatedStorage:WaitForChild("StatusRemoteEvent")
local TopScoresRemoteEvent = ReplicatedStorage:WaitForChild("TopScoresRemoteEvent")

local PlayerKilledEvent = ServerStorage:WaitForChild("PlayerKilledEvent")

local GlobalPoints = DataStoreService:GetOrderedDataStore("GlobalPoints")
local SessionData = DataStoreService:GetDataStore("SessionData")

-- game:GetService("DataStoreService"):GetDataStore("SessionData"):RemoveAsync(2707410670)
-- game:GetService("DataStoreService"):GetDataStore("SessionData"):RemoveAsync(3138096286)

local SessionDataModule = require(ServerScriptService.SessionData)
local ForceField = require(ServerScriptService.ForceField)

local crossbow = ServerStorage:WaitForChild("Crossbow 5x Scope")
local sniperRifle = ServerStorage:WaitForChild(("Sniper Rifle 10x Scope"))

local FORCE_FIELD_DURATION = 60
local STARTING_GOLD = 0
local STARTING_POINTS = 0
local FEATURE_TOUCHED_POINTS = 3
local PLAYER_KILLED_POINTS = 10

game.Players.CharacterAutoLoads = false

local function crossbowEarned(player)
	crossbow:Clone().Parent = player.Backpack
	crossbow:Clone().Parent = player.StarterGear
end

local function sniperRifleEarned(player)
	sniperRifle:Clone().Parent = player.Backpack
	sniperRifle:Clone().Parent = player.StarterGear
end

local featureCount = 0

for _, biomeFolder in ipairs(workspace.Biomes:GetChildren()) do
	for _, feature in ipairs(biomeFolder:GetChildren()) do
		if feature:IsA("Model") then
			featureCount += 1
		end
	end
end

local function onFeatureFound(player, featureName, isSavedData)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	table.insert(SessionDataModule.foundFeatures, featureName)
	local count = #SessionDataModule.foundFeatures
	FeatureFoundRemoteEvent:FireClient(player, count, featureName)
	if count == 1 and not isSavedData then
		local messages = {
			[[Congratulations! You found your first feature.<br />Find four more to earn a crossbow.]],
			}
		StatusRemoteEvent:FireClient(player, messages)
	end
	if count == 5 then
		crossbowEarned(player)
	end
	if count == featureCount then -- There are 24 features.
		sniperRifleEarned(player)
	end
end

local function onGoldFound(player, goldName)
	table.insert(SessionDataModule.foundGold, goldName)
	GoldFoundRemoteEvent:FireClient(player, goldName)
end

FeatureFoundRemoteEvent.OnServerEvent:Connect(function(player, feature)
	player.leaderstats.Points.Value += FEATURE_TOUCHED_POINTS
	onFeatureFound(player, feature.Name, false)
end)

GoldFoundRemoteEvent.OnServerEvent:Connect(function(player, gold)
	local goldValue = gold:GetAttribute("GoldValue")
	player.leaderstats.Gold.Value += goldValue
	onGoldFound(player, gold.Name)
end)

JumpingBootsRemoteEvent.OnServerEvent:Connect(function(player)
	player.leaderstats.Gold.Value -= 100
	player:SetAttribute("HasJumpingBoots", true)
end)

PlayerKilledEvent.Event:Connect(function(target, dealer)
	dealer.leaderstats.Points.Value += PLAYER_KILLED_POINTS
end)

local function onHumanoidDied(player)
	player:LoadCharacter()
end

local function setupSessionData(player)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local folder = Instance.new("Folder")
	folder.Name = "leaderstats"
	folder.Parent = player
	local goldValue = Instance.new("IntValue")
	goldValue.Name = "Gold"
	goldValue.Parent = folder
	local points = Instance.new("IntValue")
	points.Name = "Points"
	points.Parent = folder
	local success, savedData = pcall(function()
		return SessionData:GetAsync(player.UserId)
	end)
	if success and savedData then
		local savedPoints = savedData["Points"]
		if savedPoints then
			points.Value = savedPoints
		else
			points.Value = STARTING_POINTS
		end
		local savedGoldValue = savedData["Gold"]
		if savedGoldValue then
			goldValue.Value = savedGoldValue
		else
			goldValue.Value = STARTING_GOLD
		end
		local savedGold = savedData["Found Gold"]
		if savedGold then
			for _, goldName in ipairs(savedGold) do
				onGoldFound(player, goldName)
			end
		end
		local hasJumpingBoots = savedData["Has Jumping Boots"]
		if hasJumpingBoots then
			player:SetAttribute("HasJumpingBoots", hasJumpingBoots)
		end
		-- Save points to a player attribute so we can compare it for the global scores.
		player:SetAttribute("SavedPoints", points.Value)
	end
end

local function setupFeatureData(player)
	-- Setup features separately so they come after picking a team, Which determines
	-- the color of their keycard, and the keycard is always in the first position.
	local success, savedData = pcall(function()
		return SessionData:GetAsync(player.UserId)
	end)
	if success and savedData then
		local savedFeatures = savedData["Found Features"]
		if savedFeatures then
			for _, featureName in ipairs(savedFeatures) do
				onFeatureFound(player, featureName, true)
			end
		end
	end
end

FeatureDataEvent.Event:Connect(function(player)
	setupFeatureData(player)
end)

local function setupTopScores(player)
	local isAscending = false
	local pageSize = 20
	local pages = GlobalPoints:GetSortedAsync(isAscending, pageSize)
	local topScores = pages:GetCurrentPage()
	TopScoresRemoteEvent:FireClient(player, topScores)
end

local function onCharacterAdded(character, player)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.Died:Connect(function()
		onHumanoidDied(player)
	end)
	ForceField.setupForceField(character, FORCE_FIELD_DURATION)
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(character, player)
	end)
	player:LoadCharacter()
	setupSessionData(player)
	setupTopScores(player)
end

for _, player in pairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
game.Players.PlayerAdded:Connect(onPlayerAdded)

local function saveData(player)
	local data = {
		["Points"] = player.leaderstats.Points.Value,
		["Gold"] = player.leaderstats.Gold.Value,
		["Found Features"] = SessionDataModule.foundFeatures,
		["Found Gold"] = SessionDataModule.foundGold,
		["Has Jumping Boots"] = player:GetAttribute("HasJumpingBoots")
	}
	local success, errorMessage = pcall(function()
		SessionData:SetAsync(player.UserId, data)
	end)
	if not success then
		warn(errorMessage)
	end
end

local function saveGlobal(player)
	local currentPoints = player.leaderstats.Points.Value
	if currentPoints > player:GetAttribute("SavedPoints") then
		local success, errorMessage = pcall(function()
			GlobalPoints:SetAsync(player.UserId, currentPoints)
		end)
		if not success then
			warn(errorMessage)
		end
	end
end

local function onPlayerRemoving(player)
	saveData(player)
	saveGlobal(player)
end
game.Players.PlayerRemoving:Connect(onPlayerRemoving)

game:BindToClose(function()
	for _, player in pairs(game.Players:GetPlayers()) do
		saveData(player)
		saveGlobal(player)
	end
end)
