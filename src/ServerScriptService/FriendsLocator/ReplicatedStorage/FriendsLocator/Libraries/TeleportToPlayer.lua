local RAYCASTS_NUMBER = 10
local MAX_HEIGHT = 100 -- in studs
local DEFAULT_TELEPORT_DISTANCE = 5 -- in studs

local Players = game:GetService("Players")

local TeleportToPlayer = {}

-- Finds an unobstructed spot teleportDistance studs away from destinationCharacter (nil if none found)
function TeleportToPlayer.getCharacterTeleportPoint(destinationCharacter: Model, teleportDistance: number): CFrame
	local rootPart = destinationCharacter and destinationCharacter:FindFirstChild("HumanoidRootPart")
	local humanoid = destinationCharacter and destinationCharacter:FindFirstChild("Humanoid")
	if not rootPart or not humanoid then
		return
	end

	-- Pre-populate ignore list with destinationCharacter in case it's not a player character (ex: NPCs)
	local ignoreList = { destinationCharacter }
	for _, player in ipairs(Players:GetChildren()) do
		table.insert(ignoreList, player.Character)
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = ignoreList

	-- Scan a circular area around the player to find a spot that's not blocked by a wall and has solid ground
	-- below it
	for i = 1, RAYCASTS_NUMBER do
		local rotated = rootPart.CFrame * CFrame.Angles(0, math.pi * 2 * (i / RAYCASTS_NUMBER), 0)
		-- First raycast to check if there is no obstacle in front
		local forwardRaycastResult = workspace:Raycast(rootPart.Position, rotated.LookVector * 5, params)
		if not forwardRaycastResult then
			local forward = rotated + rotated.LookVector * teleportDistance
			-- Second raycast to check if there is ground to stand on
			local downwardRaycastResult = workspace:Raycast(forward.Position, Vector3.new(0, -MAX_HEIGHT, 0), params)
			local position = downwardRaycastResult and downwardRaycastResult.Position
			if position then
				local lookAt = Vector3.new(rootPart.CFrame.X, position.Y, rootPart.CFrame.Z)
				return CFrame.lookAt(position, lookAt)
			end
		end
	end
	return
end

-- Moves playerToTeleport close to destinationPlayer, if possible. Returns wether or not the operation succeeded
function TeleportToPlayer.teleport(playerToTeleport: Player, destinationPlayer: Player, teleportDistance: number)
	teleportDistance = teleportDistance or DEFAULT_TELEPORT_DISTANCE

	local spawnPoint = TeleportToPlayer.getCharacterTeleportPoint(destinationPlayer.Character, teleportDistance)
	if not spawnPoint or not TeleportToPlayer.validate(playerToTeleport, destinationPlayer, spawnPoint) then
		return false
	end

	local rootPart = playerToTeleport.Character and playerToTeleport.Character:FindFirstChild("HumanoidRootPart")
	local humanoid = playerToTeleport.Character and playerToTeleport.Character:FindFirstChild("Humanoid")
	if not rootPart or not humanoid then
		return false
	end

	if humanoid.Sit then -- Un-sits the player, otherwise the seat will be moved as well
		humanoid.Sit = false
		humanoid.Seated:Wait() -- Humanoid.Seated fires when the player stands up, after the seat weld is removed
	end

	-- Inspired from https://developer.roblox.com/en-us/api-reference/property/Humanoid/HipHeight
	local rootPartHeight = humanoid.HipHeight + rootPart.Size.Y / 2
	if humanoid.RigType == Enum.HumanoidRigType.R6 then
		local leg = humanoid.Parent:FindFirstChild("Left Leg") or humanoid.Parent:FindFirstChild("Right Leg")
		if leg then
			rootPartHeight += leg.Size.Y
		end
	end

	rootPart.CFrame = spawnPoint + Vector3.new(0, rootPartHeight, 0)
	return true
end

-- Custom validation function that can be replaced by the developer
function TeleportToPlayer.validate(
	_playerToTeleport: Player,
	_destinationPlayer: Player,
	_teleportPoint: CFrame
): boolean
	return true
end

function TeleportToPlayer.setTeleportationValidator(newValidator)
	assert(typeof(newValidator) == "function", "setTeleportationValidator expects a function as its first argument")
	TeleportToPlayer.validate = newValidator
end

return TeleportToPlayer
