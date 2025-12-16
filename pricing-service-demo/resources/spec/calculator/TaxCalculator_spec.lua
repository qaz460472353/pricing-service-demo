require "spec.test_setup"

local tax_calculator = require "pricing.calculator.TaxCalculator"
local pricing_enums = require "pricing.utils.Enums"

local COMPONENT_TYPE_TAX = pricing_enums.COMPONENT_TYPE.TAX

describe("TaxCalculator", function()
    local snapshot

    before_each(function()
        snapshot = assert:snapshot()
    end)

    after_each(function()
        snapshot:revert()
    end)

    it("should calculate tax amount correctly", function()
        -- Arrange
        local internal_data = {
            line_items = {
                {
                    aggregated_prices = {
                        list_price = 100.00,
                        discount_amount = 10.00,
                        fee_amount = 5.00,
                    },
                    components = {},
                },
            },
        }

        -- Act
        local success, err = tax_calculator.execute(internal_data)

        -- Assert
        assert.is_true(success)
        assert.is_nil(err)
        local line_item = internal_data.line_items[1]
        -- Tax on: (100 - 10 + 5) * 0.08 = 7.60
        local expected_tax = (100.00 - 10.00 + 5.00) * 0.08
        assert.is_equal(line_item.aggregated_prices.tax_amount, expected_tax)
        assert.is_equal(#line_item.components, 1)
        assert.is_equal(line_item.components[1].type, COMPONENT_TYPE_TAX)
    end)

    it("should calculate tax for zero taxable amount", function()
        -- Arrange
        local internal_data = {
            line_items = {
                {
                    aggregated_prices = {
                        list_price = 0,
                        discount_amount = 0,
                        fee_amount = 0,
                    },
                    components = {},
                },
            },
        }

        -- Act
        local success, err = tax_calculator.execute(internal_data)

        -- Assert
        assert.is_true(success)
        assert.is_nil(err)
        assert.is_equal(internal_data.line_items[1].aggregated_prices.tax_amount, 0)
    end)

    it("should handle missing aggregated prices gracefully", function()
        -- Arrange
        local internal_data = {
            line_items = {
                {
                    aggregated_prices = {
                        list_price = 100.00,
                    },
                    components = {},
                },
            },
        }

        -- Act
        local success, err = tax_calculator.execute(internal_data)

        -- Assert
        assert.is_true(success)
        assert.is_nil(err)
        -- Should use 0 for missing discount_amount and fee_amount
        local expected_tax = 100.00 * 0.08
        assert.is_equal(internal_data.line_items[1].aggregated_prices.tax_amount, expected_tax)
    end)
end)
