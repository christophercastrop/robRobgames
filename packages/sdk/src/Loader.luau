--!strict
-- Ciclo de vida de servicios (servidor) y controllers (cliente) en dos fases:
--   1. Init: en orden de registro; preparar estado, sin depender de otros servicios ya arrancados.
--   2. Start: en el mismo orden, sólo si todos los Init tuvieron éxito.
-- Start no debe bloquear: los bucles se lanzan con task.spawn dentro del propio servicio.
-- Un fallo aborta el arranque con un error que nombra el servicio (fail fast: un servidor a medias es peor).

local Log = require("./Log")

export type Service = {
	Name: string,
	Init: ((self: any) -> ())?,
	Start: ((self: any) -> ())?,
	[any]: any,
}

export type Loader = {
	add: (self: Loader, service: Service) -> Loader,
	get: (self: Loader, name: string) -> Service,
	start: (self: Loader) -> (),
	isStarted: (self: Loader) -> boolean,
	_services: { Service },
	_byName: { [string]: Service },
	_started: boolean,
}

local log = Log.scoped("Loader")

local function runPhase(services: { Service }, phase: "Init" | "Start")
	for _, service in services do
		local callback = service[phase]
		if callback ~= nil then
			local ok, err = pcall(callback, service)
			if not ok then
				log.error(`{phase} failed`, { service = service.Name, error = err })
				error(`[factory] {phase} failed for service '{service.Name}': {err}`, 0)
			end
		end
	end
end

local LoaderClass = {}

function LoaderClass.add(self: Loader, service: Service): Loader
	assert(not self._started, "cannot add services after start()")
	assert(type(service.Name) == "string" and service.Name ~= "", "service must have a non-empty Name")
	assert(self._byName[service.Name] == nil, `duplicate service '{service.Name}'`)
	table.insert(self._services, service)
	self._byName[service.Name] = service
	return self
end

function LoaderClass.get(self: Loader, name: string): Service
	local service = self._byName[name]
	assert(service ~= nil, `unknown service '{name}'`)
	return service
end

function LoaderClass.start(self: Loader)
	assert(not self._started, "start() called twice")
	self._started = true
	runPhase(self._services, "Init")
	runPhase(self._services, "Start")
	log.info("started", { services = #self._services })
end

function LoaderClass.isStarted(self: Loader): boolean
	return self._started
end

local Loader = {}

function Loader.new(): Loader
	local self = {
		_services = {},
		_byName = {},
		_started = false,
	}
	return (setmetatable(self, { __index = LoaderClass }) :: any) :: Loader
end

return Loader
