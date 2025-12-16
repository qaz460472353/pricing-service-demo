-- Service: pricing
-- File: FeeCalculator.lua
-- Description: Calculates fee amounts

local pricing_enums = require "pricing.utils.Enums"

local _M = {}

-- Execute fee calculation
-- @param internal_data (table) - Pricing internal data
-- @return (boolean) - Success status
-- @return (table|nil) - Error object if calculation fails
function _M.execute(internal_data)
    for _, line_item in ipairs(internal_data.line_items or {}) do
        -- Simplified: Fixed fee amount
        local fee_amount = 5.00

        -- Add fee component
        table.insert(line_item.components or {}, {
            type = pricing_enums.COMPONENT_TYPE.FEE,
            amount = fee_amount,
        })

        -- Update aggregated prices
        line_item.aggregated_prices.fee_amount = fee_amount
    end

    return true
end

return _M
