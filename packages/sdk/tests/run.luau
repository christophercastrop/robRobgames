--!strict
-- Runner de tests unitarios con Lune: `lune run packages/sdk/tests/run` desde la raíz del repo.
local fs = require("@lune/fs")
local process = require("@lune/process")
local harness = require("./harness")

-- Los requires dinámicos no se tipan; se resuelven respecto a este fichero.
local requireDynamic = (require :: any) :: (string) -> any

local UNIT_DIR = "packages/sdk/tests/unit"

local files = {}
for _, name in fs.readDir(UNIT_DIR) do
	if string.sub(name, -10) == ".spec.luau" then
		table.insert(files, name)
	end
end
table.sort(files)

local totalPassed, totalFailed = 0, 0
for _, name in files do
	print(name)
	requireDynamic("./unit/" .. string.sub(name, 1, -6))
	local passed, failed = harness.run()
	totalPassed += passed
	totalFailed += failed
end

print(`\n{totalPassed} passed, {totalFailed} failed ({#files} files)`)
if totalFailed > 0 or #files == 0 then
	process.exit(1)
end
