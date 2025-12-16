require "spec.test_setup"

local executor = require "pricing.Executor"
local pricing_enums = require "pricing.utils.Enums"

local ERRORS = {
    MODULE_NAME_PRICING = "PRICING",
    PHASE_NOT_FOUND = "PHASE_NOT_FOUND",
}

describe("Executor", function()
    local snapshot
    local OPERATOR_NAME = "demo_operator"

    before_each(function()
        snapshot = assert:snapshot()
    end)

    after_each(function()
        snapshot:revert()
    end)

    it("should execute phases successfully", function()
        -- Arrange
        local internal_data = {
            facts = {
                operator_name = OPERATOR_NAME,
            },
            line_items = {
                {
                    item_context = {
                        source_object = { id = "charge1", offer_id = "offer1" },
                    },
                    components = {},
                    aggregated_prices = {},
                },
            },
            execution_phases = {
                "LIST_PRICE_PHASE",
                "DISCOUNT_PHASE",
                "TOTAL_PHASE",
            },
        }

        -- Act
        local result, err = executor:execute(internal_data)

        -- Assert
        assert.is_not_nil(result)
        assert.is_nil(err)
        assert.is_not_nil(result.line_items)
        assert.is_equal(#result.line_items, 1)
    end)

    it("should return error when phase not found", function()
        -- Arrange
        local internal_data = {
            facts = {
                operator_name = OPERATOR_NAME,
            },
            line_items = {},
            execution_phases = {
                "NON_EXISTENT_PHASE",
            },
        }

        -- Act
        local result, err = executor:execute(internal_data)

        -- Assert
        assert.is_nil(result)
        assert.is_not_nil(err)
        assert.is_equal(err.module, ERRORS.MODULE_NAME_PRICING)
        assert.is_equal(err.code, ERRORS.PHASE_NOT_FOUND)
    end)

    it("should execute all phases in order", function()
        -- Arrange
        local internal_data = {
            facts = {
                operator_name = OPERATOR_NAME,
            },
            line_items = {
                {
                    item_context = {
                        source_object = { id = "charge1", offer_id = "offer1" },
                    },
                    components = {},
                    aggregated_prices = {},
                },
            },
            execution_phases = {
                "LIST_PRICE_PHASE",
                "DISCOUNT_PHASE",
                "FEE_PHASE",
                "TAX_PHASE",
                "TOTAL_PHASE",
            },
        }

        -- Act
        local result, err = executor:execute(internal_data)

        -- Assert
        assert.is_not_nil(result)
        assert.is_nil(err)
        local line_item = result.line_items[1]
        -- Verify all phases executed
        assert.is_not_nil(line_item.aggregated_prices.list_price)
        assert.is_not_nil(line_item.aggregated_prices.discount_amount)
        assert.is_not_nil(line_item.aggregated_prices.fee_amount)
        assert.is_not_nil(line_item.aggregated_prices.tax_amount)
        assert.is_not_nil(line_item.aggregated_prices.net_price)
    end)

    it("should handle empty line items", function()
        -- Arrange
        local internal_data = {
            facts = {
                operator_name = OPERATOR_NAME,
            },
            line_items = {},
            execution_phases = {
                "LIST_PRICE_PHASE",
            },
        }

        -- Act
        local result, err = executor:execute(internal_data)

        -- Assert
        assert.is_not_nil(result)
        assert.is_nil(err)
        assert.is_equal(#result.line_items, 0)
    end)
end)
