local Players = game:GetService("Players")

local player = Players.LocalPlayer

local doors = {
	workspace.TeamBlue.Boat.LowerDoor,
	workspace.TeamBlue.Boat.UpperDoor,
	workspace.TeamRed.Boat.LowerDoor,
	workspace.TeamRed.Boat.UpperDoor,
}

local COOLDOWN = 3

for _, door in ipairs(doors) do
	local debounce = false
	local handle = door.DoorHandle
	door.Touched:Connect(function(hit)
		if debounce then
			return
		end
		debounce = true
		if hit.Parent.Name == door:GetAttribute("KeyName") then
			-- Only the key holder can pass through the door.
			if Players:GetPlayerFromCharacter(hit.Parent.Parent) == player then
				door.Transparency = 0.5
				door.CanCollide = false
				handle.Transparency = 1
				handle.CanCollide = false
				task.wait(COOLDOWN)
				door.Transparency = 0
				door.CanCollide = true
				handle.Transparency = 0
				handle.CanCollide = true
			end
		end
		debounce = false
	end)
end
