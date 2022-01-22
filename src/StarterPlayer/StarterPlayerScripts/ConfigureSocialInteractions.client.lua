local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialInteractions = require(ReplicatedStorage:WaitForChild("SocialInteractions"))

-- Register string pattern for the "Tilt" animation
SocialInteractions.setTriggerWordsForChatAnimation("rbxassetid://3334538554", {"cra+zy"})

-- Register additional string pattern for the "Applaud" animation
SocialInteractions.setTriggerWordsForChatAnimation("rbxassetid://5911729486", {"coo+l"})
