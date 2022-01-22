local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClockTime = require(ReplicatedStorage:WaitForChild("ClockTime"))

local event = Instance.new("RemoteEvent")
event.Name = "ClockTimePauseToggleEvent"
event.OnServerEvent:Connect(function(player)
	if player.userId == game.CreatorId then
		ClockTime.ClockTimePaused = not ClockTime.ClockTimePaused
	end
end)
event.Parent = ReplicatedStorage

local event = Instance.new("RemoteEvent")
event.Name = "ClockTimeAddHourEvent"
event.OnServerEvent:Connect(function(player)
	if player.userId == game.CreatorId then
		local time = game.Lighting.ClockTime + ClockTime.ONE_HOUR
		if time > 24 then
			time -= 24
		end
		game.Lighting.ClockTime = time
	end
end)
event.Parent = ReplicatedStorage

local event = Instance.new("RemoteEvent")
event.Name = "ClockTimeSubtractHourEvent"
event.OnServerEvent:Connect(function(player)
	if player.userId == game.CreatorId then
		local time = game.Lighting.ClockTime - ClockTime.ONE_HOUR
		if time < 0 then
			time += 24
		end
		game.Lighting.ClockTime = time
	end
end)
event.Parent = ReplicatedStorage

local event = Instance.new("RemoteEvent")
event.Name = "ClockTimeAddMinuteEvent"
event.OnServerEvent:Connect(function(player)
	if player.userId == game.CreatorId then
		local time = game.Lighting.ClockTime + ClockTime.ONE_MINUTE
		if time > 24 then
			time -= 24
		end
		game.Lighting.ClockTime = time
	end
end)
event.Parent = ReplicatedStorage
