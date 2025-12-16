-- Service: pricing
-- File: Phases.lua
-- Description: Pricing calculation phases configuration

local base_price_calculator = require "pricing.calculator.BasePriceCalculator"
local discount_calculator = require "pricing.calculator.DiscountCalculator"
local fee_calculator = require "pricing.calculator.FeeCalculator"
local tax_calculator = require "pricing.calculator.TaxCalculator"
local price_aggregator = require "pricing.calculator.PriceAggregator"

local _M = {}

-- List Price Phase: Calculate base prices
_M.LIST_PRICE_PHASE = {
    phase_type = "LIST_PRICE_PHASE",
    preprocessors = {},
    calculators = {
        base_price_calculator.execute,
    },
    aggregators = {
        price_aggregator.aggregate_list_price,
    },
}

-- Discount Phase: Calculate discounts
_M.DISCOUNT_PHASE = {
    phase_type = "DISCOUNT_PHASE",
    preprocessors = {},
    calculators = {
        discount_calculator.execute,
    },
    aggregators = {
        price_aggregator.aggregate_discount_price,
    },
}

-- Fee Phase: Calculate fees
_M.FEE_PHASE = {
    phase_type = "FEE_PHASE",
    preprocessors = {},
    calculators = {
        fee_calculator.execute,
    },
    aggregators = {
        price_aggregator.aggregate_fee_amount,
    },
}

-- Tax Phase: Calculate taxes
_M.TAX_PHASE = {
    phase_type = "TAX_PHASE",
    preprocessors = {},
    calculators = {
        tax_calculator.execute,
    },
    aggregators = {
        price_aggregator.aggregate_tax_price,
    },
}

-- Total Phase: Calculate total prices
_M.TOTAL_PHASE = {
    phase_type = "TOTAL_PHASE",
    preprocessors = {},
    calculators = {},
    aggregators = {
        price_aggregator.aggregate_total_prices,
    },
}

return _M
