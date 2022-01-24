local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:wait()
local humanoid = character:WaitForChild("Humanoid")

local textLabel = script.Parent

local function update()
	textLabel.Text = "Jump Power: " .. tostring(humanoid.JumpPower)
end

update()

humanoid:GetPropertyChangedSignal("JumpPower"):Connect(update)
