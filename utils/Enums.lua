-- Service: pricing
-- File: Enums.lua
-- Description: Pricing service enumerations and constants

local _M = {}

-- Phase types for pricing calculation
_M.PHASE_TYPE = {
    LIST_PRICE_PHASE = "LIST_PRICE_PHASE",
    DISCOUNT_PHASE = "DISCOUNT_PHASE",
    PRORATION_PHASE = "PRORATION_PHASE",
    FEE_PHASE = "FEE_PHASE",
    TAX_PHASE = "TAX_PHASE",
    TOTAL_PHASE = "TOTAL_PHASE",
}

-- Pricing component types
_M.COMPONENT_TYPE = {
    ORIGIN = "origin",
    FEE = "fee",
    TAX = "tax",
    DISCOUNT = "discount",
    PRORATION = "proration",
}

-- Line item source types
_M.LINE_ITEM_SOURCE_TYPE = {
    CHARGE_OBJECT = "CHARGE_OBJECT",
    ENTITY = "ENTITY",
}

return _M
