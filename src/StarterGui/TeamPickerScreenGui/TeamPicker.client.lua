local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local ChooseTeamRemoteEvent = ReplicatedStorage:WaitForChild("ChooseTeamRemoteEvent")
local PlayerEnterRemoteEvent = ReplicatedStorage:WaitForChild("PlayerEnterRemoteEvent")

local IconController = require(ReplicatedStorage.Icon.IconController)

local outerFrame = script.Parent:WaitForChild("Frame")
local innerFrame = outerFrame:WaitForChild("Frame")

outerFrame.Visible = false

local blur = Instance.new("BlurEffect")
blur.Parent = game:GetService("Lighting")
blur.Enabled = false

local BLUE_TEAM = "Really blue"
local RED_TEAM = "Really red"

local function choose()
	blur.Enabled = false
	outerFrame.Visible = false
	--IconController.setTopbarEnabled(true)
	--StarterGui:SetCore("TopbarEnabled", true) -- Not working for some reason.
end

local function playerEnter()
	blur.Enabled = true
	outerFrame.Visible = true
	--IconController.setTopbarEnabled(false)
	--StarterGui:SetCore("TopbarEnabled", false) -- Works, but enabling is not working.
end

innerFrame.BlueTextButton.MouseButton1Click:Connect(function()
	ChooseTeamRemoteEvent:FireServer(BrickColor.new(BLUE_TEAM))
	choose()
end)

innerFrame.RedTextButton.MouseButton1Click:Connect(function()
	ChooseTeamRemoteEvent:FireServer(BrickColor.new(RED_TEAM))
	choose()
end)

PlayerEnterRemoteEvent.OnClientEvent:Connect(function(player)
	playerEnter()
end)
