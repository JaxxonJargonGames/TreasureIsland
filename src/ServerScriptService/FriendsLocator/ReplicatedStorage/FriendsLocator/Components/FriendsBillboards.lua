local Roact = require(script.Parent.Parent.Packages.Roact)
local Cryo = require(script.Parent.Parent.Packages.Cryo)
local ConfigurationContext = require(script.Parent.Parent.Libraries.Configuration).ConfigurationContext

local withConfiguration = ConfigurationContext.withConfiguration

local FriendsBillboards = Roact.Component:extend("FriendsBillboards")

FriendsBillboards.defaultProps = {
	Players = game:GetService("Players"),
	selectUserIdsByDistance = require(script.Parent.Parent.Modules.selectUserIdsByDistance),
	FriendBillboard = require(script.Parent:WaitForChild("FriendBillboard")),
}

function FriendsBillboards:init()
	self.state = {
		userIds = {},
		distanceFromCamera = {},
	}
end

function FriendsBillboards:render()
	local userIds = self.state.userIds
	local distanceFromCamera = self.state.distanceFromCamera
	local configuration = self.props.configuration
	local selectUserIdsByDistance = self.props.selectUserIdsByDistance
	local FriendBillboard = self.props.FriendBillboard

	if not configuration.enabled then
		return nil
	end

	local selectedUserIds = selectUserIdsByDistance(Cryo.Dictionary.keys(userIds), distanceFromCamera, configuration)
	local isUserShown = {}
	for _, userId in ipairs(selectedUserIds) do
		isUserShown[userId] = true
	end

	local children = {}
	for userId, _ in pairs(self.state.userIds) do
		children[userId] = Roact.createElement(FriendBillboard, {
			userId = userId,
			isShown = isUserShown[userId],
			onDistanceChanged = function(distance)
				self:setState({
					distanceFromCamera = Cryo.Dictionary.join(distanceFromCamera, {
						[userId] = distance,
					}),
				})
			end,
		})
	end

	return Roact.createElement("ScreenGui", { ResetOnSpawn = false }, children)
end

function FriendsBillboards:didMount()
	local Players = self.props.Players

	Players.PlayerAdded:Connect(function(player)
		if self:_shouldDisplay(player) then
			self:setState({
				userIds = Cryo.Dictionary.join(self.state.userIds, {
					[tostring(player.UserId)] = true,
				}),
			})
		end
	end)
	Players.PlayerRemoving:Connect(function(player)
		if self.state.userIds[tostring(player.UserId)] then
			self:setState({
				userIds = Cryo.Dictionary.join(self.state.userIds, {
					[tostring(player.UserId)] = Cryo.None,
				}),
			})
		end
	end)

	self:_updateFriendList()
end

function FriendsBillboards:didUpdate(prevProps)
	local nextConfiguration = self.props.configuration
	local configuration = prevProps.configuration
	if configuration ~= nextConfiguration then
		self:_updateFriendList()
	end
end

function FriendsBillboards:_shouldDisplay(player)
	local Players = self.props.Players
	local configuration = self.props.configuration
	if configuration.showAllPlayers then
		return player ~= Players.LocalPlayer
	end

	local success, isFriendsWith = pcall(function()
		return Players.LocalPlayer:IsFriendsWith(player.UserId)
	end)

	return success and isFriendsWith or false
end

function FriendsBillboards:_updateFriendList()
	local Players = self.props.Players
	local nextUserIds = {}
	for _, player in pairs(Players:GetChildren()) do
		if self:_shouldDisplay(player) then
			nextUserIds[tostring(player.UserId)] = true
		end
	end

	self:setState({ userIds = nextUserIds })
end

return withConfiguration(FriendsBillboards)
