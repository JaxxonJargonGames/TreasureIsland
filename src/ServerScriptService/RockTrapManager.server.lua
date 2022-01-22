local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")

local boulderTemplate = ServerStorage:WaitForChild("Boulder")

local random = Random.new(tick())

local function getBoulder()
	local boulder = boulderTemplate:Clone()
	boulder.Anchored = false
	local x = random:NextInteger(0, 10)
	local y = random:NextInteger(0, 10)
	local z = random:NextInteger(0, 10)
	boulder.Size += Vector3.new(x, y, z)
	local debounce = false
	boulder.Touched:Connect(function(hit)
		if debounce then
			return
		end
		debounce = true
		local parent = hit.Parent
		local humanoid = parent:FindFirstChildWhichIsA("Humanoid")
		-- If the boulder is moving more that a slight amount it will kill the humanoid.
		local alv = boulder.AssemblyLinearVelocity
		if humanoid then
			if alv.X < -0.1 or alv.X > 0.1 or alv.Y < -0.1 or alv.Y > 0.1 or alv.Z < -0.1 or alv.Z > 0.1 then
				humanoid.Health = 0 -- Player dies even if they have a force field.
			end
		end
		task.wait(2)
		debounce = false
	end)
	-- Use the properties for granite per https://robloxapi.github.io/ref/type/PhysicalProperties.html
	local density = 10
	local friction = 0.8
	local elasticity = 0.2
	local frictionWeight = 1
	local elasticityWeight = 1
	local physicalProperties = PhysicalProperties.new(density, friction, elasticity, frictionWeight, elasticityWeight)
	boulder.CustomPhysicalProperties = physicalProperties
	return boulder
end

local function getBoulderCrashSound()
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://5618365929" -- Boulder crashing.
	sound.Volume = 5
	return sound
end

-- Setup all rock traps.
for _, trap in ipairs(workspace.RockTraps:GetChildren()) do
	local debounce = false
	local rockSpawn = trap:FindFirstChild("RockSpawn")
	local trigger = trap:FindFirstChild("Trigger")
	trigger.Transparency = 1
	trigger.Touched:Connect(function(hit)
		if debounce then
			return
		end
		if hit.Parent:FindFirstChild("Humanoid") then
			debounce = true
			local boulder = getBoulder()
			boulder.Position = rockSpawn.Position
			boulder.Parent = workspace
			local sound = getBoulderCrashSound()
			sound.Parent = boulder
			sound:Play()
			sound.Parent = SoundService
			task.wait(2)
			debounce = false
		end
	end)
end
