local RunService = game:GetService("RunService")
local Otter = require(script.Parent.Parent.Packages.Otter)
local Constants = require(script.Parent.Parent.Constants)
local config = require(script.Parent.Parent.config)

local ATTRIBUTE = Constants.BODY_ORIENTATION_ATTRIBUTE

local updateBodyOrientation: RemoteEvent = script.Parent.Parent.UpdateBodyOrientation

-- Class that provides body orientation functionality to a given rig
local OrientableBody = {}
OrientableBody.__index = OrientableBody

local function waitForDescendantWhichIsA(parent: Instance, name: string, className: string)
	for _, descendant in ipairs(parent:GetDescendants()) do
		if descendant.Name == name and descendant:IsA(className) then
			return descendant
		end
	end
	while true do
		local descendant = parent.DescendantAdded:Wait()
		if descendant.Name == name and descendant:IsA(className) then
			return descendant
		end
	end
end

function OrientableBody.new(character: Model)
	local self = {}
	self.character = character

	task.spawn(function()
		self.neck = waitForDescendantWhichIsA(character, "Neck", "Motor6D")
		self.waist = waitForDescendantWhichIsA(character, "Waist", "Motor6D")
	end)

	self.motor = Otter.createGroupMotor({
		horizontalAngle = 0,
		verticalAngle = 0,
	})
	self.motor:onStep(function(values)
		local waistWeight = config.getValues().waistOrientationWeight
		local neckWeight = 1 - waistWeight
		self:applyAngle(self.neck, values.horizontalAngle * neckWeight, values.verticalAngle * neckWeight)
		self:applyAngle(self.waist, values.horizontalAngle * waistWeight, values.verticalAngle * waistWeight)
	end)

	return setmetatable(self, OrientableBody)
end

function OrientableBody:applyAngle(joint, horizontalAngle, verticalAngle)
	if not joint then
		return
	end

	local horizontalRotation = CFrame.Angles(0, horizontalAngle, 0)
	local verticalRotation = CFrame.Angles(verticalAngle, 0, 0)
	joint.C0 = CFrame.new(joint.C0.Position) * horizontalRotation * verticalRotation
end

-- Changes the body orientiation to make it face a given direction. Returns the computed angles
function OrientableBody:face(direction: Vector3): Vector2?
	local humanoid: Humanoid? = self.character and self.character:FindFirstChild("Humanoid")
	if not humanoid or not humanoid.RootPart then
		return nil
	end

	direction = humanoid.RootPart.CFrame:PointToObjectSpace(humanoid.RootPart.Position + direction)

	local verticalAngle = math.asin(direction.Y)
	if verticalAngle < Constants.OFFSET_Y and verticalAngle > -Constants.OFFSET_Y then
		-- Vertical angle is within dead zone, do not change head orientation
		verticalAngle = 0
	else
		if verticalAngle > 0 then
			verticalAngle = verticalAngle - Constants.OFFSET_Y
		else
			verticalAngle = verticalAngle + Constants.OFFSET_Y
		end
	end

	local horizontalAngle = math.atan2(-direction.X, -direction.Z)
	-- If looking behind the character, it will instead rotate towards the camera
	if horizontalAngle > math.pi / 2 then
		horizontalAngle = math.pi - horizontalAngle
	elseif horizontalAngle < -math.pi / 2 then
		horizontalAngle = -math.pi - horizontalAngle
	end

	self.motor:setGoal({
		horizontalAngle = Otter.spring(horizontalAngle),
		verticalAngle = Otter.spring(verticalAngle),
	})

	return Vector2.new(horizontalAngle, verticalAngle)
end

-- Continuously compute a new body orientation to face the camera, and notify the server for replication
-- Intended to be used for the local player's character
function OrientableBody:useCameraAsSource()
	local timeSinceLastSync = 0
	self.renderStepConnection = RunService.RenderStepped:Connect(function(delta)
		local camera = workspace.CurrentCamera
		if not camera then
			return
		end

		local orientation = self:face(camera.CFrame.LookVector)

		timeSinceLastSync += delta
		if timeSinceLastSync > Constants.SYNC_INTERVAL and orientation then
			timeSinceLastSync %= Constants.SYNC_INTERVAL
			updateBodyOrientation:FireServer(orientation)
		end
	end)
end

-- Read the current body orientation angle as an attribute from the server, and use it to orient the character
function OrientableBody:orientFromAttribute()
	local value: Vector2 = self.character:GetAttribute(ATTRIBUTE)
	if value then
		self.motor:setGoal({
			horizontalAngle = Otter.spring(value.X),
			verticalAngle = Otter.spring(value.Y),
		})
	end
end

-- Use the character attribute (updated by the server) as the source of truth for body orientation
-- Intended to be used for replicated characters
function OrientableBody:useAttributeAsSource()
	self:orientFromAttribute()
	self.attributeConnection = self.character:GetAttributeChangedSignal(ATTRIBUTE):Connect(function()
		self:orientFromAttribute()
	end)
end

function OrientableBody:destroy()
	self:applyAngle(self.neck, 0, 0)
	self:applyAngle(self.waist, 0, 0)

	if self.motor then
		self.motor:destroy()
		self.motor = nil
	end
	if self.attributeConnection then
		self.attributeConnection:Disconnect()
		self.attributeConnection = nil
	end
	if self.renderStepConnection then
		self.renderStepConnection:Disconnect()
		self.renderStepConnection = nil
	end
end

return OrientableBody
