local Players = game:GetService("Players")

local Roact = require(script.Parent.Parent.Packages.Roact)
local ConfigurationContext = require(script.Parent.Parent.Libraries.Configuration).ConfigurationContext
local TeleportToPlayer = require(script.Parent.Parent.Libraries.TeleportToPlayer)
local withCustomGui = require(script.Parent.CustomGui)

local withConfiguration = ConfigurationContext.withConfiguration
local bindableEvents = script.Parent.Parent.BindableEvents

local FriendLocator = Roact.Component:extend("FriendLocator")

local BACKGROUND_COLOR = Color3.new(0.9, 0.9, 0.9)
local THUMBNAIL_URL = "rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"
local CUSTOM_PORTRAIT_NAME = "Portrait"
local CUSTOM_PORTRAIT_CLASS = "ImageLabel"
local CUSTOM_DISPLAY_NAME_NAME = "DisplayName"
local CUSTOM_DISPLAY_NAME_CLASS = "TextLabel"

local function getRootPartFromPlayer(player)
	local character = player and player.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

function FriendLocator:init()
	self.Players = self.props.Players or Players

	function self.onClick()
		local configuration = self.props.configuration
		local playerToTeleport = self.Players.LocalPlayer
		local destinationPlayer = self.Players:GetPlayerByUserId(self.props.userId)

		if configuration.teleportToFriend then
			TeleportToPlayer.teleport(playerToTeleport, destinationPlayer)
		end

		-- Notify that friend indicator is clicked
		local targetRootPart = getRootPartFromPlayer(destinationPlayer)
		bindableEvents.FriendLocatorClicked:Fire(destinationPlayer, targetRootPart.CFrame)
	end

	self.parent = Roact.createRef()
end

function FriendLocator:render()
	self:_renderCustomGui()
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		[Roact.Ref] = self.parent,
	}, {
		ImageButton = Roact.createElement("ImageButton", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			[Roact.Event.Activated] = self.onClick,
		}),

		Content = not self.props.customGui and Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			Border = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = BACKGROUND_COLOR,
			}, {
				Circle = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
			}),

			Portrait = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.9, 0.9),
				Image = string.format(THUMBNAIL_URL, self.props.userId),
				BackgroundColor3 = BACKGROUND_COLOR,
				ZIndex = 2,
			}, {
				Circle = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
			}),

			Tail = Roact.createElement("Frame", {
				Size = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5 + 0.5 / math.sqrt(2)),
				Rotation = 45,
				BorderSizePixel = 0,
				BackgroundColor3 = BACKGROUND_COLOR,
			}),
		}),
	})
end

function FriendLocator:didMount()
	if self.props.customGui then
		local parent = self.parent:getValue()

		self.props.customGui.Parent = parent
	end
end

function FriendLocator:_renderCustomGui()
	local instance = self.props.customGui
	if not instance then
		return
	end

	-- Render portrait included inside custom GUI instance provided
	local portrait = instance:FindFirstChild(CUSTOM_PORTRAIT_NAME, true)
	if portrait and portrait:IsA(CUSTOM_PORTRAIT_CLASS) then
		portrait.Image = string.format(THUMBNAIL_URL, self.props.userId)
	end

	-- Render display name included inside custom GUI instance provided
	local displayName = instance:FindFirstChild(CUSTOM_DISPLAY_NAME_NAME, true)
	if displayName and displayName:IsA(CUSTOM_DISPLAY_NAME_CLASS) then
		local player = self.Players:GetPlayerByUserId(self.props.userId)
		displayName.Text = player.DisplayName
	end
end

return withConfiguration(withCustomGui("FriendLocator")(FriendLocator))
