local t = require(script.Parent.Parent.Packages.t)
local Configuration = require(script.Parent.Parent.Libraries.Configuration).Configuration

local initialValues = {
	-- Sets BillboardGui on top of everything (prevents locator from being blocked by 3D world objects)
	alwaysOnTop = true,

	-- Shows locators for all players, not just friends
	showAllPlayers = false,

	-- Will reposition user to friend's location if set to true
	teleportToFriend = true,

	-- Shows locators when players are farther than this threshold
	thresholdDistance = 100,

	-- Number of locators shown at a single time will be limited to these
	maxLocators = 10,

	-- Boolean flag to toggle the Dev Module on/off
	enabled = true,

	-- Size of locator (this is the size of the BillboardGui)
	locatorSize = UDim2.new(0, 50, 0, 50),
}

local validator = t.strictInterface({
	alwaysOnTop = t.optional(t.boolean),
	showAllPlayers = t.optional(t.boolean),
	teleportToFriend = t.optional(t.boolean),
	thresholdDistance = t.optional(t.numberPositive),
	maxLocators = t.optional(t.numberPositive),
	enabled = t.optional(t.boolean),
	locatorSize = t.optional(t.UDim2),
})

local FriendsLocatorConfiguration = Configuration.new("FriendsLocatorConfiguration", initialValues, validator)

return FriendsLocatorConfiguration
