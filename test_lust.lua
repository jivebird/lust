require 'luaunit/luaunit'
require 'lust'

TestMock = {}

function TestMock:setUp()
	self.mock = Mock:new()
end

function TestMock:testExists()
	assert(self.mock ~= nil)
end

function TestMock:testVerifyHasntHappened()
	assert(verify(self.mock).simpleMethod() == false)
end

function TestMock:testVerifyHasHappened()
	self.mock.simpleMethod()
	assert(verify(self.mock).simpleMethod() == true)
end

TestFunctions = wrapFunctions('test')
LuaUnit:run()
