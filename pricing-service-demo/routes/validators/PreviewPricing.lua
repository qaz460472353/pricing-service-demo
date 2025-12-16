-- Service: pricing
-- File: PreviewPricing.lua
-- Description: Request validator for preview pricing endpoint

local checks = require "util.Checks"

local _M = {}

-- Validate preview pricing request
-- @param request_body (table) - Request body to validate
-- @return (boolean) - Validation result
-- @return (table|nil) - Error object if validation fails
function _M.validate(request_body)
    if not checks.is_non_empty_table(request_body) then
        return false, {
            code = "INVALID_REQUEST",
            message = "Request body is required",
        }
    end

    if not checks.is_non_empty_string(request_body.target_id) then
        return false, {
            code = "INVALID_TARGET_ID",
            message = "target_id is required",
        }
    end

    if not checks.is_number(request_body.target_type) then
        return false, {
            code = "INVALID_TARGET_TYPE",
            message = "target_type must be a number",
        }
    end

    if not checks.is_non_empty_array(request_body.purchasing_entity_ids) then
        return false, {
            code = "INVALID_PURCHASING_ENTITIES",
            message = "purchasing_entity_ids must be a non-empty array",
        }
    end

    return true
end

return _M
