--!strict
-- Logger estructurado del SDK. Salida única "[factory] <nivel> <scope>: <mensaje> {campos}" para que
-- get_console_output (Studio MCP) y los server logs de Open Cloud se puedan filtrar por prefijo.

export type Level = "debug" | "info" | "warn" | "error"
export type Fields = { [string]: any }
export type Sink = (level: Level, line: string) -> ()

local LEVEL_ORDER: { [Level]: number } = { debug = 1, info = 2, warn = 3, error = 4 }

local function defaultSink(level: Level, line: string)
	if level == "warn" or level == "error" then
		warn(line)
	else
		print(line)
	end
end

local state = {
	sink = defaultSink :: Sink,
	minLevel = "info" :: Level,
}

local function formatFields(fields: Fields?): string
	if fields == nil then
		return ""
	end
	local keys = {}
	for key in fields do
		table.insert(keys, key)
	end
	table.sort(keys)
	local parts = table.create(#keys)
	for _, key in keys do
		table.insert(parts, `{key}={tostring(fields[key])}`)
	end
	return " {" .. table.concat(parts, ", ") .. "}"
end

local Log = {}

-- Construye la línea sin emitirla (útil en tests y para enviar a otros destinos).
function Log.format(level: Level, scope: string, message: string, fields: Fields?): string
	return `[factory] {level} {scope}: {message}{formatFields(fields)}`
end

function Log.emit(level: Level, scope: string, message: string, fields: Fields?)
	if LEVEL_ORDER[level] < LEVEL_ORDER[state.minLevel] then
		return
	end
	state.sink(level, Log.format(level, scope, message, fields))
end

export type Logger = {
	debug: (message: string, fields: Fields?) -> (),
	info: (message: string, fields: Fields?) -> (),
	warn: (message: string, fields: Fields?) -> (),
	error: (message: string, fields: Fields?) -> (),
}

-- Logger ligado a un scope (normalmente el nombre del servicio).
function Log.scoped(scope: string): Logger
	return {
		debug = function(message: string, fields: Fields?)
			Log.emit("debug", scope, message, fields)
		end,
		info = function(message: string, fields: Fields?)
			Log.emit("info", scope, message, fields)
		end,
		warn = function(message: string, fields: Fields?)
			Log.emit("warn", scope, message, fields)
		end,
		error = function(message: string, fields: Fields?)
			Log.emit("error", scope, message, fields)
		end,
	}
end

function Log.setSink(sink: Sink)
	state.sink = sink
end

function Log.resetSink()
	state.sink = defaultSink
end

function Log.setMinLevel(level: Level)
	state.minLevel = level
end

return Log
