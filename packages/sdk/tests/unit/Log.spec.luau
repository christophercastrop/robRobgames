--!strict
local harness = require("../harness")
local Log = require("../../src/Log")

local describe, it, expect = harness.describe, harness.it, harness.expect

describe("Log", function()
	it("formats lines with the factory prefix and sorted fields", function()
		local line = Log.format("info", "Economy", "granted", { amount = 5, currency = "coins" })
		expect(line).toBe("[factory] info Economy: granted {amount=5, currency=coins}")
	end)

	it("respects the minimum level", function()
		local lines = {}
		Log.setSink(function(_level, line)
			table.insert(lines, line)
		end)
		Log.setMinLevel("warn")
		local log = Log.scoped("Test")
		log.info("hidden")
		log.warn("shown")
		Log.setMinLevel("info")
		Log.resetSink()
		expect(#lines).toBe(1)
		expect(lines[1]).toContain("warn Test: shown")
	end)
end)

return nil
