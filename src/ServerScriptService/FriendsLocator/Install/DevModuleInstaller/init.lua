--!strict
local events = require(script.events)
local install = require(script.install)

local DevModuleInstaller: { [string]: any } = {
	verboseLogging = false,
	pruneDevelopmentFiles = true,

	started = events.started.Event,
	finished = events.finished.Event,
}

function DevModuleInstaller.install(devModule: Folder)
	return install(devModule, {
		verboseLogging = DevModuleInstaller.verboseLogging,
		pruneDevelopmentFiles = DevModuleInstaller.pruneDevelopmentFiles,
	})
end

return DevModuleInstaller
