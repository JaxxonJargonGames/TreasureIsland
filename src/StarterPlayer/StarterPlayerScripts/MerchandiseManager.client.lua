local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local CrossbowAddedRemoteEvent = ReplicatedStorage:WaitForChild("CrossbowAddedRemoteEvent")
local JumpingBootsAddedRemoteEvent = ReplicatedStorage:WaitForChild("JumpingBootsAddedRemoteEvent")

local merchants = workspace:WaitForChild("Merchants"):GetChildren()
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local MerchandiseModule = require(ReplicatedStorage:WaitForChild("Merchandise"))

local CROSSBOW_PRICE = MerchandiseModule.CROSSBOW_PRICE
local JUMPING_BOOTS_PRICE = MerchandiseModule.JUMPING_BOOTS_PRICE

local function setupCrossbow()
	local hasCrossbow = player:GetAttribute("HasCrossbow") or nil
	if hasCrossbow then
		local purchase = false
		CrossbowAddedRemoteEvent:FireServer(purchase)
	end
end

setupCrossbow()

local function setupJumpingBoots()
	local hasJumpingBoots = player:GetAttribute("HasJumpingBoots") or nil
	if hasJumpingBoots then
		local purchase = false
		JumpingBootsAddedRemoteEvent:FireServer(purchase)
	end
end

setupJumpingBoots()

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
	return dialog
end

for _, merchant in pairs(merchants) do
	local head = merchant:WaitForChild("Head")
	local dialog = getDialog()
	dialog.Parent = head
end
