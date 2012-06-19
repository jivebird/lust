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

function TestAssert:testAssertNilWithNil()
	local status = pcall(assertNil, nil)
	assert(status)
end

function TestAssert:testAssertNilWithNotNil()
	local status, err = pcall(assertNil, {})
	assert(not status)
	assert(err:endsWith('Expected nil'))
end

function TestAssert:testAssertNotNilWithNotNil()
	local status = pcall(assertNotNil, {})
	assert(status)
end

function TestAssert:testAssertNotNilWithNil()
	local status, err = pcall(assertNotNil, nil)
	assert(not status)
	assert(err:endsWith('Expected not nil'))
end

function TestAssert:testAssertErrorNoError()
	local status, err = pcall(assertError, function() assertTrue(true) end)
	assertFalse(status)
	assertTrue(err:endsWith('Expected error.  Got none.'))
end

function TestAssert:testAssertErrorWithError()
	local status = pcall(assertError, function() assertTrue(false) end)
	assertTrue(status)
end

function TestAssert:testAssertNoErrorNoError()
	local status = pcall(assertNoError, function() assertTrue(true) end)
	assertTrue(status)
end

function TestAssert:testAssertNoErrorWithError()
	local status, err = pcall(assertNoError, function() assertTrue(false) end)
	assertFalse(status)
	assert(err:endsWith('Expected true was false'))
end

TestMock = {}

function TestMock:setUp()
	self.mock = Mock:new()
end

function TestMock:testExists()
	assert(self.mock ~= nil)
end

function TestMock:testVerifyHasntHappened()
	assertError(function() verify(self.mock):simpleMethod() end)
end

function TestMock:testVerifyHasHappened()
	self.mock:simpleMethod()
	assertNoError(function() verify(self.mock):simpleMethod() end)
end

function TestMock:testVerifyHasntHappenedWithArg()
	assertError(function() verify(self.mock):argMethod(1) end)
end

function TestMock:testVerifyHasHappenedWithArg()
	self.mock:argMethod(1)
	assertNoError(function() verify(self.mock):argMethod(1) end)
end

function TestMock:testVerifyHasHappenedWithMultipleArgs()
	self.mock:argMethod(1, 2)
	assertNoError(function() verify(self.mock):argMethod(1, 2) end)
end

function TestMock:testVerifyHasntHappenedWithDifferentArg()
	self.mock:argMethod(2)
	assertError(function() verify(self.mock):argMethod(1) end)
end

function TestMock:testVerifyHasntHappenedWithMoreArgs()
	self.mock:argMethod(2)
	assertError(function() verify(self.mock):argMethod(2, 1) end)
end

function TestMock:testVerifyHasntHappenedWithLessArgs()
	self.mock:argMethod(2, 1)
	assertError(function() verify(self.mock):argMethod(2) end)
end

function TestMock:testStubHasntHappened()
	assertNil(self.mock:simpleMethod())
end

function TestMock:testStubHasHappened()
	when(self.mock, 15):simpleMethod()
	assertEquals(15, self.mock:simpleMethod())
end

function TestMock:testStubHasntHappenedWithArg()
	assertNil(self.mock:argMethod(1))
end

function TestMock:testStubHasHappenedWithArg()
	when(self.mock, 20):argMethod(1)
	assertEquals(20, self.mock:argMethod(1))
end

function TestMock:testStubHasHappenedWithMultipleArgs()
	when(self.mock, 45):argMethod(1, 2)
	assertEquals(45, self.mock:argMethod(1, 2))
end

function TestMock:testStubHasntHappenedWithDifferentArg()
	when(self.mock, 45):argMethod(2)
	assertNil(self.mock:argMethod(1))
end

function TestMock:testStubHasntHappenedWithMoreArgs()
	when(self.mock, 45):argMethod(2)
	assertNil(self.mock:argMethod(2, 1))
end

function TestMock:testStubHasntHappenedWithLessArgs()
	when(self.mock, 45):argMethod(2, 1)
	assertNil(self.mock:argMethod(2))
end

function TestMock:testArgumentMatcherWithVerifyDidntMatch()
	self.mock:argMethod(15)
	assertError(function() verify(self.mock):argMethod(match(15, incrementMatcher)) end)
end

function TestMock:testArgumentMatcherWithVerifyDoesMatch()
	self.mock:argMethod(16, 10)
	assertNoError(function() verify(self.mock):argMethod(match(17, incrementMatcher), 10) end)
end

function TestMock:testArgumentMatcherWithStubDidntMatch()
	when(self.mock, 12):argMethod(match(20, incrementMatcher))
	assertNil(self.mock:argMethod(20))
end

function TestMock:testArgumentMatcherWithStubDoesMatch()
	when(self.mock, 12):argMethod(match(20, incrementMatcher))
	assertEquals(12, self.mock:argMethod(19))
end

function incrementMatcher(expected, actual)
	return expected == actual + 1
end

LuaUnit:run()
