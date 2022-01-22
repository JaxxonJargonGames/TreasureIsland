local MockRemoteEvent = {}
MockRemoteEvent.__index = MockRemoteEvent

local MOCK_PLAYER = {}

function MockRemoteEvent.new()
	local self = {}

	self._onClientEventBindable = Instance.new("BindableEvent")
	self.OnClientEvent = self._onClientEventBindable.Event

	self._onServerEventBindable = Instance.new("BindableEvent")
	self.OnServerEvent = self._onServerEventBindable.Event

	return setmetatable(self, MockRemoteEvent)
end

function MockRemoteEvent:FireServer(...)
	self._onServerEventBindable:Fire(MOCK_PLAYER, ...)
end

function MockRemoteEvent:FireClient(_player, ...)
	self._onClientEventBindable:Fire(...)
end

function MockRemoteEvent:FireAllClients(...)
	self._onClientEventBindable:Fire(...)
end

return MockRemoteEvent
