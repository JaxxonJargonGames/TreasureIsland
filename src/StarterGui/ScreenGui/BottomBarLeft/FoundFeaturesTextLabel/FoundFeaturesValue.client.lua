local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FeatureFoundRemoteEvent = ReplicatedStorage:WaitForChild("FeatureFoundRemoteEvent")

FeatureFoundRemoteEvent.OnClientEvent:Connect(function(count, featureName)
	local textLabel = script.Parent
	local text = "Found Features: " .. tostring(count)
	textLabel.Text = text
end)
