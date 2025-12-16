-- Service: pricing
-- File: TaxCalculator.lua
-- Description: Calculates tax amounts

local pricing_enums = require "pricing.utils.Enums"

local _M = {}

-- Execute tax calculation
-- @param internal_data (table) - Pricing internal data
-- @return (boolean) - Success status
-- @return (table|nil) - Error object if calculation fails
function _M.execute(internal_data)
    for _, line_item in ipairs(internal_data.line_items or {}) do
        local list_price = line_item.aggregated_prices.list_price or 0
        local discount_amount = line_item.aggregated_prices.discount_amount or 0
        local fee_amount = line_item.aggregated_prices.fee_amount or 0

        -- Simplified: Calculate tax on net price (8% tax rate)
        local taxable_amount = list_price - discount_amount + fee_amount
        local tax_amount = taxable_amount * 0.08

        -- Add tax component
        table.insert(line_item.components or {}, {
            type = pricing_enums.COMPONENT_TYPE.TAX,
            amount = tax_amount,
        })

        -- Update aggregated prices
        line_item.aggregated_prices.tax_amount = tax_amount
    end

    return true
end

return _M
