local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local CrossbowAddedRemoteEvent = ReplicatedStorage:WaitForChild("CrossbowAddedRemoteEvent")
local JumpingBootsAddedRemoteEvent = ReplicatedStorage:WaitForChild("JumpingBootsAddedRemoteEvent")
local SetupMerchandiseRemoteEvent = ReplicatedStorage:WaitForChild("SetupMerchandiseRemoteEvent")
local SniperRifleAddedRemoteEvent = ReplicatedStorage:WaitForChild("SniperRifleAddedRemoteEvent")

local merchants = workspace:WaitForChild("Merchants"):GetChildren()
local player = Players.LocalPlayer

local MerchandiseModule = require(ReplicatedStorage:WaitForChild("Merchandise"))

local CROSSBOW_PRICE = MerchandiseModule.CROSSBOW_PRICE
local JUMPING_BOOTS_PRICE = MerchandiseModule.JUMPING_BOOTS_PRICE
local JUMPING_BOOTS_POWER = MerchandiseModule.JUMPING_BOOTS_POWER
local SNIPER_RIFLE_PRICE = MerchandiseModule.SNIPER_RIFLE_PRICE

local function setupJumpingBoots()
	local hasJumpingBoots = player:GetAttribute("HasJumpingBoots") or nil
	if hasJumpingBoots then
		player.Character.Humanoid.JumpPower = JUMPING_BOOTS_POWER
		player:SetAttribute("HasJumpingBoots", true)
	end
end

local function setupCrossbow()
	local hasCrossbow = player:GetAttribute("HasCrossbow") or nil
	if hasCrossbow then
		local purchase = false
		CrossbowAddedRemoteEvent:FireServer(purchase)
	end
end

local function setupSniperRifle()
	local hasSniperRifle = player:GetAttribute("HasSniperRifle") or nil
	if hasSniperRifle then
		local purchase = false
		SniperRifleAddedRemoteEvent:FireServer(purchase)
	end
end

SetupMerchandiseRemoteEvent.OnClientEvent:Connect(function()
	setupJumpingBoots()
	setupCrossbow()
	setupSniperRifle()
end)

local function getCoinSound()
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://631557324"
	sound.Volume = 7
	return sound
end

local function getDialog()
	local dialog = Instance.new("Dialog")
	dialog.Purpose = Enum.DialogPurpose.Shop
	dialog.ConversationDistance = 25
	dialog.InitialPrompt = "What would you like to buy?"
	dialog.GoodbyeDialog = "Nothing now, thanks."
	dialog.Tone = Enum.DialogTone.Friendly
	local choice1 = Instance.new("DialogChoice")
	choice1.GoodbyeChoiceActive = true
	choice1.UserDialog = "Jumping boots."
	choice1.ResponseDialog = "That will cost " .. tostring(JUMPING_BOOTS_PRICE) .. " pieces of gold."
	choice1.GoodbyeDialog = "No, thanks."
	choice1.Parent = dialog
	local choiceA = Instance.new("DialogChoice")
	choiceA.GoodbyeChoiceActive = false
	choiceA.Name = "Purchase Jumping Boots"
	choiceA.UserDialog = "Purchase for " .. tostring(JUMPING_BOOTS_PRICE) .. "!"
	choiceA.Parent = choice1
	dialog.DialogChoiceSelected:Connect(function(player, choice)
		if choice.Name == "Purchase Jumping Boots" then
			if player:GetAttribute("HasJumpingBoots") then
				choice.ResponseDialog = "You already have jumping boots."
			elseif player.leaderstats.Gold.Value >= JUMPING_BOOTS_PRICE then
				local purchase = true
				JumpingBootsAddedRemoteEvent:FireServer(purchase)
				local coinSound = getCoinSound()
				coinSound.Parent = dialog.Parent
				coinSound:Play()
				coinSound.Parent = SoundService
				choice.ResponseDialog = "Enjoy your new jumping boots!"
			else
				choice.ResponseDialog = "You don't have enough gold."
			end
		end
	end)
	local choice2 = Instance.new("DialogChoice")
	choice2.GoodbyeChoiceActive = true
	choice2.UserDialog = "Crossbow."
	choice2.ResponseDialog = "That will cost " .. CROSSBOW_PRICE .. " pieces of gold."
	choice2.GoodbyeDialog = "No, thanks."
	choice2.Parent = dialog
	local choiceB = Instance.new("DialogChoice")
	choiceB.GoodbyeChoiceActive = false
	choiceB.Name = "Purchase Crossbow"
	choiceB.UserDialog = "Purchase for " .. CROSSBOW_PRICE .. "!"
	choiceB.Parent = choice2
	dialog.DialogChoiceSelected:Connect(function(player, choice)
		if choice.Name == "Purchase Crossbow" then
			if player:GetAttribute("HasCrossbow") then
				choice.ResponseDialog = "You already have a crossbow."
			elseif player.leaderstats.Gold.Value >= CROSSBOW_PRICE then
				local purchase = true
				CrossbowAddedRemoteEvent:FireServer(purchase)
				local coinSound = getCoinSound()
				coinSound.Parent = dialog.Parent
				coinSound:Play()
				coinSound.Parent = SoundService
				choice.ResponseDialog = "Enjoy your new crossbow!"
			else
				choice.ResponseDialog = "You don't have enough gold."
			end
		end
	end)
	local choice3 = Instance.new("DialogChoice")
	choice3.GoodbyeChoiceActive = true
	choice3.UserDialog = "Sniper Rifle."
	choice3.ResponseDialog = "That will cost " .. SNIPER_RIFLE_PRICE .. " pieces of gold."
	choice3.GoodbyeDialog = "No, thanks."
	choice3.Parent = dialog
	local choiceC = Instance.new("DialogChoice")
	choiceC.GoodbyeChoiceActive = false
	choiceC.Name = "Purchase Sniper Rifle"
	choiceC.UserDialog = "Purchase for " .. SNIPER_RIFLE_PRICE .. "!"
	choiceC.Parent = choice3
	dialog.DialogChoiceSelected:Connect(function(player, choice)
		if choice.Name == "Purchase Sniper Rifle" then
			if player:GetAttribute("HasSniperRifle") then
				choice.ResponseDialog = "You already have a sniper rifle."
			elseif player.leaderstats.Gold.Value >= SNIPER_RIFLE_PRICE then
				local purchase = true
				SniperRifleAddedRemoteEvent:FireServer(purchase)
				local coinSound = getCoinSound()
				coinSound.Parent = dialog.Parent
				coinSound:Play()
				coinSound.Parent = SoundService
				choice.ResponseDialog = "Enjoy your new sniper rifle!"
			else
				choice.ResponseDialog = "You don't have enough gold."
			end
		end
	end)
	return dialog
end

for _, merchant in pairs(merchants) do
	local head = merchant:WaitForChild("Head")
	local dialog = getDialog()
	dialog.Parent = head
end
