-- Service: pricing
-- File: PreviewPricing.lua
-- Description: Route handler for preview pricing endpoint

-- Simplified logger module
local logger = {
    error = function(self, msg, ...) print(string.format("[ERROR] " .. msg, ...)) end,
}
logger = setmetatable(logger, { __index = logger })

-- Simplified HTTP manager (placeholder)
local http_manager = {
    handle_request = function(config) 
        -- In real implementation, this would register the route
        print("Route registered: PreviewPricing")
    end
}

local pricing_engine = require "pricing.PricingEngine"
local route_helper = require "pricing.utils.RouteHelper"
local pricing_enums = require "pricing.utils.Enums"

local LINE_ITEM_SOURCE_TYPE = pricing_enums.LINE_ITEM_SOURCE_TYPE

-- Simplified auth enums
local TOKEN_TYPE = {
    SERVICE = "SERVICE",
}

local CONTEXT_OPTIONS = {
    allowed_token_types = {
        TOKEN_TYPE.SERVICE,
    },
}

-- Request handler function
local function request_handler(request_context)
    local request_body = request_context.body

    -- Get operator name from request context
    local operator_name, get_operator_name_err = route_helper.get_operator_name(request_context)
    if get_operator_name_err then
        return nil, get_operator_name_err
    end

    -- Build calculation context
    local calc_context = {
        operator_name = operator_name,
        target_id = request_body.target_id,
        target_type = request_body.target_type,
        calculation_timestamp = os.time(),
        purchasing_entity_ids = request_body.purchasing_entity_ids,
        existing_entity_ids = request_body.existing_entity_ids,
        skip_tax_calculation = request_body.skip_tax_calculation or false,
        source_type = LINE_ITEM_SOURCE_TYPE.ENTITY,
    }

    -- Execute preview pricing
    local preview_result, get_err = pricing_engine.preview_pricing(operator_name, calc_context)
    if get_err then
        logger:error("Preview pricing failed: %s", get_err)
        return nil, get_err
    end

    return {
        body = preview_result
    }
end

-- Register route handler
http_manager.handle_request({
    context_options = CONTEXT_OPTIONS,
    validator = require "pricing.routes.validators.PreviewPricing",
    request_handler = request_handler,
})
