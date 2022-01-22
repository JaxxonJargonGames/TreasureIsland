--!strict
local events = require(script.Parent.events)
local constants = require(script.Parent.constants)

local useVerboseLogging = false

local function log(messageType: string, message: string)
	if useVerboseLogging then
		print(("[%s] %s"):format(messageType, message))
	end
end

-- Reparents an instance and outputs helpful logging information so we can see
-- where instances are going at runtime.
local function move(instance: Instance, newParent: Instance)
	instance.Parent = newParent
	log("move", ("%s -> %s"):format(instance.Name, instance:GetFullName()))
end

-- Gets the storage location for packages used by each Dev Modules. The packages
-- that get put in this folder are deduplicated so every distinct version of a
-- package has only one copy.
local function getPackageStorage(): Folder
	local packageStorage = constants.PACKAGE_STORAGE_LOCATION:FindFirstChild(constants.PACKAGE_STORAGE_NAME) :: Folder

	if not packageStorage then
		packageStorage = Instance.new("Folder")
		packageStorage.Name = constants.PACKAGE_STORAGE_NAME
		packageStorage.Parent = constants.PACKAGE_STORAGE_LOCATION
	end

	return packageStorage
end

-- Prunes any stories and test files that are included with the DevModule. These
-- are not needed at runtime.
local function prune(instance: Instance)
	for _, descendant in ipairs(instance:GetDescendants()) do
		local name = descendant.Name
		if name:match("%.story$") or name:match("%.spec$") then
			descendant:Destroy()
		end
	end
end

local function getPackageVersion(package: ModuleScript): string
	local version = package:FindFirstChild(constants.PACKAGE_VERSION_NAME)

	assert(
		version and version:IsA("StringValue"),
		constants.PACKAGE_VERSION_OBJECT_MISSING:format(
			package.Name,
			constants.PACKAGE_VERSION_NAME,
			package:GetFullName()
		)
	)
	assert(version.Value ~= "", constants.PACKAGE_VERSION_EMPTY:format(package.Name, version:GetFullName()))

	return version.Value
end

-- This function merges the Packages folder from a DevModule into a shared
-- location. Until we have an improved package implementation, we need to
-- manually dedupe our libraries to cut down on bloat
local function dedupePackages(packages: Instance)
	local packageStorage = getPackageStorage()

	for _, package in ipairs(packages:GetChildren()) do
		if package ~= script and package:IsA("ModuleScript") then
			local version = getPackageVersion(package)

			local existingVersion: ModuleScript
			for _, otherPackage in ipairs(packageStorage:GetChildren()) do
				if otherPackage.Name:match(("^%s_"):format(package.Name)) and otherPackage:IsA("ModuleScript") then
					if version == getPackageVersion(otherPackage) then
						existingVersion = otherPackage
						break
					end
				end
			end

			if not existingVersion then
				local clone = package:Clone() :: ModuleScript
				clone.Parent = packageStorage
				clone.Name = ("%s_%s"):format(clone.Name, version)
				existingVersion = clone
			end

			-- Link the package with the existing version (which was either
			-- there previously, or is the one we just generated)
			local packageRef = constants.PACKAGE_REF:Clone()
			packageRef.Name = package.Name

			local packageObject = packageRef:FindFirstChild("package")
			if packageObject and packageObject:IsA("ObjectValue") then
				packageObject.Value = existingVersion
			end
			packageRef.Parent = package.Parent

			package:Destroy()

			log("link", ("%s <-> %s"):format(package.Name, existingVersion:GetFullName()))
		end
	end
end

-- Takes an instance and overlays it on top of a parent. This is used for
-- overlaying a DevModule's DataModel-based layout on top of existing services.
local function overlay(instance: Instance, parent: Instance)
	for _, child in ipairs(instance:GetChildren()) do
		local existingChild = parent:FindFirstChild(child.Name)

		if existingChild and child.ClassName == "Folder" then
			overlay(child, existingChild)
		else
			move(child, parent)
		end
	end
end

-- Gathers up all the scripts in the DevModule. We use the resulting array to
-- enable all scripts in one step.
local function getDevModuleScripts(devModule: Instance): { BaseScript }
	local scripts = {}
	for _, descendant in ipairs(devModule:GetDescendants()) do
		if descendant.Parent == devModule then
			continue
		end

		if descendant:IsA("Script") or descendant:IsA("LocalScript") then
			table.insert(scripts, descendant)
		end
	end
	return scripts
end

-- Ensures that all scripts included with a DevModule are marked as Disabled.
-- This makes sure there are no race conditions resulting in the Install script
-- running after the scripts included with the module.
local function assertScriptsAreDisabled(devModuleScripts: { BaseScript })
	local enabledScripts = {}

	for _, devModuleScript in ipairs(devModuleScripts) do
		if not devModuleScript.Disabled then
			table.insert(enabledScripts, devModuleScript.Name)
		end
	end

	if #enabledScripts > 0 then
		error(constants.ENABLED_SCRIPTS_ERROR:format(table.concat(enabledScripts, ", ")))
	end
end

type Options = { verboseLogging: boolean?, pruneDevelopmentFiles: boolean? }

local defaultOptions: Options = {
	verboseLogging = false,
	pruneDevelopmentFiles = true,
}

local function install(devModule: Instance, options: Options?)
	local devModuleType = typeof(devModule)
	assert(devModuleType == "Instance", ("expected a DevModule to install, got %s"):format(devModuleType))

	assert(devModule.Parent, ("%s must be parented to be installed"):format(devModule.Name))

	local mergedOptions = defaultOptions
	for key, value in pairs(options or {}) do
		mergedOptions[key] = value
	end

	if mergedOptions.verboseLogging then
		useVerboseLogging = mergedOptions.verboseLogging
	end

	events.started:Fire()

	log("info", ("Installing %s from %s..."):format(devModule.Name, devModule.Parent.Name))

	local devModuleScripts = getDevModuleScripts(devModule)
	assertScriptsAreDisabled(devModuleScripts)

	if constants.DEV_MODULE_STORAGE:FindFirstChild(devModule.Name) then
		log("info", "A version of this DevModule already exists. Skipping...")
		devModule:Destroy()
		return
	end

	if mergedOptions.pruneDevelopmentFiles then
		log("info", "Pruning development files...")
		prune(devModule)
	end

	-- The `true` flag searches all descendants of an instance, which is needed
	-- here since the Packages folder is nested.
	local packages = devModule:FindFirstChild(constants.PACKAGE_NAME, true)
	if packages then
		log("info", "Linking packages...")
		dedupePackages(packages)
	end

	log("info", "Overlaying services...")
	for _, child in ipairs(devModule:GetChildren()) do
		-- GetService errors if the given name is not a service so we wrap it in
		-- a pcall to use the result in a conditional.
		local success, service = pcall(function()
			return game:GetService(child.Name)
		end)

		if success then
			overlay(child, service)
		end
	end

	log("info", "Enabling scripts...")
	for _, devModuleScript in ipairs(devModuleScripts) do
		devModuleScript.Disabled = false
		log("info", ("Enabled %s"):format(devModuleScript.Name))
	end

	events.finished:Fire()

	log("info", ("Safe to remove %s"):format(devModule:GetFullName()))
	log("info", ("Removing %s..."):format(devModule:GetFullName()))
	devModule:Destroy()

	log("info", ("Successfully installed %s!"):format(devModule.Name))
end

return install
