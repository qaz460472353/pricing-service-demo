-- Example usage of Pricing Service
-- This file demonstrates how to use the pricing engine

local pricing_engine = require "pricing.PricingEngine"

-- Example 1: Preview pricing for purchasing entities
print("=== Example 1: Preview Pricing ===")
local calc_context = {
    operator_name = "demo_operator",
    target_id = "user123",
    target_type = 1,
    calculation_timestamp = os.time(),
    purchasing_entity_ids = {
        { entity_id = "offer1", quantity = 1 },
        { entity_id = "offer2", quantity = 2 },
    }
}

local result, err = pricing_engine.preview_pricing("demo_operator", calc_context)
if err then
    print("Error: ", err)
else
    print("Preview Pricing Result:")
    print("  Total Price: $" .. string.format("%.2f", result.total_price.amount))
    print("  Tax Amount: $" .. string.format("%.2f", result.total_price.tax_amount))
    print("  Discount Amount: $" .. string.format("%.2f", result.total_price.discount_amount))
    print("  Fee Amount: $" .. string.format("%.2f", result.total_price.fee_amount))
    print("\n  Item Prices:")
    for i, item in ipairs(result.item_price) do
        print(string.format("    Item %d:", i))
        print(string.format("      List Price: $%.2f", item.list_price))
        print(string.format("      Discount: $%.2f", item.discount_amount))
        print(string.format("      Fee: $%.2f", item.fee_amount))
        print(string.format("      Tax: $%.2f", item.tax_amount))
        print(string.format("      Net Price: $%.2f", item.net_price))
    end
end

print("\n=== Example 2: Calculate Price from Charge Objects ===")
local charge_objects = {
    {
        id = "charge1",
        offer_id = "offer1",
        quantity = 1,
    },
    {
        id = "charge2",
        offer_id = "offer2",
        quantity = 1,
    }
}

local calc_context2 = {
    operator_name = "demo_operator",
    target_id = "user123",
    target_type = 1,
    calculation_timestamp = os.time(),
}

local result2, err2 = pricing_engine.calculate("demo_operator", charge_objects, calc_context2)
if err2 then
    print("Error: ", err2)
else
    print("Calculation Result:")
    print("  Total Price: $" .. string.format("%.2f", result2.total_price.amount))
    print("  Number of Items: " .. #result2.item_price)
end
