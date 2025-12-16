-- Service: pricing
-- File: BasePriceCalculator.lua
-- Description: Calculates base list prices

local pricing_enums = require "pricing.utils.Enums"

local _M = {}

-- Execute base price calculation
-- @param internal_data (table) - Pricing internal data
-- @return (boolean) - Success status
-- @return (table|nil) - Error object if calculation fails
function _M.execute(internal_data)
    for _, line_item in ipairs(internal_data.line_items or {}) do
        -- Simplified: Use a mock base price
        -- In real implementation, this would fetch from catalog/offer data
        local base_price = 100.00 -- Mock price

        -- Add origin component
        table.insert(line_item.components or {}, {
            type = pricing_enums.COMPONENT_TYPE.ORIGIN,
            amount = base_price,
        })

        -- Update aggregated prices
        line_item.aggregated_prices = line_item.aggregated_prices or {}
        line_item.aggregated_prices.list_price = base_price
    end

    return true
end

return _M
