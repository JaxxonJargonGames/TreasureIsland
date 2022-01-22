local Configuration = require(script.Configuration.FriendsLocatorConfiguration)

local bindableEvents = script.BindableEvents

local FriendsLocator = {
	-- Configurations
	configure = Configuration.configure,

	--[[
		Event that is fired when a friend locator is shown/hidden on the LocalPlayer's screen.

		Callback parameters:
		- player (Player): Player object that the friend locator is adorned to
		- cframe (CFrame): CFrame of the player that the friend locator is being shown for
		- isVisible (boolean): True if the friend locator is visible on the LocalPlayer's screen
	]]
	visibilityChanged = bindableEvents.FriendLocatorVisibilityChanged.Event,

	--[[
		Event that is fired when a friend locator is clicked/activated by the LocalPlayer.

		Callback parameters:
		- player (Player): Player object that the clicked friend locator is adorned to.
		- cframe (CFrame): CFrame of the player that the clicked friend locator is adorned to.
	]]
	clicked = bindableEvents.FriendLocatorClicked.Event,
}

return FriendsLocator
