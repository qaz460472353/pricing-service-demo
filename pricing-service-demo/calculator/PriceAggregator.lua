-- Service: pricing
-- File: PriceAggregator.lua
-- Description: Aggregates price components

local _M = {}

-- Aggregate list price
-- @param internal_data (table) - Pricing internal data
-- @return (boolean) - Success status
function _M.aggregate_list_price(internal_data)
    -- Already aggregated in calculator
    return true
end

-- Aggregate discount price
-- @param internal_data (table) - Pricing internal data
-- @return (boolean) - Success status
function _M.aggregate_discount_price(internal_data)
    -- Already aggregated in calculator
    return true
end

-- Aggregate fee amount
-- @param internal_data (table) - Pricing internal data
-- @return (boolean) - Success status
function _M.aggregate_fee_amount(internal_data)
    -- Already aggregated in calculator
    return true
end

-- Aggregate tax price
-- @param internal_data (table) - Pricing internal data
-- @return (boolean) - Success status
function _M.aggregate_tax_price(internal_data)
    -- Already aggregated in calculator
    return true
end

-- Aggregate total prices
-- @param internal_data (table) - Pricing internal data
-- @return (boolean) - Success status
function _M.aggregate_total_prices(internal_data)
    for _, line_item in ipairs(internal_data.line_items or {}) do
        local list_price = line_item.aggregated_prices.list_price or 0
        local discount_amount = line_item.aggregated_prices.discount_amount or 0
        local fee_amount = line_item.aggregated_prices.fee_amount or 0
        local tax_amount = line_item.aggregated_prices.tax_amount or 0

        -- Calculate net price
        line_item.aggregated_prices.net_price = list_price - discount_amount + fee_amount + tax_amount
    end

    return true
end

return _M
