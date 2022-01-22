local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.SocialInteractions.Constants)

local updateBodyOrientation: RemoteEvent = ReplicatedStorage.SocialInteractions.UpdateBodyOrientation

updateBodyOrientation.OnServerEvent:Connect(function(player: Player, orientation: Vector2)
	assert(typeof(orientation) == "Vector2", "Expected orientation parameter to be a Vector2")
	if player.Character then
		player.Character:SetAttribute(Constants.BODY_ORIENTATION_ATTRIBUTE, orientation)
	end
end)
