-- Service: pricing
-- File: PricingInternalData.lua
-- Description: Pricing internal data structure definition

local checks = require "util.Checks"

local _M = {}

-- Default internal data structure
function _M:generate_default_internal_data()
    return {
        line_items = {},
        facts = {
            operator_name = nil,
            calculation_timestamp = nil,
            target_id = nil,
            target_type = nil,
        },
        execution_phases = {},
    }
end

-- Create internal data from charge objects
-- @param charge_objects (table) - List of charge objects
-- @param calc_context (table) - Calculation context
-- @return (table) - Internal data structure
-- @return (table|nil) - Error object if construction fails
function _M:new_from_charge_objects(charge_objects, calc_context)
    checks.assert(checks.is_non_empty_array(charge_objects), "charge_objects must be a non-empty array")
    checks.assert(checks.is_non_empty_table(calc_context), "calc_context must be a non-empty table")

    local internal_data = self:generate_default_internal_data()
    setmetatable(internal_data, { __index = _M })

    -- Set facts
    internal_data.facts.operator_name = calc_context.operator_name
    internal_data.facts.calculation_timestamp = calc_context.calculation_timestamp or os.time()
    internal_data.facts.target_id = calc_context.target_id
    internal_data.facts.target_type = calc_context.target_type

    -- Set execution phases
    internal_data.execution_phases = {
        "LIST_PRICE_PHASE",
        "DISCOUNT_PHASE",
        "FEE_PHASE",
        "TAX_PHASE",
        "TOTAL_PHASE",
    }

    -- Convert charge objects to line items
    for _, charge_object in ipairs(charge_objects) do
        local line_item = {
            item_context = {
                source_object = charge_object,
                offer_id = charge_object.offer_id,
            },
            components = {},
            aggregated_prices = {
                list_price = 0,
                discount_amount = 0,
                fee_amount = 0,
                tax_amount = 0,
                net_price = 0,
            },
        }
        table.insert(internal_data.line_items, line_item)
    end

    return internal_data
end

-- Create internal data from purchasing entities
-- @param operator_name (string) - Operator identifier
-- @param calc_context (table) - Calculation context with purchasing entities
-- @return (table) - Internal data structure
-- @return (table|nil) - Error object if construction fails
function _M:new_from_purchasing_entities(operator_name, calc_context)
    checks.assert(checks.is_non_empty_string(operator_name), "operator_name must be a non-empty string")
    checks.assert(checks.is_non_empty_table(calc_context), "calc_context must be a non-empty table")

    local internal_data = self:generate_default_internal_data()
    setmetatable(internal_data, { __index = _M })

    -- Set facts
    internal_data.facts.operator_name = operator_name
    internal_data.facts.calculation_timestamp = calc_context.calculation_timestamp or os.time()
    internal_data.facts.target_id = calc_context.target_id
    internal_data.facts.target_type = calc_context.target_type

    -- Set execution phases
    internal_data.execution_phases = {
        "LIST_PRICE_PHASE",
        "DISCOUNT_PHASE",
        "FEE_PHASE",
        "TAX_PHASE",
        "TOTAL_PHASE",
    }

    -- Convert purchasing entities to line items
    for _, entity in ipairs(calc_context.purchasing_entity_ids or {}) do
        local line_item = {
            item_context = {
                entity_id = entity.entity_id,
                quantity = entity.quantity or 1,
            },
            components = {},
            aggregated_prices = {
                list_price = 0,
                discount_amount = 0,
                fee_amount = 0,
                tax_amount = 0,
                net_price = 0,
            },
        }
        table.insert(internal_data.line_items, line_item)
    end

    return internal_data
end

return _M
