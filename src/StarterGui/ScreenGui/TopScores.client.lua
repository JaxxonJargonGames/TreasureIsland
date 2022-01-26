local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TopScoresRemoteEvent = ReplicatedStorage:WaitForChild("TopScoresRemoteEvent")

local function getTextLabel(text)
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.SourceSans
	textLabel.Size = UDim2.new(0, 500, 0, 50)
	textLabel.SizeConstraint = Enum.SizeConstraint.RelativeXY
	textLabel.Text = text
	textLabel.TextColor3 = Color3.new(255, 255, 255)
	textLabel.TextSize = 24
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Visible = true
	return textLabel
end

TopScoresRemoteEvent.OnClientEvent:Connect(function(topScores)
	frame = script.Parent:WaitForChild("TopScoresScrollingFrame")
	frame:ClearAllChildren()
	layout = Instance.new("VerticalListLayout")
	layout.Parent = frame
	local textLabel = getTextLabel("Top 20 Scores of All Time")
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Size = UDim2.new(0, 500, 0, 50)
	textLabel.TextColor3 = Color3.new(255, 200, 100)
	textLabel.TextSize = 24
	textLabel.TextXAlignment = Enum.TextXAlignment.Center
	textLabel.Parent = script.Parent
	for rank, data in ipairs(topScores) do
		local horizontalFrame = Instance.new("Frame")
		horizontalFrame.BackgroundTransparency = 1
		horizontalFrame.Size = UDim2.new(0, 500, 0, 50)
		horizontalFrame.Parent = script.Parent
		local horizontalListLayout = Instance.new("UIListLayout")
		horizontalListLayout.FillDirection = Enum.FillDirection.Horizontal
		horizontalListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		horizontalListLayout.Parent = horizontalFrame
		local userId = data.key
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Image = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		imageLabel.Size = UDim2.new(0, 50, 0, 50)
		imageLabel.Parent = horizontalFrame
		local padding = Instance.new("TextLabel")
		padding.Size = UDim2.new(0, 20, 0, 50)
		padding.Transparency = 1
		padding.Parent = horizontalFrame
		local name = Players:GetNameFromUserIdAsync(userId)
		local gold = data.value
		local text = name .. " is #" .. rank .. " with " .. gold .. " gold pieces"
		local textLabel = getTextLabel(text)
		textLabel.Parent = horizontalFrame
	end
end)
