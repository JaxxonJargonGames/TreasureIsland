local ReplicatedFirst = game:GetService("ReplicatedFirst")

local ElapsedTimeEvent = ReplicatedFirst:WaitForChild("ElapsedTimeEvent")

local startTime = os.clock()

while true do
	local elapsedTime = os.clock() - startTime
	elapsedTime = math.round(elapsedTime)
	ElapsedTimeEvent:Fire(elapsedTime)
	task.wait(0.5)
end
