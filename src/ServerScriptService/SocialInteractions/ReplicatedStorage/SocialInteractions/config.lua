local t = require(script.Parent.Packages.t)
local Configuration = require(script.Parent.Libraries.Configuration).Configuration

local initialValues = {
	-- Toggle the "body orientation" feature through this parameter
	useBodyOrientation = true,

	-- Body orientation uses a mix of waist and neck rotation, use this parameter
	-- to determine which of the two is prevalent. It should be a number between
	-- 0 and 1: 1 means that only the waist rotates, 0 means that only the neck
	-- rotates. A value of 0.5 performs an even mix of waist and neck rotation.
	waistOrientationWeight = 0.5,

	-- Toggle the "chat-triggered emotes" feature through this parameter
	useChatEmotes = true,

	-- "Chat emotes" comes with a default list of trigger words. Use this
	-- parameter to turn them off if you would rather
	-- provide your own.
	useDefaultTriggerWordsForChatEmotes = true,
}
local validator = t.strictInterface({
	useBodyOrientation = t.optional(t.boolean),
	waistOrientationWeight = t.optional(t.number),
	useChatEmotes = t.optional(t.boolean),
	useDefaultTriggerWordsForChatEmotes = t.optional(t.boolean),
})

local config = Configuration.new("SocialInteractions", initialValues, validator)

return config
