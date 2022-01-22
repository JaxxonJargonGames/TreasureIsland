local Players = game:GetService("Players")
local OrientableBody = require(script.Parent.OrientableBody)

local BodyOrientation = {}

local orientableBodies: { [Player]: typeof(OrientableBody.new()) } = {}
local characterAddedConnections: { [Player]: RBXScriptConnection } = {}
local characterRemovingConnections: { [Player]: RBXScriptConnection } = {}
local playerAddedConnection: RBXScriptConnection
local playerRemovingConnection: RBXScriptConnection
local enabled = false

-- Sets up an OrientableBody for the given player
local function onCharacterAdded(player: Player, character: Model)
	local body = OrientableBody.new(character)
	orientableBodies[player] = body

	if character == Players.LocalPlayer.Character then
		body:useCameraAsSource()
	else
		body:useAttributeAsSource()
	end
end

-- Listen for player's character events and create/destroy an associated OrientableBody
local function onPlayerEntered(player: Player)
	if player.Character then
		onCharacterAdded(player, player.Character)
	end

	characterAddedConnections[player] = player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)

	characterRemovingConnections[player] = player.CharacterRemoving:Connect(function()
		if orientableBodies[player] then
			orientableBodies[player]:destroy()
			orientableBodies[player] = nil
		end
	end)
end

-- Clear orientable body event listeners for a given player
local function onPlayerRemoving(player)
	if orientableBodies[player] then
		orientableBodies[player]:destroy()
		orientableBodies[player] = nil
	end
	if characterAddedConnections[player] then
		characterAddedConnections[player]:Disconnect()
		characterAddedConnections[player] = nil
	end
	if characterRemovingConnections[player] then
		characterRemovingConnections[player]:Disconnect()
		characterRemovingConnections[player] = nil
	end
end

-- Turns on body orientation. Developer-facing.
function BodyOrientation.enable()
	if enabled then
		return
	end

	playerRemovingConnection = Players.PlayerRemoving:Connect(onPlayerRemoving)
	playerAddedConnection = Players.PlayerAdded:Connect(onPlayerEntered)
	for _, player in ipairs(Players:GetChildren()) do
		onPlayerEntered(player)
	end

	enabled = true
end

-- Turns off body orientation. Developer-facing.
function BodyOrientation.disable()
	if not enabled then
		return
	end

	playerAddedConnection:Disconnect()
	playerRemovingConnection:Disconnect()
	for _, player in ipairs(Players:GetChildren()) do
		onPlayerRemoving(player)
	end

	enabled = false
end

return BodyOrientation
