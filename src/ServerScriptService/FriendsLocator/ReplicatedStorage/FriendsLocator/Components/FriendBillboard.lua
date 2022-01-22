local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Roact = require(script.Parent.Parent.Packages.Roact)
local ConfigurationContext = require(script.Parent.Parent.Libraries.Configuration).ConfigurationContext
local FriendLocator = require(script.Parent:WaitForChild("FriendLocator"))
local withCustomGui = require(script.Parent.CustomGui)

local e = Roact.createElement
local bindableEvents = script.Parent.Parent.BindableEvents
local withConfiguration = ConfigurationContext.withConfiguration

local FriendBillboard = Roact.Component:extend("FriendBillboard")

FriendBillboard.defaultProps = {
	isShown = false,
	Players = Players,
	camera = workspace.CurrentCamera,
}

local function getRootPartFromPlayer(player)
	local character = player and player.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

function FriendBillboard:init()
	local player = self.props.Players:GetPlayerByUserId(self.props.userId)
	self.state = {
		adornee = getRootPartFromPlayer(player),
	}

	self.characterConn = player.CharacterAdded:Connect(function(character)
		self:setState({ adornee = character:WaitForChild("HumanoidRootPart") })
	end)

	self.getBillboardGuiSize = function()
		if self.props.customGui then
			local size = self.props.customGui.Size
			local x, y = size.X, size.Y

			return UDim2.new(0, x.Offset, 0, y.Offset)
		end

		return self.props.configuration.locatorSize
	end
end

function FriendBillboard:render()
	local configuration = self.props.configuration
	local isShown = self.props.isShown

	-- Parent component can control whether to show this BillboardGui based on
	-- other factors (sorting based on distance, clustering etc.)
	if not isShown then
		return nil
	end

	return e("BillboardGui", {
		Size = self.getBillboardGuiSize(),
		Adornee = self.state.adornee,
		SizeOffset = Vector2.new(0, 0.75),
		StudsOffsetWorldSpace = Vector3.new(0, 1.5, 0),
		Active = true,
		AlwaysOnTop = configuration.alwaysOnTop,
	}, {
		FriendLocator = e(FriendLocator, {
			userId = self.props.userId,
		}),
	})
end

function FriendBillboard:didMount()
	self.previousDistance = nil

	-- Need to use a loop because property changed signals don't work on Position
	self.heartbeatConn = RunService.Heartbeat:Connect(function()
		local adorneePart = self.state.adornee
		local onDistanceChanged = self.props.onDistanceChanged
		local camera = self.props.camera

		if camera and adorneePart then
			local distance = (camera.CFrame.Position - adorneePart.Position).Magnitude

			-- Fire callback with distance to parent component
			if distance ~= self.previousDistance and onDistanceChanged then
				onDistanceChanged(distance)
			end

			self.previousDistance = distance
		end
	end)
end

function FriendBillboard:didUpdate(prevProps)
	local isShown = self.props.isShown
	if prevProps.isShown ~= isShown then
		-- Notify that friend locator is shown/hidden
		local adorneePart = self.state.adornee
		local player = self.props.Players:GetPlayerByUserId(self.props.userId)

		local visibilityChangedEvent = self.props.visibilityChangedEvent
			or bindableEvents.FriendLocatorVisibilityChanged
		visibilityChangedEvent:Fire(player, adorneePart.CFrame, isShown)
	end
end

function FriendBillboard:willUnmount()
	if self.characterConn then
		self.characterConn:Disconnect()
		self.characterConn = nil
	end
	if self.heartbeatConn then
		self.heartbeatConn:Disconnect()
		self.heartbeatConn = nil
	end
end

return withConfiguration(withCustomGui("FriendLocator")(FriendBillboard))
