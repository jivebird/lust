require 'luaunit/luaunit'
require 'lust'

TestEndsWith = {}

function string:endsWith(str)
	local start, stop = self:find(str, self:len() - str:len())
	return start ~= nil and stop == self:len()
end

function TestEndsWith:testDoesntEndWith()
	local str = 'Blah blah blah'
	assert(not str:endsWith('blahe'))
	assert(not str:endsWith('Blah'))
end

function TestEndsWith:testDoesEndWith()
	local str = 'Blah blah blah'
	assert(str:endsWith('blah'))
	
	local str = 'Another test'
	assert(str:endsWith('r test'))
end

TestAssert = {}

function TestAssert:testAssertTrueWithTrue()
	assert(pcall(assertTrue, true) == true)
end

function TestAssert:testAssertTrueWithFalse()
	local status, err = pcall(assertTrue, false)
	assert(not status)
	assert(err:endsWith('Expected true was false'))
end

function TestAssert:testAssertTrueWithNil()
	local status, err = pcall(assertTrue, nil)
	assert(not status)
	assert(err:endsWith('Expected true was nil'))
end

function TestAssert:testAssertFalseWithFalse()
	assert(pcall(assertFalse, false) == true)
end

function TestAssert:testAssertFalseWithTrue()
	local status, err = pcall(assertFalse, true)
	assert(not status)
	assert(err:endsWith('Expected false was true'))
end

function TestAssert:testAssertFalseWithNil()
	assert(pcall(assertFalse, nil) == true)
end

TestMock = {}

function TestMock:setUp()
	self.mock = Mock:new()
end

function TestMock:testExists()
	assert(self.mock ~= nil)
end

function TestMock:testVerifyHasntHappened()
	assertFalse(verify(self.mock).simpleMethod())
end

function TestMock:testVerifyHasHappened()
	self.mock.simpleMethod()
	assertTrue(verify(self.mock).simpleMethod())
end

function TestMock:testVerifyHasntHappenedWithArg()
	assertFalse(verify(self.mock).argMethod(1))
end

function TestMock:testVerifyHasHappenedWithArg()
	self.mock.argMethod(1)
	assertTrue(verify(self.mock).argMethod(1))
end

function TestMock:testVerifyHasHappenedWithMultipleArgs()
	self.mock.argMethod(1, 2)
	assertTrue(verify(self.mock).argMethod(1, 2))
end

function TestMock:testVerifyHasntHappenedWithDifferentArg()
	self.mock.argMethod(2)
	assertFalse(verify(self.mock).argMethod(1))
end

function TestMock:testVerifyHasntHappenedWithMoreArgs()
	self.mock.argMethod(2)
	assertFalse(verify(self.mock).argMethod(2, 1))
end

function TestMock:testVerifyHasntHappenedWithLessArgs()
	self.mock.argMethod(2, 1)
	assertFalse(verify(self.mock).argMethod(2))
end

LuaUnit:run()
