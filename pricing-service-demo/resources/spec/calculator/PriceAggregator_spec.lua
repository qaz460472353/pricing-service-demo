require "spec.test_setup"

local price_aggregator = require "pricing.calculator.PriceAggregator"

describe("PriceAggregator", function()
    local snapshot

    before_each(function()
        snapshot = assert:snapshot()
    end)

    after_each(function()
        snapshot:revert()
    end)

    it("should aggregate total prices correctly", function()
        -- Arrange
        local internal_data = {
            line_items = {
                {
                    aggregated_prices = {
                        list_price = 100.00,
                        discount_amount = 10.00,
                        fee_amount = 5.00,
                        tax_amount = 7.60,
                    },
                },
            },
        }

        -- Act
        local success = price_aggregator.aggregate_total_prices(internal_data)

        -- Assert
        assert.is_true(success)
        local line_item = internal_data.line_items[1]
        -- net_price = list_price - discount_amount + fee_amount + tax_amount
        -- net_price = 100 - 10 + 5 + 7.60 = 102.60
        local expected_net = 100.00 - 10.00 + 5.00 + 7.60
        assert.is_equal(line_item.aggregated_prices.net_price, expected_net)
    end)

    it("should aggregate total prices for multiple items", function()
        -- Arrange
        local internal_data = {
            line_items = {
                {
                    aggregated_prices = {
                        list_price = 100.00,
                        discount_amount = 10.00,
                        fee_amount = 5.00,
                        tax_amount = 7.60,
                    },
                },
                {
                    aggregated_prices = {
                        list_price = 200.00,
                        discount_amount = 20.00,
                        fee_amount = 10.00,
                        tax_amount = 15.20,
                    },
                },
            },
        }

        -- Act
        local success = price_aggregator.aggregate_total_prices(internal_data)

        -- Assert
        assert.is_true(success)
        assert.is_equal(internal_data.line_items[1].aggregated_prices.net_price, 102.60)
        assert.is_equal(internal_data.line_items[2].aggregated_prices.net_price, 205.20)
    end)

    it("should handle zero values correctly", function()
        -- Arrange
        local internal_data = {
            line_items = {
                {
                    aggregated_prices = {
                        list_price = 0,
                        discount_amount = 0,
                        fee_amount = 0,
                        tax_amount = 0,
                    },
                },
            },
        }

        -- Act
        local success = price_aggregator.aggregate_total_prices(internal_data)

        -- Assert
        assert.is_true(success)
        assert.is_equal(internal_data.line_items[1].aggregated_prices.net_price, 0)
    end)

    it("should handle missing aggregated prices", function()
        -- Arrange
        local internal_data = {
            line_items = {
                {
                    aggregated_prices = {
                        list_price = 100.00,
                    },
                },
            },
        }

        -- Act
        local success = price_aggregator.aggregate_total_prices(internal_data)

        -- Assert
        assert.is_true(success)
        -- Should use 0 for missing values
        assert.is_equal(internal_data.line_items[1].aggregated_prices.net_price, 100.00)
    end)
end)
