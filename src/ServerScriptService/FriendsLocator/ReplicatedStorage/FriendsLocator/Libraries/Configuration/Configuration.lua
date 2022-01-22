local RunService = game:GetService("RunService")

local createConfiguration = require(script.Parent.createConfiguration)
local serverConfigChanged = script.Parent.serverConfigChanged
local serverConfigRequested = script.Parent.serverConfigRequested

local Configuration = createConfiguration(RunService, serverConfigChanged, serverConfigRequested)

return Configuration
