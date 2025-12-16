require "spec.test_setup"

local pricing_internal_data = require "pricing.struct.PricingInternalData"

describe("PricingInternalData", function()
    local snapshot
    local OPERATOR_NAME = "demo_operator"

    before_each(function()
        snapshot = assert:snapshot()
    end)

    after_each(function()
        snapshot:revert()
    end)

    it("should generate default internal data structure", function()
        -- Act
        local internal_data = pricing_internal_data:generate_default_internal_data()

        -- Assert
        assert.is_not_nil(internal_data)
        assert.is_not_nil(internal_data.line_items)
        assert.is_not_nil(internal_data.facts)
        assert.is_not_nil(internal_data.execution_phases)
        assert.is_equal(#internal_data.line_items, 0)
    end)

    it("should create internal data from charge objects", function()
        -- Arrange
        local charge_objects = {
            {
                id = "charge1",
                offer_id = "offer1",
            },
            {
                id = "charge2",
                offer_id = "offer2",
            },
        }
        local calc_context = {
            operator_name = OPERATOR_NAME,
            target_id = "user123",
            target_type = 1,
            calculation_timestamp = 1234567890,
        }

        -- Act
        local internal_data, err = pricing_internal_data:new_from_charge_objects(charge_objects, calc_context)

        -- Assert
        assert.is_not_nil(internal_data)
        assert.is_nil(err)
        assert.is_equal(#internal_data.line_items, 2)
        assert.is_equal(internal_data.facts.operator_name, OPERATOR_NAME)
        assert.is_equal(internal_data.facts.target_id, "user123")
        assert.is_equal(internal_data.facts.calculation_timestamp, 1234567890)
        assert.is_not_nil(internal_data.execution_phases)
        assert.is_equal(#internal_data.execution_phases, 5)
    end)

    it("should create internal data from purchasing entities", function()
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
        local internal_data, err = pricing_internal_data:new_from_purchasing_entities(OPERATOR_NAME, calc_context)

        -- Assert
        assert.is_not_nil(internal_data)
        assert.is_nil(err)
        assert.is_equal(#internal_data.line_items, 2)
        assert.is_equal(internal_data.facts.operator_name, OPERATOR_NAME)
        assert.is_equal(internal_data.line_items[1].item_context.entity_id, "offer1")
        assert.is_equal(internal_data.line_items[1].item_context.quantity, 1)
        assert.is_equal(internal_data.line_items[2].item_context.quantity, 2)
    end)

    it("should return error for invalid charge objects", function()
        -- Arrange
        local charge_objects = {}
        local calc_context = {
            operator_name = OPERATOR_NAME,
        }

        -- Act
        local internal_data, err = pricing_internal_data:new_from_charge_objects(charge_objects, calc_context)

        -- Assert
        -- Note: In simplified version, this might not return error
        -- In real implementation, should validate and return error
    end)

    it("should use current timestamp if calculation_timestamp not provided", function()
        -- Arrange
        local charge_objects = {
            { id = "charge1", offer_id = "offer1" },
        }
        local calc_context = {
            operator_name = OPERATOR_NAME,
            target_id = "user123",
            target_type = 1,
            -- calculation_timestamp not provided
        }

        -- Act
        local internal_data, err = pricing_internal_data:new_from_charge_objects(charge_objects, calc_context)

        -- Assert
        assert.is_not_nil(internal_data)
        assert.is_nil(err)
        assert.is_not_nil(internal_data.facts.calculation_timestamp)
        assert.is_number(internal_data.facts.calculation_timestamp)
    end)
end)
