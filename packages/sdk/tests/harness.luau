--!strict
-- Mini harness de tests unitarios para Lune (lógica pura, sin APIs del engine).
-- Los tests de engine usan Jest-Lua vía Open Cloud Luau Execution (backlog P0-06).

export type Test = { name: string, fn: () -> () }

local harness = {}
local registry: { Test } = {}
local currentPrefix = ""

function harness.describe(name: string, body: () -> ())
	local previous = currentPrefix
	currentPrefix = if previous == "" then name else `{previous} > {name}`
	body()
	currentPrefix = previous
end

function harness.it(name: string, fn: () -> ())
	table.insert(registry, { name = if currentPrefix == "" then name else `{currentPrefix} > {name}`, fn = fn })
end

local function fail(message: string)
	error(message, 3)
end

function harness.expect(actual: any)
	return {
		toBe = function(expected: any)
			if actual ~= expected then
				fail(`expected {tostring(expected)}, got {tostring(actual)}`)
			end
		end,
		toContain = function(fragment: string)
			if type(actual) ~= "string" or string.find(actual, fragment, 1, true) == nil then
				fail(`expected "{tostring(actual)}" to contain "{fragment}"`)
			end
		end,
		toThrow = function(fragment: string?)
			local ok, err = pcall(actual)
			if ok then
				fail("expected function to throw")
			elseif fragment ~= nil and string.find(tostring(err), fragment, 1, true) == nil then
				fail(`expected error containing "{fragment}", got "{tostring(err)}"`)
			end
		end,
	}
end

function harness.run(): (number, number)
	local passed, failed = 0, 0
	for _, test in registry do
		local ok, err = pcall(test.fn)
		if ok then
			passed += 1
			print(`  ok   {test.name}`)
		else
			failed += 1
			print(`  FAIL {test.name}\n       {tostring(err)}`)
		end
	end
	table.clear(registry)
	return passed, failed
end

return harness
