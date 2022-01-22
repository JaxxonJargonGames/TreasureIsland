local Players = game:GetService("Players")

local player = Players.LocalPlayer

local textLabel = script.Parent

local function update()
	local hasJumpingBoots = player:GetAttribute("HasJumpingBoots") or nil -- Hack to fix a Roblox bug.
	if hasJumpingBoots then
		textLabel.Text = "Jumping Boots"
	else
		textLabel.Text = ""
	end
end

update()

player:GetAttributeChangedSignal("HasJumpingBoots"):Connect(update)
