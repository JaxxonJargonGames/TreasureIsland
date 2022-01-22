local StarterGui = game:GetService("StarterGui")

local Roact = require(script.Parent.Parent.Packages.Roact)
local Cryo = require(script.Parent.Parent.Packages.Cryo)

--[[
	HOC that wraps a component that can be hot swapped with a GUI instance.

	Parameters:
	- guiName (string): name of GUI that is stored in the `CustomGui` folder

	Returns:
	- Function that injects the custom GUI instance into the wrapped component as a prop
]]
local function withCustomGui(guiName)
	return function(Component)
		local CustomGui = Roact.Component:extend("CustomGui")

		function CustomGui:init()
			self.StarterGui = self.props.StarterGui or StarterGui

			-- Find the custom GUI folder and clone the instance
			local instance = self.StarterGui:FindFirstChild(guiName, true)

			-- No custom GUI defined
			if not instance then
				return
			end

			-- Invalid class of GUI defined
			if not instance:IsA("Frame") then
				warn(
					string.format(
						"[FriendsLocator] Custom GUI provided expected to be Frame, got %s instead",
						instance.ClassName
					)
				)
				return
			end

			-- Clone GUI
			self.instance = instance:Clone()
		end

		function CustomGui:render()
			return Roact.createElement(
				Component,
				Cryo.Dictionary.join(self.props, {
					customGui = self.instance,
				})
			)
		end

		function CustomGui:willUnmount()
			if self.instance then
				self.instance:Destroy()
				self.instance = nil
			end
		end

		return CustomGui
	end
end

return withCustomGui
