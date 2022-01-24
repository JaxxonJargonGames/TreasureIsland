local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local GoldFoundRemoteEvent = ReplicatedStorage:WaitForChild("GoldFoundRemoteEvent")
local JumpingBootsPurchasedRemoteEvent = ReplicatedStorage:WaitForChild("JumpingBootsPurchasedRemoteEvent")
local StatusRemoteEvent = ReplicatedStorage:WaitForChild("StatusRemoteEvent")
local TopScoresRemoteEvent = ReplicatedStorage:WaitForChild("TopScoresRemoteEvent")

local PlayerKilledEvent = ServerStorage:WaitForChild("PlayerKilledEvent")

local GlobalGold = DataStoreService:GetOrderedDataStore("GlobalGold")
local SessionData = DataStoreService:GetDataStore("SessionData")

-- game:GetService("DataStoreService"):GetDataStore("SessionData"):RemoveAsync(2707410670)
-- game:GetService("DataStoreService"):GetOrderedDataStore("GlobalGold"):RemoveAsync(2707410670)

-- game:GetService("DataStoreService"):GetDataStore("SessionData"):RemoveAsync(3138096286)
-- game:GetService("DataStoreService"):GetOrderedDataStore("GlobalGold"):RemoveAsync(3138096286)

local SessionDataModule = require(ServerScriptService.SessionData)
local ForceField = require(ServerScriptService.ForceField)

local crossbow = ServerStorage:WaitForChild("Crossbow 5x Scope")
local sniperRifle = ServerStorage:WaitForChild(("Sniper Rifle 10x Scope"))

local FORCE_FIELD_DURATION = 60
local STARTING_GOLD = 0
local JUMPING_BOOTS_PRICE = 100

game.Players.CharacterAutoLoads = false

-- local function crossbowEarned(player)
-- 	crossbow:Clone().Parent = player.Backpack
-- 	crossbow:Clone().Parent = player.StarterGear
-- end

-- local function sniperRifleEarned(player)
-- 	sniperRifle:Clone().Parent = player.Backpack
-- 	sniperRifle:Clone().Parent = player.StarterGear
-- end

local function onGoldFound(player, goldName)
	table.insert(SessionDataModule.foundGold, goldName)
	GoldFoundRemoteEvent:FireClient(player, goldName)
end

GoldFoundRemoteEvent.OnServerEvent:Connect(function(player, gold)
	local goldValue = gold:GetAttribute("GoldValue")
	player.leaderstats.Gold.Value += goldValue
	onGoldFound(player, gold.Name)
end)

JumpingBootsPurchasedRemoteEvent.OnServerEvent:Connect(function(player)
	player.leaderstats.Gold.Value -= JUMPING_BOOTS_PRICE
	player:SetAttribute("HasJumpingBoots", true)
end)

-- TODO: dealer gets half of the target's gold.
-- PlayerKilledEvent.Event:Connect(function(target, dealer)
-- 	dealer.leaderstats.Points.Value += PLAYER_KILLED_POINTS
-- end)

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
	local success, savedData = pcall(function()
		return SessionData:GetAsync(player.UserId)
	end)
	if success and savedData then
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
		-- Save to a player attribute so we can compare it for the global scores.
		player:SetAttribute("SavedGold", goldValue.Value)
	end
end

local function setupTopScores(player)
	local isAscending = false
	local pageSize = 20
	local pages = GlobalGold:GetSortedAsync(isAscending, pageSize)
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
		["Gold"] = player.leaderstats.Gold.Value,
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
	local currentGold = player.leaderstats.Gold.Value
	local savedGold = player:GetAttribute("SavedGold") or 0
	if currentGold > savedGold then
		local success, errorMessage = pcall(function()
			GlobalGold:SetAsync(player.UserId, currentGold)
		end)
		if not success then
			warn(errorMessage)
		end
	end
end

local function onPlayerRemoving(player)
	saveGlobal(player)
	saveData(player)
end
game.Players.PlayerRemoving:Connect(onPlayerRemoving)

game:BindToClose(function()
	for _, player in pairs(game.Players:GetPlayers()) do
		saveData(player)
		saveGlobal(player)
	end
end)
