--!strict
local package = script.package
assert(
	package and package:IsA("ObjectValue"),
	("could not require package. %q does not have a 'package' ObjectValue"):format(script:GetFullName())
)
local value = package.Value
assert(
	value and value:IsA("ModuleScript"),
	("could not require package. %q does not have a package set as its Value"):format(package:GetFullName())
)
return require(value :: ModuleScript)
