-- Service: pricing
-- File: RouteHelper.lua
-- Description: Route helper utilities

local checks = require "util.Checks"

local _M = {}

-- Get operator name from request context
-- @param request_context (table) - HTTP request context
-- @return (string) - Operator name
-- @return (table|nil) - Error object if extraction fails
function _M.get_operator_name(request_context)
    checks.assert(checks.is_non_empty_table(request_context), "request_context must be a non-empty table")

    -- Simplified: Extract from headers or use default
    local operator_name = request_context.headers and request_context.headers["X-Operator-Name"]
    if not operator_name or operator_name == "" then
        operator_name = "default_operator"
    end

    return operator_name
end

return _M
