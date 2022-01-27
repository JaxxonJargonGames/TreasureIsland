local MINIMUM_AGE = 3
local KICK_MESSAGE = "Your account must be at least " .. MINIMUM_AGE .. " days old to play this game."

game.Players.PlayerAdded:Connect(function(player)
    if player.AccountAge < MINIMUM_AGE then
        player:Kick(KICK_MESSAGE)
    end
end)
