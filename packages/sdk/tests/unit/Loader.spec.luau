--!strict
local harness = require("../harness")
local Log = require("../../src/Log")
local Loader = require("../../src/Loader")

local describe, it, expect = harness.describe, harness.it, harness.expect

local function silence()
	Log.setSink(function() end)
end

describe("Loader", function()
	it("runs every Init before any Start, in registration order", function()
		silence()
		local calls = {}
		local function service(name: string)
			return {
				Name = name,
				Init = function()
					table.insert(calls, "init:" .. name)
				end,
				Start = function()
					table.insert(calls, "start:" .. name)
				end,
			}
		end
		local loader = Loader.new()
		loader:add(service("A")):add(service("B"))
		loader:start()
		Log.resetSink()
		expect(table.concat(calls, ",")).toBe("init:A,init:B,start:A,start:B")
		expect(loader:isStarted()).toBe(true)
	end)

	it("aborts before Start when an Init fails and names the service", function()
		silence()
		local started = false
		local loader = Loader.new()
		loader:add({
			Name = "Broken",
			Init = function()
				error("boom")
			end,
		})
		loader:add({
			Name = "Other",
			Start = function()
				started = true
			end,
		})
		expect(function()
			loader:start()
		end).toThrow("Init failed for service 'Broken'")
		Log.resetSink()
		expect(started).toBe(false)
	end)

	it("rejects duplicate names and late registration", function()
		local loader = Loader.new()
		loader:add({ Name = "A" })
		expect(function()
			loader:add({ Name = "A" })
		end).toThrow("duplicate service 'A'")
		silence()
		loader:start()
		Log.resetSink()
		expect(function()
			loader:add({ Name = "B" })
		end).toThrow("cannot add services after start()")
	end)

	it("returns registered services by name", function()
		local loader = Loader.new()
		local svc = { Name = "Economy" }
		loader:add(svc)
		expect(loader:get("Economy")).toBe(svc)
		expect(function()
			loader:get("Missing")
		end).toThrow("unknown service 'Missing'")
	end)
end)

return nil
