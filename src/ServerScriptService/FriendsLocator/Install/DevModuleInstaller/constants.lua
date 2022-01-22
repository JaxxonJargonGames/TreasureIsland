--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local constants = {
	-- The location where all DevModules are moved at runtime. Note that a DevModule
	-- is moved after its scripts and other instances have been moved to their
	-- proper locations. What remains of the DevModule is the Packages folder, and
	-- any ModuleScripts that are used by the DevModule.
	DEV_MODULE_STORAGE = ReplicatedStorage,

	-- DevModules rely on dependencies. By convention, these are stored in a folder
	-- named "Packages" inside the root of the DevModule. At runtime, the Packages
	-- folders from every DevModule are deduplicated, resulting in only one version
	-- of each package in use across all the DevModules in the game
	PACKAGE_NAME = "Packages",
	PACKAGE_STORAGE_LOCATION = ReplicatedStorage,
	PACKAGE_STORAGE_NAME = "DevModulePackages",
	PACKAGE_REF = script.Parent.packageRef,

	-- The version of a package is controlled by a StringValue included as a child
	-- of the package. This constant controls the name of that StringValue.
	--
	-- Initially we wanted to use Attributes for the version, however Rojo does not
	-- support syncing Attributes yet. As such, we've opted to go the old fashioned
	-- way of including a StringValue.
	PACKAGE_VERSION_NAME = "_Version",

	PACKAGE_VERSION_OBJECT_MISSING = "%s is missing a %s StringValue at %s",
	PACKAGE_VERSION_EMPTY = "%s cannot have an empty value for its version at %s",
	ENABLED_SCRIPTS_ERROR = "All scripts included with a DevModule must be Disabled. Please disable the "
		.. "following script(s): %s",
}

return constants
