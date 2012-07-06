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
		if key > 1 then
			local argument = arguments[key]
			if not self:isSameArgument(argument, value) then
				return false
			end
		end
	end
	
	return true
end

function MockCall:isSameArgument(argument1, argument2)
	if self:isArgumentMatcher(argument1) then
		if not argument1:matches(argument2) then
			return false
		end
	elseif self:isArgumentMatcher(argument2) then
		if not argument2:matches(argument1) then
			return false
		end
	elseif argument1 ~= argument2 then
		return false
	end
	
	return true
end

function MockCall:isArgumentMatcher(argument)
	return type(argument) == 'table' and argument._isArgumentMatcher
end

Mock = {}

function Mock:new()
	local mock = {}
	mock.calls = {}
	mock.stubs = {}
	setmetatable(mock, self)
	
	return mock
end

function Mock.addCall(mock, name, arguments)
	table.insert(mock.calls, MockCall:new(name, arguments))
	return Mock.getStub(mock, name, arguments)
end

function Mock.whenCalled(mock, value, name, arguments)
	local call = Mock.getCall(mock.stubs, name, arguments)
	
	if not call then
		call = MockCall:new(name, arguments)
	end
	
	call.value = value
	table.insert(mock.stubs, call)
end

function Mock.hasCall(mock, name, arguments)
	for i, call in ipairs(mock.calls) do
		if call:isSame(name, arguments) then
			return true
		end
	end
	
	return nil
end

function Mock.getStub(mock, name, arguments)
	local call = Mock.getCall(mock.stubs, name, arguments)
	return call and call.value or nil
end

function Mock.getCall(list, name, arguments)
	for i, call in ipairs(list) do
		if call:isSame(name, arguments) then
			return call
		end
	end
	
	return nil
end

function Mock.getCallCount(mock)
	return table.getn(mock.calls)
end

function Mock.__index(mock, property)
	return function(...)
		return Mock.addCall(mock, property, arg)
	end
end

Stubber = {}

function Stubber:new(mock, value)
	local stubber = {}
	stubber.mock = mock
	stubber.value = value
	setmetatable(stubber, self)
	return stubber
end

function Stubber.__index(stubber, property)
	return function(...)
		Mock.whenCalled(stubber.mock, stubber.value, property, arg)
	end
end

function when(mock, value)
	return Stubber:new(mock, value)
end

Verifier = {}

function Verifier:new(mock)
	local verifier = {}
	verifier.mock = mock
	setmetatable(verifier, self)
	return verifier
end

function Verifier.__index(verifier, property)
	return function(...)
		assert(Mock.hasCall(verifier.mock, property, arg), 'Expected method not called')
	end
end

function verify(mock)
	return Verifier:new(mock)
end

ArgumentMatcher = {}

function ArgumentMatcher:new(expected, method)
	local matcher = {}
	matcher.expected = expected
	matcher.method = method
	matcher._isArgumentMatcher = true
	setmetatable(matcher, self)
	self.__index = self
	
	return matcher;
end

function ArgumentMatcher:matches(actual)
	return self.method(self.expected, actual)
end

function match(expected, method)
	return ArgumentMatcher:new(expected, method)
end

function assertTrue(value)
	assert(value, 'Expected true was ' .. (value == nil and 'nil' or 'false'))
end

function assertFalse(value)
	assert(not value, 'Expected false was true')
end

function assertNil(value)
	assert(value == nil, 'Expected nil')
end

function assertNotNil(value)
	assert(value ~= nil, 'Expected not nil')
end

function assertNoError(method)
	local status, err = pcall(method)
	assert(status, err and 'Expected no error.  Got ' .. err or 'Expected no error')
end

function assertError(method)
	local status, err = pcall(method)
	assert(not status, 'Expected error.  Got none.')
end
