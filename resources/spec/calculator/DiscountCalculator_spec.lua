require "spec.test_setup"

local discount_calculator = require "pricing.calculator.DiscountCalculator"
local pricing_enums = require "pricing.utils.Enums"

local COMPONENT_TYPE_DISCOUNT = pricing_enums.COMPONENT_TYPE.DISCOUNT

describe("DiscountCalculator", function()
    local snapshot

    before_each(function()
        snapshot = assert:snapshot()
    end)

    after_each(function()
        snapshot:revert()
    end)

    it("should calculate discount amount correctly", function()
        -- Arrange
        local list_price = 100.00
        local internal_data = {
            line_items = {
                {
                    aggregated_prices = {
                        list_price = list_price,
                    },
                    components = {},
                },
            },
        }

        -- Act
        local success, err = discount_calculator.execute(internal_data)

        -- Assert
        assert.is_true(success)
        assert.is_nil(err)
        local line_item = internal_data.line_items[1]
        assert.is_equal(line_item.aggregated_prices.discount_amount, 10.00) -- 10% of 100
        assert.is_equal(#line_item.components, 1)
        assert.is_equal(line_item.components[1].type, COMPONENT_TYPE_DISCOUNT)
        assert.is_equal(line_item.components[1].amount, -10.00) -- Negative for discount
    end)

    it("should calculate discount for zero list price", function()
        -- Arrange
        local internal_data = {
            line_items = {
                {
                    aggregated_prices = {
                        list_price = 0,
                    },
                    components = {},
                },
            },
        }

        -- Act
        local success, err = discount_calculator.execute(internal_data)

        -- Assert
        assert.is_true(success)
        assert.is_nil(err)
        assert.is_equal(internal_data.line_items[1].aggregated_prices.discount_amount, 0)
    end)

    it("should calculate discount for multiple items", function()
        -- Arrange
        local internal_data = {
            line_items = {
                {
                    aggregated_prices = { list_price = 100.00 },
                    components = {},
                },
                {
                    aggregated_prices = { list_price = 200.00 },
                    components = {},
                },
            },
        }

        -- Act
        local success, err = discount_calculator.execute(internal_data)

        -- Assert
        assert.is_true(success)
        assert.is_nil(err)
        assert.is_equal(internal_data.line_items[1].aggregated_prices.discount_amount, 10.00)
        assert.is_equal(internal_data.line_items[2].aggregated_prices.discount_amount, 20.00)
    end)
end)
