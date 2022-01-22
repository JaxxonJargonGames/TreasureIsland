local Cryo = require(script.Parent.Parent.Packages.Cryo)

--[[
	Determines which locators to show based on (in order of priority):
	1. Distance from users, and
	2. Total number of indicators to show

	Parameters:
	- userIds (table): list of user IDs for all candidate players
	- distanceFromCamera (table):
		Key (string): Stringified Player.UserId
		Value (number): Magnitude of how far the player is from the LocalPlayer's camera
	- configuration (table): Configuration table for the dev module

	Returns:
	- userIds (table): list of user IDs to display the friendship locator for.
]]
local function selectUserIdsByDistance(userIds, distanceFromCamera, configuration)
	-- Sort the players according to the distance to you
	local sortedByDistance = Cryo.List.sort(userIds, function(a, b)
		local distance1 = distanceFromCamera[a] or math.huge
		local distance2 = distanceFromCamera[b] or math.huge

		return distance1 < distance2
	end)

	-- Limit the total number of indicators
	local res = {}
	for _, userId in ipairs(sortedByDistance) do
		if #res >= configuration.maxLocators then
			break
		end

		local distance = distanceFromCamera[userId] or 0
		if distance > configuration.thresholdDistance then
			table.insert(res, userId)
		end
	end

	return res
end

return selectUserIdsByDistance
