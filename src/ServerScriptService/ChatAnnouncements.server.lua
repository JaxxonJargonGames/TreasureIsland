local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local GoldFoundRemoteEvent = ReplicatedStorage:WaitForChild("GoldFoundRemoteEvent")
local PlayerKilledEvent = ServerStorage:WaitForChild("PlayerKilledEvent")

local ChatService = require(ServerScriptService:WaitForChild("ChatServiceRunner"):WaitForChild("ChatService"))

if not ChatService:GetChannel("All") then
	while task.wait(0.1) do
		local channelName = ChatService.ChannelAdded:Wait()
		if channelName == "All" then
			break
		end
	end
end

local scoreAnnouncer = ChatService:AddSpeaker("Score!")
scoreAnnouncer:JoinChannel("All")
scoreAnnouncer:SetExtraData("NameColor", Color3.fromRGB(255, 255, 255))
scoreAnnouncer:SetExtraData("ChatColor", Color3.fromRGB(255, 255, 255))

GoldFoundRemoteEvent.OnServerEvent:Connect(function(player, gold)
	local goldValue = gold:GetAttribute("GoldValue")
	local message = player.DisplayName .. " found " .. tostring(goldValue) .. " pieces of gold!"
	scoreAnnouncer:SayMessage(message, "All")
end)

PlayerKilledEvent.Event:Connect(function(target, dealer)
	local message = target.DisplayName .. " was killed by " .. dealer.DisplayName
	scoreAnnouncer:SayMessage(message, "All")
	local stolenGold = math.round(target.leaderstats.Gold.Value / 2)
	local message = dealer.DisplayName .. " stole " .. tostring(stolenGold) .. " pieces of gold!"
	scoreAnnouncer:SayMessage(message, "All")
end)
