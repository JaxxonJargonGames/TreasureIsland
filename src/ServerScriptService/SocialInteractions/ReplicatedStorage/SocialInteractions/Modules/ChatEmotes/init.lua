local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Cryo = require(script.Parent.Parent.Packages.Cryo)
local t = require(script.Parent.Parent.Packages.t)
local config = require(script.Parent.Parent.config)
local events = require(script.Parent.Parent.events)

local defaultChatEvents = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents", 5)
local chatEvent = defaultChatEvents and defaultChatEvents:WaitForChild("OnNewMessage", 5)

local emotesList: { [string]: { animationId: number, triggerWords: { string } } } = require(script.emotesList)
local customEmotesList: { [string]: { animationId: number, triggerWords: { string } } } = {}

local ChatEmotes = {}

local enabled = false
local chattedConnection: RBXScriptSignal
local characterAddedConnection: RBXScriptSignal
local characterMovedConnection: RBXScriptSignal
local characterJumpedConnection: RBXScriptSignal
local currentTrack: AnimationTrack?
local random = Random.new()

local function stopCurrentTrack()
	if currentTrack then
		currentTrack:Stop()
		currentTrack = nil
	end
end

-- Returns whether or not message contains triggerWord
function ChatEmotes.messageMatchesTriggerWord(message: string, triggerWord: string): boolean
	message = " " .. string.lower(message) .. " " -- extra spaces are to help the below pattern detect word boundaries
	local pattern = "[%p%s]" .. string.lower(triggerWord) .. "[%p%s]" -- %p matches punctuation, %s matches whitespaces
	return string.find(message, pattern) ~= nil
end

-- Check if the given message should trigger an emote, and return its animation ID
function ChatEmotes.getEmoteFromMessage(message: string): (string?, string?)
	local useDefaultEmotes = config.getValues().useDefaultTriggerWordsForChatEmotes
	local list = if useDefaultEmotes then Cryo.Dictionary.join(emotesList, customEmotesList) else customEmotesList
	local candidates = {}

	for _, emote in pairs(list) do
		if emote.requiresOwnershipOf and not emote.isOwned then
			continue
		end

		for _, triggerWord in ipairs(emote.triggerWords) do
			if ChatEmotes.messageMatchesTriggerWord(message, triggerWord) then
				table.insert(candidates, { animation = emote.animationId, triggerWord = triggerWord })
			end
		end
	end

	if #candidates == 0 then
		return nil
	end

	local chosen = candidates[random:NextInteger(1, #candidates)]
	return chosen.animation, chosen.triggerWord
end

function ChatEmotes.setTriggerWordsForChatAnimation(animationId: string, triggerWords: { string })
	assert(t.string(animationId), "Bad argument #1 to ChatEmotes.setTriggerWordsForChatAnimation: expected a string")
	assert(
		t.array(t.string)(triggerWords),
		"Bad argument #2 to ChatEmotes.setTriggerWordsForChatAnimation: expected an array of strings"
	)
	customEmotesList[animationId] = {
		animationId = animationId,
		triggerWords = triggerWords,
	}
end

local function onChatted(message)
	local animationId, triggerWord = ChatEmotes.getEmoteFromMessage(message)
	local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChild("Animator")
	if animationId and animator then
		local animation = Instance.new("Animation")
		animation.AnimationId = animationId

		stopCurrentTrack()
		currentTrack = animator:LoadAnimation(animation)
		currentTrack.Priority = Enum.AnimationPriority.Action
		currentTrack:Play()

		events.onChatAnimationPlayed:Fire(animationId, triggerWord)
	end
end

function ChatEmotes.enable()
	if enabled then
		return
	end

	if chatEvent then
		chattedConnection = chatEvent.OnClientEvent:Connect(function(data)
			if data.SpeakerUserId ~= Players.LocalPlayer.UserId then
				return
			end
			onChatted(data.Message)
		end)
	else
		chattedConnection = Players.LocalPlayer.Chatted:Connect(onChatted)
	end

	local function onCharacterAdded(character)
		local humanoid = character:WaitForChild("Humanoid")
		characterMovedConnection = humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(stopCurrentTrack)
		characterJumpedConnection = humanoid.Jumping:Connect(stopCurrentTrack)
	end
	if Players.LocalPlayer.Character then
		task.spawn(function()
			onCharacterAdded(Players.LocalPlayer.Character)
		end)
	end
	characterAddedConnection = Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

	-- Ownership checks are cached on initialization because, as the call yields, performing this check when
	-- receiving a chat message would create a small delay before the animation is played
	task.spawn(function()
		for _, emote in pairs(emotesList) do
			if emote.requiresOwnershipOf then
				emote.isOwned = MarketplaceService:PlayerOwnsAsset(Players.LocalPlayer, emote.requiresOwnershipOf)
			end
		end
	end)

	enabled = true
end

function ChatEmotes.disable()
	if not enabled then
		return
	end

	stopCurrentTrack()
	if chattedConnection then
		chattedConnection:Disconnect()
		chattedConnection = nil
	end
	if characterAddedConnection then
		characterAddedConnection:Disconnect()
		characterAddedConnection = nil
	end
	if characterMovedConnection then
		characterMovedConnection:Disconnect()
		characterMovedConnection = nil
	end
	if characterJumpedConnection then
		characterJumpedConnection:Disconnect()
		characterJumpedConnection = nil
	end
	enabled = false
end

return ChatEmotes
