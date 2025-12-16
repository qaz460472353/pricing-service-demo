-- Service: pricing
-- File: DiscountCalculator.lua
-- Description: Calculates discount amounts

local pricing_enums = require "pricing.utils.Enums"

local _M = {}

-- Execute discount calculation
-- @param internal_data (table) - Pricing internal data
-- @return (boolean) - Success status
-- @return (table|nil) - Error object if calculation fails
function _M.execute(internal_data)
    for _, line_item in ipairs(internal_data.line_items or {}) do
        local list_price = line_item.aggregated_prices.list_price or 0
        -- Simplified: Apply 10% discount as example
        local discount_amount = list_price * 0.10

        -- Add discount component
        table.insert(line_item.components or {}, {
            type = pricing_enums.COMPONENT_TYPE.DISCOUNT,
            amount = -discount_amount, -- Negative for discount
        })

        -- Update aggregated prices
        line_item.aggregated_prices.discount_amount = discount_amount
    end

    return true
end

return _M
