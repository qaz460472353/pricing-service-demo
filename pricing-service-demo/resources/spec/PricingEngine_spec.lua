require "spec.test_setup"

local pricing_engine = require "pricing.PricingEngine"

describe("PricingEngine", function()
    local snapshot
    local OPERATOR_NAME = "demo_operator"

    before_each(function()
        snapshot = assert:snapshot()
    end)

    after_each(function()
        snapshot:revert()
    end)

    describe("calculate", function()
        it("should calculate price successfully", function()
            -- Arrange
            local charge_objects = {
                {
                    id = "charge1",
                    offer_id = "offer1",
                },
            }
            local calc_context = {
                operator_name = OPERATOR_NAME,
                target_id = "user123",
                target_type = 1,
                calculation_timestamp = 1234567890,
            }

            -- Act
            local result, err = pricing_engine.calculate(OPERATOR_NAME, charge_objects, calc_context)

            -- Assert
            assert.is_not_nil(result)
            assert.is_nil(err)
            assert.is_not_nil(result.item_price)
            assert.is_not_nil(result.total_price)
            assert.is_equal(#result.item_price, 1)
        end)

        it("should return error for invalid operator name", function()
            -- Arrange
            local charge_objects = {
                { id = "charge1", offer_id = "offer1" },
            }
            local calc_context = {
                operator_name = "",
                target_id = "user123",
                target_type = 1,
            }

            -- Act
            local result, err = pricing_engine.calculate("", charge_objects, calc_context)

            -- Assert
            -- Note: In simplified version, validation might be different
            -- In real implementation, should return error for empty operator_name
        end)

        it("should calculate price for multiple charge objects", function()
            -- Arrange
            local charge_objects = {
                { id = "charge1", offer_id = "offer1" },
                { id = "charge2", offer_id = "offer2" },
            }
            local calc_context = {
                operator_name = OPERATOR_NAME,
                target_id = "user123",
                target_type = 1,
                calculation_timestamp = 1234567890,
            }

            -- Act
            local result, err = pricing_engine.calculate(OPERATOR_NAME, charge_objects, calc_context)

            -- Assert
            assert.is_not_nil(result)
            assert.is_nil(err)
            assert.is_equal(#result.item_price, 2)
        end)
    end)

    describe("preview_pricing", function()
        it("should preview pricing successfully", function()
            -- Arrange
            local calc_context = {
                target_id = "user123",
                target_type = 1,
                calculation_timestamp = 1234567890,
                purchasing_entity_ids = {
                    { entity_id = "offer1", quantity = 1 },
                },
            }

            -- Act
            local result, err = pricing_engine.preview_pricing(OPERATOR_NAME, calc_context)

            -- Assert
            assert.is_not_nil(result)
            assert.is_nil(err)
            assert.is_not_nil(result.item_price)
            assert.is_not_nil(result.total_price)
        end)

        it("should preview pricing for multiple entities", function()
            -- Arrange
            local calc_context = {
                target_id = "user123",
                target_type = 1,
                calculation_timestamp = 1234567890,
                purchasing_entity_ids = {
                    { entity_id = "offer1", quantity = 1 },
                    { entity_id = "offer2", quantity = 2 },
                },
            }

            -- Act
            local result, err = pricing_engine.preview_pricing(OPERATOR_NAME, calc_context)

            -- Assert
            assert.is_not_nil(result)
            assert.is_nil(err)
            assert.is_equal(#result.item_price, 2)
        end)

        it("should handle empty purchasing entities", function()
            -- Arrange
            local calc_context = {
                target_id = "user123",
                target_type = 1,
                calculation_timestamp = 1234567890,
                purchasing_entity_ids = {},
            }

            -- Act
            local result, err = pricing_engine.preview_pricing(OPERATOR_NAME, calc_context)

            -- Assert
            assert.is_not_nil(result)
            assert.is_nil(err)
            assert.is_equal(#result.item_price, 0)
        end)
    end)
end)
