local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FriendsLocator = require(ReplicatedStorage:WaitForChild("FriendsLocator"))

FriendsLocator.configure({
	showAllPlayers = RunService:IsStudio(),  -- Allows for debugging in Studio
	alwaysOnTop = true,
	teleportToFriend = true,
	thresholdDistance = 100,
	maxLocators = 10
})
