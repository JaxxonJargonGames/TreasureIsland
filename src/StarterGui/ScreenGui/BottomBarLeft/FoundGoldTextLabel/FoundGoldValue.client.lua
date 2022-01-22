local Players = game:GetService("Players")

local player = Players.LocalPlayer
local leaderstats = player:WaitForChild("leaderstats")

local function onValueChanged()
	local textLabel = script.Parent
	local text = "Gold: " .. tostring(leaderstats.Gold.Value)
	textLabel.Text = text
end

onValueChanged()

leaderstats.Gold:GetPropertyChangedSignal("Value"):Connect(function()
	onValueChanged()
end)
