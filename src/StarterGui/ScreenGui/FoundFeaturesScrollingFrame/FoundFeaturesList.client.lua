local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FeatureFoundRemoteEvent = ReplicatedStorage:WaitForChild("FeatureFoundRemoteEvent")

local function getTextLabel(text)
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 0
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Size = UDim2.new(0, 240, 0, 30)
	textLabel.SizeConstraint = Enum.SizeConstraint.RelativeXY
	textLabel.Text = text
	textLabel.TextColor3 = Color3.new(255, 255, 255)
	textLabel.TextSize = 16
	textLabel.TextStrokeTransparency = 0
	textLabel.Visible = true
	return textLabel
end

FeatureFoundRemoteEvent.OnClientEvent:Connect(function(count, featureName)
	local text = "#" .. tostring(count) .. ": " .. featureName
	local textLabel = getTextLabel(text)
	textLabel.BackgroundColor3 = BrickColor.random().Color
	textLabel.Parent = script.Parent
end)
