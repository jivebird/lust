MockCall = {}

function MockCall:new(name, arguments)
	local call = {}
	call.name = name
	call.arguments = arguments
	setmetatable(call, self)
	self.__index = self
end

function MockCall:isSame(name, arguments)
	return self.name = name
end

Mock = {}

function Mock:new()
	local mock = {}
	mock.calls = {}
	setmetatable(mock, self)
	return mock
end

function Mock:__index(property)
	local mock = self
	return function(...)
		mock.calls[property] = true
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
		return verifier.mock.calls[property] == true
	end
end

function verify(mock)
	return Verifier:new(mock)
end
