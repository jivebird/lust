MockCall = {}

function MockCall:new(name, arguments)
	local call = {}
	call.name = name
	call.arguments = arguments
	setmetatable(call, self)
	self.__index = self
	
	return call
end

function MockCall:isSame(name, arguments)
	return self.name == name and self:isSameArguments(arguments)
end

function MockCall:isSameArguments(arguments)
	if #arguments ~= #self.arguments then
		return false
	end
	
	for key, value in ipairs(self.arguments) do
		if arguments[key] ~= value then
			return false
		end
	end
	
	return true
end

Mock = {}

function Mock:new()
	local mock = {}
	mock.calls = {}
	setmetatable(mock, self)
	return mock
end

function Mock:addCall(name, arguments)
	table.insert(self.calls, MockCall:new(name, arguments))
end

function Mock:hasCall(name, arguments)
	for i, call in ipairs(self.calls) do
		if call:isSame(name, arguments) then
			return true
		end
	end
	
	return false
end

function Mock:getCallCount()
	return table.getn(self.calls)
end

function Mock:__index(property)
	local mock = self
	
	return function(...)
		Mock.addCall(mock, property, arg)
	end
end

Verifier = {}

function Verifier:new(mock)
	local verifier = {}
	verifier.mock = mock
	setmetatable(verifier, self)
	return verifier
end

function Verifier:__index(property)
	local verifier = self
	return function(...)
		return Mock.hasCall(verifier.mock, property, arg)
	end
end

function verify(mock)
	return Verifier:new(mock)
end

function assertTrue(value)
	assert(value, 'Expected true was ' .. (value == nil and 'nil' or 'false'))
end

function assertFalse(value)
	assert(not value, 'Expected false was true')
end
