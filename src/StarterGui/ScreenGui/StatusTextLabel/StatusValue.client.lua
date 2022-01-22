local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local ChooseTeamRemoteEvent = ReplicatedStorage:WaitForChild("ChooseTeamRemoteEvent")
local FeatureFoundRemoteEvent = ReplicatedStorage:WaitForChild("FeatureFoundRemoteEvent")
local StatusRemoteEvent = ReplicatedStorage:WaitForChild("StatusRemoteEvent")

local Typewriter = require(ReplicatedStorage:WaitForChild("Typewriter"))

local DELAY_BETWEEN_CHARS = 0.025
local MESSAGE_WAIT_TIME = 0.2

local featureCount = 0
local label = script.Parent

-- Load translator if game is localized
--AnimateUI.loadTranslator()

local function displayStatus(messages)
	label.Visible = true
	for _, message in pairs(messages) do
		Typewriter.typeWrite(label, message, DELAY_BETWEEN_CHARS)
		task.wait(MESSAGE_WAIT_TIME)
	end
	label.Visible = false
end

StatusRemoteEvent.OnClientEvent:Connect(function(messages)
	displayStatus(messages)
end)

local intro = {
	[[Welcome to Jaxxon Jargon's<br /><font size="46" color="rgb(255,50,25)">Treasure Island</font> <font size="40">🗡</font>]],
}

local messages = {
	
	[[Your first objective is to find <font color="rgb(255,200,50)">gold!</font><br />Your second objective is to go shopping<br />for weapons and other useful items.]],
}

ChooseTeamRemoteEvent.OnClientEvent:Connect(function()
	displayStatus(intro)
	if featureCount < 5 then
		displayStatus(messages)
	end
end)

FeatureFoundRemoteEvent.OnClientEvent:Connect(function(count, featureName)
	featureCount = count
end)
