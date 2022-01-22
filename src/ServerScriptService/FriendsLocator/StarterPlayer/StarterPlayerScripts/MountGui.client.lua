local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FriendsLocator = ReplicatedStorage:WaitForChild("FriendsLocator")

local Roact = require(FriendsLocator.Packages.Roact)
local FriendsLocatorConfiguration = require(FriendsLocator.Configuration.FriendsLocatorConfiguration)
local ConfigurationContext = require(FriendsLocator.Libraries.Configuration).ConfigurationContext
local FriendsBillboards = require(FriendsLocator.Components.FriendsBillboards)

local ConfigurationProvider = ConfigurationContext.ConfigurationProvider

local player = Players.LocalPlayer

local app = Roact.createElement(ConfigurationProvider, { config = FriendsLocatorConfiguration }, {
	Roact.createElement(FriendsBillboards),
})

Roact.mount(app, player.PlayerGui, "FriendsLocator")
