local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BodyOrientation = require(ReplicatedStorage.SocialInteractions.Modules.BodyOrientation)
local ChatEmotes = require(ReplicatedStorage.SocialInteractions.Modules.ChatEmotes)
local config = require(ReplicatedStorage.SocialInteractions.config)

function onConfigChanged(values)
	if values.useBodyOrientation then
		BodyOrientation.enable()
	else
		BodyOrientation.disable()
	end

	if values.useChatEmotes then
		ChatEmotes.enable()
	else
		ChatEmotes.disable()
	end
end

config.changed:Connect(onConfigChanged)
onConfigChanged(config.initialValues)
