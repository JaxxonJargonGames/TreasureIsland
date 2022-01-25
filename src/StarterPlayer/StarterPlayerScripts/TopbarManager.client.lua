local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")

local ElapsedTimeEvent = ReplicatedFirst:WaitForChild("ElapsedTimeEvent")
local TimeOfDayEvent = ReplicatedFirst:WaitForChild("TimeOfDayEvent")

local Icon = require(ReplicatedStorage.Icon)
local IconController = require(ReplicatedStorage.Icon.IconController)
local Themes = require(ReplicatedStorage.Icon.Themes)

local player = Players.LocalPlayer
local Minimap = require(player.PlayerScripts:WaitForChild("Minimap"))

local screenGui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

local helpTextFrame = screenGui:WaitForChild("HelpTextScrollingFrame")
local scoresFrame = screenGui:WaitForChild("TopScoresScrollingFrame")

IconController.setGameTheme(Themes["BlueGradient"])

local function canSendGameInvite(targetPlayer)
	local success, canSend = pcall(function()
		return SocialService:CanSendGameInviteAsync(targetPlayer)
	end)
	return success and canSend
end

local function promptGameInvite(targetPlayer)
	local success, canInvite = pcall(function()
		return SocialService:PromptGameInvite(targetPlayer)
	end)
	return success and canInvite
end

local function openGameInvitePrompt(targetPlayer)
	local canInvite = canSendGameInvite(targetPlayer)
	if canInvite then
		local promptOpened = promptGameInvite(targetPlayer)
		return promptOpened
	end
	return false
end

local elapsedTimeIcon = Icon.new()
:lock()
:setLabel("Elapsed")

ElapsedTimeEvent.Event:Connect(function(elapsedTime)
	elapsedTimeIcon:setLabel("Elapsed: " .. tostring(elapsedTime))
end)

local topScoresIcon = Icon.new()
:setLabel("Scores")
:setMid()
:bindToggleItem(scoresFrame)

-- helpTextFrame.HelpTextLabel.Text =
-- 	"Welcome to Jaxxon Jargon's Treasure Island. "
-- 	.. "You begin your adventure as part of the Red Team or Blue Team. "
-- 	.. "Each team battles the other for control of the island. "
-- 	.. "Your first objective is to find Gold. "
-- 	.. "Your next objective is to purchase useful items in the shop. "
-- 	.. "Good luck. Your shipmates are counting on you."

-- local helpIcon = Icon.new()
-- :setLabel("Help")
-- :setMid()
-- :bindToggleItem(helpTextFrame)

local mapIcon = Icon.new()
:setLabel("Map")
:setMid()
:bindEvent("selected", function(self)
	Minimap:Toggle()
	self:deselect()
end)

local inviteFriendsIcon = Icon.new()
:setLabel("Invite")
:setMid()
:bindEvent("selected", function(self)
	openGameInvitePrompt(player)
	self:deselect()
end)

local timeOfDayIcon = Icon.new()
:lock()
:setLabel("Time Of Day")
:setRight()

TimeOfDayEvent.Event:Connect(function(timeOfDay)
	timeOfDayIcon:setLabel(timeOfDay)
end)
