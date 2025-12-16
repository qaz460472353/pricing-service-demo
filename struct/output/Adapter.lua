-- Service: pricing
-- File: Adapter.lua
-- Description: Converts internal pricing data to output format

local checks = require "util.Checks"

local _M = {}

-- Convert internal data to output format
-- @param internal_data (table) - Calculated internal data
-- @return (table) - Output pricing result
-- @return (table|nil) - Error object if conversion fails
function _M.convert(internal_data)
    checks.assert(checks.is_non_empty_table(internal_data), "internal_data must be a non-empty table")

    local item_price = {}
    local total_price = {
        amount = 0,
        tax_amount = 0,
        discount_amount = 0,
        fee_amount = 0,
    }

    -- Convert line items to item prices
    for _, line_item in ipairs(internal_data.line_items or {}) do
        local aggregated = line_item.aggregated_prices or {}
        local item = {
            charge_id = line_item.item_context.source_object and line_item.item_context.source_object.id or nil,
            list_price = aggregated.list_price or 0,
            discount_amount = aggregated.discount_amount or 0,
            fee_amount = aggregated.fee_amount or 0,
            tax_amount = aggregated.tax_amount or 0,
            net_price = aggregated.net_price or 0,
        }
        table.insert(item_price, item)

        -- Aggregate totals
        total_price.amount = total_price.amount + (aggregated.net_price or 0)
        total_price.tax_amount = total_price.tax_amount + (aggregated.tax_amount or 0)
        total_price.discount_amount = total_price.discount_amount + (aggregated.discount_amount or 0)
        total_price.fee_amount = total_price.fee_amount + (aggregated.fee_amount or 0)
    end

    return {
        item_price = item_price,
        total_price = total_price,
    }
end

return _M
