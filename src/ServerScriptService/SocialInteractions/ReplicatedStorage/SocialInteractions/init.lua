local config = require(script.config)
local events = require(script.events)
local ChatEmotes = require(script.Modules.ChatEmotes)

-- Methods and events to expose from the Dev Module.
local module = {
	-- Functions
	configure = config.configure,
	setTriggerWordsForChatAnimation = ChatEmotes.setTriggerWordsForChatAnimation,

	-- Events
	onChatAnimationPlayed = events.onChatAnimationPlayed.Event,
}

return module
