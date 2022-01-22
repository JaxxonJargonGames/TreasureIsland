local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local Cryo = require(script.Parent.Parent.Parent.Packages.Cryo)

local context = Roact.createContext({})

--[[
	Wrapper component that provides the ConfigurationContext to the child components.
]]
local ConfigurationProvider = Roact.Component:extend("ConfigurationProvider")
function ConfigurationProvider:init()
	assert(
		typeof(self.props.config) == "table",
		"ConfigurationContext requires the `config` prop to be an instance of Configuration"
	)

	self.state = self.props.config.getValues()
	self:_connectUpdateEvent()
end

function ConfigurationProvider:render()
	return Roact.createElement(context.Provider, {
		value = self.state,
	}, self.props[Roact.Children])
end

function ConfigurationProvider:didMount()
	self:_connectUpdateEvent()
end

function ConfigurationProvider:willUnmount()
	if self.changedConn then
		self.changedConn:Disconnect()
		self.changedConn = nil
	end
end

--[[
	Since Roact yields between render and didMount, a Dev Module user can, in theory, update the
	configuration values between the two lifecycle methods, resulting in a race condition.

	We need to make sure the event is connected before the yield happens, therefore we connect to this
	event in two locations:
	1. init(), and
	2. didMount()

	#2 is added to ensure that this event gets connected in the event that a user unmounts ConfigurationContext
	and mounts it again, which is extremely unlikely.
]]
function ConfigurationProvider:_connectUpdateEvent()
	if self.changedConn then
		return
	end

	self.changedConn = self.props.config.changed:Connect(function(values)
		self:setState(values)
	end)
end

--[[
	Higher order component that lets the wrapped component consume the ConfigurationContext.
]]
local function withConfiguration(component)
	return function(props)
		if props.configuration then
			warn("Child component has a prop named `configuration` and will be overriden by ConfigurationContext.")
		end

		return Roact.createElement(context.Consumer, {
			render = function(configuration)
				local mergedProps = Cryo.Dictionary.join({ configuration = configuration }, props)

				return Roact.createElement(component, mergedProps)
			end,
		})
	end
end

return {
	ConfigurationProvider = ConfigurationProvider,
	withConfiguration = withConfiguration,
}
