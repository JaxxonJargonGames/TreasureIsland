local Cryo = require(script.Parent.Parent.Parent.Packages.Cryo)
local t = require(script.Parent.Parent.Parent.Packages.t)

return function(RunService, serverConfigChanged, serverConfigRequested)
	local Configuration = {}

	local check = t.tuple(t.string, t.table, t.callback)

	function Configuration.new(name, initialValues, validate)
		assert(check(name, initialValues, validate))

		initialValues = Cryo.Dictionary.join(initialValues, {})

		assert(validate(initialValues))

		local changed = Instance.new("BindableEvent")

		local self = {
			name = name,
			initialValues = initialValues,
			values = initialValues,
			validate = validate,
			changed = changed.Event,
		}

		self.getValues = function()
			return self.values
		end

		self._updateValues = function(newValues)
			self.values = newValues
			changed:Fire(newValues)
		end

		self.configure = function(configuration)
			local newValues = Cryo.Dictionary.join(self.values, configuration)

			assert(self.validate(newValues))

			self._updateValues(newValues)

			if RunService:IsServer() then
				serverConfigChanged:FireAllClients(self.name, newValues)
			end
		end

		self.reset = function()
			self.values = {}
			self.configure(self.initialValues)
		end

		self.destroy = function()
			if self._configChangedConn then
				self._configChangedConn:Disconnect()
			end

			if self._configRequestedConn then
				self._configRequestedConn:Disconnect()
			end
		end

		if RunService:IsServer() then
			self._configRequestedConn = serverConfigRequested.OnServerEvent:Connect(
				function(player: Player, otherName: string)
					if self.name == otherName then
						serverConfigChanged:FireClient(player, self.name, self.values)
					end
				end
			)
		elseif RunService:IsClient() then
			self._configChangedConn = serverConfigChanged.OnClientEvent:Connect(
				function(otherName: string, values: table)
					if self.name == otherName then
						self._updateValues(values)
					end
				end
			)

			serverConfigRequested:FireServer(self.name)
		end

		return self
	end

	return Configuration
end
