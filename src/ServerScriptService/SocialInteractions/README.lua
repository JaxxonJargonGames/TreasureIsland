--[[
    SocialInteractions
    Version: 1.0.0
    Author: Roblox
    Asset: https://www.roblox.com/library/8207524066
    Documentation: https://developer.roblox.com/resources/developer-modules/dev-module-social-interactions

    The social interaction module aims to enable the creation of immersive and realistic experiences by giving avatars
    subtle but important interactive abilities. This module currently includes the following features:

    *   Body Orientation: makes the head of everyone's avatar face where their corresponding player is pointing their camera
        at, through a mix of neck and waist rotation. This gives players a subtle cue as to who or what someone else is
        currently interacting with.
    *   Chat Emotes: adds some liveliness to the in-game chat by making avatars sometimes play certain emotes depending on the
        content of the messages they sent. The list of "trigger words" that activate each animation is configurable.
    
    Simply inserting the Social Interaction module as described above will enable both the "body orientation" and "chat
    emotes" feature inside your project. Try them out!

    *   By moving your camera, notice how your character bends their waist and turns their neck to look where the camera is
        pointing.
    *   Test out "chat emotes" by typing "Hello, world!" in the chat. In response to that, your character will start waving!
    
	View full documentation here:
		https://developer.roblox.com/resources/developer-modules/dev-module-social-interactions
]]--

--[[
    API Reference:
    This module exposes the following APIs to allow for various configurations and custom interactions. Once the experience
    starts, a `SocialInteractions` ModuleScript will be parented to ReplicatedStorage. To access the following APIs, simply
    require the module as follows (on the client):
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialInteractions = require(ReplicatedStorage:WaitForChild("SocialInteractions"))

--[[
    configure(config: table): nil

    Overrides default configuration keys to change how the Dev Module behaves.

    Throws when trying to set a configuration key that does not exist.

    The possible keys and their default values for the `config` table are:

    	-- Toggle the "body orientation" feature through this parameter
    	useBodyOrientation = true,
    	
    	-- Body orientation uses a mix of waist and neck rotation, use this parameter to determine which of the two is
    	-- prevalent. It should be a number between 0 and 1: 1 means that only the waist rotates, 0 means that only the neck
    	-- rotates. A value of 0.5 performs an even mix of waist and neck rotation.
    	waistOrientationWeight = 0.5,
    	
    	-- Toggle the "chat-triggered emotes" feature through this parameter
    	useChatEmotes = true,
    	
    	-- "Chat emotes" comes with a default list of trigger words. Use this parameter to turn them off if you would rather
    	-- provide your own.
    	 useDefaultTriggerWordsForChatEmotes = true,
]]
-- Example: configures "body orientation" to make waist rotation more pronounced, and disable the "chat emotes" feature
SocialInteractions.configure({
	waistOrientationWeight = 0.75,
	useChatEmotes = false,
})

--[[
    setTriggerWordsForChatAnimation(animationId: string, triggerWords: { string }): nil

    Use this function to register a new animation in the "chat emote" feature. Typing any word included in the
    `triggerWords` list that is passed as an argument will activate the animation whose ID is passed as the first parameter.

    Trigger words support [Lua string patters](https://developer.roblox.com/en-us/articles/string-patterns-reference) for
    detecting multiple combinations of characters in a single word. For instance, using the trigger word `haha[ha]*` will
    activate the corresponding animation for any message that includes, for instance, the words `hahahahahaha`, `haha`,
    `hahaaaaa`, etc.
]]
local animationId = "rbxassetid://3344650532" -- "Wave" animation
-- Typing any of these words in the chat will trigger the above animation
local triggerWords = {"hi", "hello", "good morning"}
SocialInteractions.setTriggerWordsForChatAnimation(animationId, triggerWords)

--[[
    onChatAnimationPlayed(animationId: string, triggerWord: string): RBXScriptSignal

    This client event is fired every time the "chat emotes" feature plays an animation in response to a chat message being
    sent by the local player. It passes down both the ID of the animation that was activated and the corresponding trigger
    word that was detected in the message.
--]]

SocialInteractions.onChatAnimationPlayed:Connect(function(animationId, triggerWord)
	print("Chat animation was played", animationId, triggerWord)
end)