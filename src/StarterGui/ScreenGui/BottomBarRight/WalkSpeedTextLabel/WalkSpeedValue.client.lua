local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:wait()
local humanoid = character:WaitForChild("Humanoid")

local textLabel = script.Parent

local function update()
	textLabel.Text = "Walk Speed: " .. tostring(humanoid.WalkSpeed)
end

update()

humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
	update()
end)
