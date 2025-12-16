require "spec.test_setup"

local base_price_calculator = require "pricing.calculator.BasePriceCalculator"
local pricing_enums = require "pricing.utils.Enums"

local COMPONENT_TYPE_ORIGIN = pricing_enums.COMPONENT_TYPE.ORIGIN

describe("BasePriceCalculator", function()
    local snapshot
    local OPERATOR_NAME = "demo_operator"

    before_each(function()
        snapshot = assert:snapshot()
    end)

    after_each(function()
        snapshot:revert()
    end)

    it("should calculate base price successfully", function()
        -- Arrange
        local internal_data = {
            line_items = {
                {
                    item_context = {
                        source_object = {
                            id = "charge1",
                            offer_id = "offer1",
                        },
                    },
                    components = {},
                    aggregated_prices = {},
                },
            },
        }

        -- Act
        local success, err = base_price_calculator.execute(internal_data)

        -- Assert
        assert.is_true(success)
        assert.is_nil(err)
        assert.is_not_nil(internal_data.line_items[1].components)
        assert.is_equal(#internal_data.line_items[1].components, 1)
        assert.is_equal(internal_data.line_items[1].components[1].type, COMPONENT_TYPE_ORIGIN)
        assert.is_equal(internal_data.line_items[1].aggregated_prices.list_price, 100.00)
    end)

    it("should calculate base price for multiple line items", function()
        -- Arrange
        local internal_data = {
            line_items = {
                {
                    item_context = {
                        source_object = { id = "charge1", offer_id = "offer1" },
                    },
                    components = {},
                    aggregated_prices = {},
                },
                {
                    item_context = {
                        source_object = { id = "charge2", offer_id = "offer2" },
                    },
                    components = {},
                    aggregated_prices = {},
                },
            },
        }

        -- Act
        local success, err = base_price_calculator.execute(internal_data)

        -- Assert
        assert.is_true(success)
        assert.is_nil(err)
        assert.is_equal(#internal_data.line_items, 2)
        for _, line_item in ipairs(internal_data.line_items) do
            assert.is_equal(line_item.aggregated_prices.list_price, 100.00)
        end
    end)

    it("should handle empty line items gracefully", function()
        -- Arrange
        local internal_data = {
            line_items = {},
        }

        -- Act
        local success, err = base_price_calculator.execute(internal_data)

        -- Assert
        assert.is_true(success)
        assert.is_nil(err)
        assert.is_equal(#internal_data.line_items, 0)
    end)
end)
