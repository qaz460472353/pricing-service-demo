-- Service: pricing
-- File: Executor.lua
-- Description: Executes pricing calculation phases in order

local logger = require "logging.Logger":new() -- luacheck: ignore
local checks = require "util.Checks"

-- Simplified error module
local errors = {
    MODULE_NAME = {
        PRICING = "PRICING",
    },
    ERROR = {
        PRICING = {
            PHASE_NOT_FOUND = "PHASE_NOT_FOUND",
        },
    },
}

local PHASES = require "pricing.struct.Phases"
local _M = {}

-- Execute pricing calculation phases
-- @param internal_data (table) - Pricing internal data structure
-- @return (table) - Calculated internal data
-- @return (table|nil) - Error object if execution fails
function _M:execute(internal_data)
    checks.assert(checks.is_non_empty_table(internal_data), "internal_data must be a non-empty table")

    local execution_phases = internal_data.execution_phases or {}

    for _, phase_type in ipairs(execution_phases) do
        local phase = PHASES[phase_type]
        if not phase then
            logger:error("Phase not found: %s", phase_type)
            return nil, {
                module = errors.MODULE_NAME.PRICING,
                code = errors.ERROR.PRICING.PHASE_NOT_FOUND,
            }
        end

        -- Execute preprocessors
        for _, preprocessor_fn in ipairs(phase.preprocessors or {}) do
            local _, preprocess_err = preprocessor_fn(internal_data)
            if preprocess_err then
                logger:error("Preprocessor failed in phase %s: %s", phase_type, preprocess_err)
                return nil, preprocess_err
            end
        end

        -- Execute calculators
        for _, calculator_fn in ipairs(phase.calculators or {}) do
            local _, calc_err = calculator_fn(internal_data)
            if calc_err then
                logger:error("Calculator failed in phase %s: %s", phase_type, calc_err)
                return nil, calc_err
            end
        end

        -- Execute aggregators
        for _, aggregator_fn in ipairs(phase.aggregators or {}) do
            local _, aggregate_err = aggregator_fn(internal_data)
            if aggregate_err then
                logger:error("Aggregator failed in phase %s: %s", phase_type, aggregate_err)
                return nil, aggregate_err
            end
        end
    end

    return internal_data
end

return _M
