-- Service: pricing
-- File: test_setup.lua
-- Description: Test environment setup for pricing service unit tests

-- Simplified test framework setup
-- In real implementation, this would set up busted test framework
local busted = require "busted"
local assert = require "luassert"

-- Mock snapshot functionality for test isolation
local snapshot = {
    snapshots = {},
    current = nil,
}

function snapshot:new()
    local id = #self.snapshots + 1
    self.snapshots[id] = {}
    self.current = id
    return setmetatable({ id = id }, { __index = self })
end

function snapshot:revert()
    if self.current then
        self.snapshots[self.current] = nil
        self.current = nil
    end
end

-- Simplified assert with snapshot
local assert_with_snapshot = setmetatable({}, {
    __index = assert,
    snapshot = function() return snapshot:new() end,
})

_G.assert = assert_with_snapshot

-- Export test utilities
return {
    snapshot = snapshot,
}
