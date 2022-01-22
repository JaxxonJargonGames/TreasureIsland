local Roact = require(script.Parent.Parent.Packages.Roact)

Roact.setGlobalConfig({
	elementTracing = true,
	propValidation = true,
})

return {
	name = "Storybook",
	storyRoot = script.Parent,
}
