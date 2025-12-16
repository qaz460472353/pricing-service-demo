require "spec.test_setup"

local output_adapter = require "pricing.struct.output.Adapter"

describe("OutputAdapter", function()
    local snapshot

    before_each(function()
        snapshot = assert:snapshot()
    end)

    after_each(function()
        snapshot:revert()
    end)

    it("should convert internal data to output format", function()
        -- Arrange
        local internal_data = {
            line_items = {
                {
                    item_context = {
                        source_object = { id = "charge1" },
                    },
                    aggregated_prices = {
                        list_price = 100.00,
                        discount_amount = 10.00,
                        fee_amount = 5.00,
                        tax_amount = 7.60,
                        net_price = 102.60,
                    },
                },
            },
        }

        -- Act
        local result, err = output_adapter.convert(internal_data)

        -- Assert
        assert.is_not_nil(result)
        assert.is_nil(err)
        assert.is_not_nil(result.item_price)
        assert.is_not_nil(result.total_price)
        assert.is_equal(#result.item_price, 1)
        assert.is_equal(result.item_price[1].charge_id, "charge1")
        assert.is_equal(result.item_price[1].net_price, 102.60)
        assert.is_equal(result.total_price.amount, 102.60)
    end)

    it("should aggregate total prices correctly", function()
        -- Arrange
        local internal_data = {
            line_items = {
                {
                    item_context = { source_object = { id = "charge1" } },
                    aggregated_prices = {
                        list_price = 100.00,
                        discount_amount = 10.00,
                        fee_amount = 5.00,
                        tax_amount = 7.60,
                        net_price = 102.60,
                    },
                },
                {
                    item_context = { source_object = { id = "charge2" } },
                    aggregated_prices = {
                        list_price = 200.00,
                        discount_amount = 20.00,
                        fee_amount = 10.00,
                        tax_amount = 15.20,
                        net_price = 205.20,
                    },
                },
            },
        }

        -- Act
        local result, err = output_adapter.convert(internal_data)

        -- Assert
        assert.is_not_nil(result)
        assert.is_nil(err)
        assert.is_equal(#result.item_price, 2)
        assert.is_equal(result.total_price.amount, 307.80) -- 102.60 + 205.20
        assert.is_equal(result.total_price.tax_amount, 22.80) -- 7.60 + 15.20
        assert.is_equal(result.total_price.discount_amount, 30.00) -- 10.00 + 20.00
        assert.is_equal(result.total_price.fee_amount, 15.00) -- 5.00 + 10.00
    end)

    it("should handle empty line items", function()
        -- Arrange
        local internal_data = {
            line_items = {},
        }

        -- Act
        local result, err = output_adapter.convert(internal_data)

        -- Assert
        assert.is_not_nil(result)
        assert.is_nil(err)
        assert.is_equal(#result.item_price, 0)
        assert.is_equal(result.total_price.amount, 0)
    end)

    it("should handle missing charge_id gracefully", function()
        -- Arrange
        local internal_data = {
            line_items = {
                {
                    item_context = {
                        -- source_object not provided
                    },
                    aggregated_prices = {
                        list_price = 100.00,
                        net_price = 100.00,
                    },
                },
            },
        }

        -- Act
        local result, err = output_adapter.convert(internal_data)

        -- Assert
        assert.is_not_nil(result)
        assert.is_nil(err)
        assert.is_nil(result.item_price[1].charge_id)
    end)
end)
