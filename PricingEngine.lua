-- Service: pricing
-- File: PricingEngine.lua
-- Description: Core pricing engine that orchestrates price calculations

-- Simplified logger module
local logger = {
    error = function(self, msg, ...) print(string.format("[ERROR] " .. msg, ...)) end,
    info = function(self, msg, ...) print(string.format("[INFO] " .. msg, ...)) end,
}
logger = setmetatable(logger, { __index = logger })

local checks = require "util.Checks"
local executor = require "pricing.Executor"
local pricing_internal_data = require "pricing.struct.PricingInternalData"
local output_adapter = require "pricing.struct.output.Adapter"

local _M = {}

-- Calculate price for charge objects
-- @param operator_name (string) - Operator identifier
-- @param charge_objects (table) - List of charge objects to calculate
-- @param calc_context (table) - Calculation context with user info, timestamps, etc.
-- @return (table) - Pricing result with item prices and totals
-- @return (table|nil) - Error object if calculation fails
local function calculate(operator_name, charge_objects, calc_context)
    checks.assert(checks.is_non_empty_string(operator_name), "operator_name must be a non-empty string")
    checks.assert(checks.is_non_empty_array(charge_objects), "charge_objects must be a non-empty array")
    checks.assert(checks.is_non_empty_table(calc_context), "calc_context must be a non-empty table")

    -- Construct internal data structure from charge objects
    local internal_data, construct_err = pricing_internal_data:new_from_charge_objects(charge_objects, calc_context)
    if construct_err then
        logger:error("Failed to construct internal data: %s", construct_err)
        return nil, construct_err
    end

    -- Execute pricing calculation phases
    local calculated_internal_data, calc_err = executor:execute(internal_data)
    if calc_err then
        logger:error("Failed to execute pricing calculation: %s", calc_err)
        return nil, calc_err
    end

    -- Convert internal data to output format
    local calc_result, convert_err = output_adapter.convert(calculated_internal_data)
    if convert_err then
        logger:error("Failed to convert result: %s", convert_err)
        return nil, convert_err
    end

    return calc_result
end

-- Preview pricing for purchasing entities
-- @param operator_name (string) - Operator identifier
-- @param calc_context (table) - Calculation context with purchasing entities
-- @return (table) - Preview pricing result
-- @return (table|nil) - Error object if calculation fails
local function preview_pricing(operator_name, calc_context)
    checks.assert(checks.is_non_empty_string(operator_name), "operator_name must be a non-empty string")
    checks.assert(checks.is_non_empty_table(calc_context), "calc_context must be a non-empty table")

    -- Construct internal data from purchasing entities
    local internal_data, construct_err = pricing_internal_data:new_from_purchasing_entities(operator_name, calc_context)
    if construct_err then
        logger:error("Failed to construct internal data for preview: %s", construct_err)
        return nil, construct_err
    end

    -- Execute pricing calculation
    local calculated_internal_data, calc_err = executor:execute(internal_data)
    if calc_err then
        logger:error("Failed to execute preview pricing: %s", calc_err)
        return nil, calc_err
    end

    -- Convert to output format
    local calc_result, convert_err = output_adapter.convert(calculated_internal_data)
    if convert_err then
        logger:error("Failed to convert preview result: %s", convert_err)
        return nil, convert_err
    end

    return calc_result
end

_M.calculate = calculate
_M.preview_pricing = preview_pricing

return _M
