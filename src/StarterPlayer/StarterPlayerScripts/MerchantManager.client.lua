local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local JumpingBootsRemoteEvent = ReplicatedStorage:WaitForChild("JumpingBootsRemoteEvent")

local merchants = workspace:WaitForChild("Merchants"):GetChildren()

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
	choice1.ResponseDialog = "That will cost 100 pieces of gold."
	choice1.GoodbyeDialog = "No, thanks."
	choice1.Parent = dialog
	local choice2 = Instance.new("DialogChoice")
	choice2.GoodbyeChoiceActive = false
	choice2.Name = "Purchase Jumping Boots"
	choice2.UserDialog = "Purchase!"
	choice2.Parent = choice1
	dialog.DialogChoiceSelected:Connect(function(player, choice)
		if choice.Name == "Purchase Jumping Boots" then
			if player:GetAttribute("HasJumpingBoots") then
				choice.ResponseDialog = "You already have jumping boots."
			elseif player.leaderstats.Gold.Value >= 100 then
				player.Character.Humanoid.JumpPower = 100
				local coinSound = getCoinSound()
				coinSound.Parent = dialog.Parent
				coinSound:Play()
				coinSound.Parent = SoundService
				choice.ResponseDialog = "Enjoy your new jumping boots!"
				JumpingBootsRemoteEvent:FireServer()
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
