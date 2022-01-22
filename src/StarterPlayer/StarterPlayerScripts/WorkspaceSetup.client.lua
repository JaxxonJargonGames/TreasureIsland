local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Teams = game:GetService("Teams")

local GoldFoundRemoteEvent = ReplicatedStorage:WaitForChild("GoldFoundRemoteEvent")

player = Players.LocalPlayer

local function getCoinSound()
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://631557324"
	sound.Volume = 7
	return sound
end

local function getNatureSound()
	local natureSound = Instance.new("Sound")
	natureSound.Looped = true
	natureSound.RollOffMinDistance = 30
	natureSound.RollOffMaxDistance = 100
	natureSound.SoundId = "rbxassetid://169736440" -- ForestAmbienceVar2 (birds chirping, etc.)
	natureSound.Volume = 3
	return natureSound
end

local function getSpikeTrapHitbox(trap)
	local hitbox = Instance.new("Part")
	local orientation, size = trap:GetBoundingBox()
	hitbox.Anchored = true
	hitbox.CanCollide = false
	hitbox.CanTouch = true
	hitbox.CFrame = orientation
	hitbox.Size = size + Vector3.new(3, 3, 3)
	hitbox.Transparency = 1
	local debounce = false
	hitbox.Touched:Connect(function(hit)
		if debounce then
			return
		end
		debounce = true
		for _, part in ipairs(trap:GetChildren()) do
			part.Position += Vector3.new(0, 10, 0)
		end
		local parent = hit.Parent
		local humanoid = parent:FindFirstChildWhichIsA("Humanoid")
		if humanoid then
			humanoid.Health = 0 -- Player dies even if they have a force field.
		end
		task.wait(2)
		hitbox.CanTouch = false
		-- Remove the spike trap from minimap.
		CollectionService:RemoveTag(hitbox, "SpikeTrap")
		-- Commented out the code below to leave the trap in place after it was tripped.
		--for _, part in ipairs(trap:GetChildren()) do
		--	part.Position += Vector3.new(0, -10, 0)
		--end
		--debounce = false
	end)
	return hitbox
end

-- Setup all biome features.
for _, biomeFolder in ipairs(workspace.Biomes:GetChildren()) do
	for _, feature in ipairs(biomeFolder:GetChildren()) do
		if feature:IsA("Model") then
			-- Attach the nature sound to a part within the feature model.
			local natureSound = getNatureSound()
			natureSound.Parent = feature:FindFirstChildWhichIsA("BasePart")
			natureSound:Play() -- Birds chirping, etc.
		end
	end
end

-- Setup hidden gold objects.
for _, gold in ipairs(workspace.Gold.Hidden:GetChildren()) do
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MouseClick:connect(function()
		GoldFoundRemoteEvent:FireServer(gold)
		local coinSound = getCoinSound()
		coinSound.Parent = gold
		coinSound:Play()
		coinSound.Parent = SoundService
		-- Remove the gold from minimap.
		CollectionService:RemoveTag(gold, "Gold")
	end)
	clickDetector.Parent = gold
	if player.UserId == game.CreatorId or game.CreatorId == 0 then
		-- Tagged for the minimap.
		CollectionService:AddTag(gold, "Gold")
	end
end

GoldFoundRemoteEvent.OnClientEvent:Connect(function(goldName)
	local gold = workspace.Gold.Hidden:FindFirstChild(goldName)
	gold.Transparency = 1
	gold.CanCollide = false
	gold.Parent = workspace.Gold.Found
end)

-- Setup and tag all spike traps.
for _, trap in ipairs(workspace.SpikeTraps:GetChildren()) do
	local hitbox = getSpikeTrapHitbox(trap)
	hitbox.Parent = workspace
	-- Tagged for the minimap.
	CollectionService:AddTag(hitbox, "SpikeTrap")
end

