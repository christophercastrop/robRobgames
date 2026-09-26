--!strict
-- Servicio de ejemplo: demuestra el ciclo Init/Start del Loader. Sustituir en cada juego.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sdk = require(ReplicatedStorage.Sdk)
local Constants = require(ReplicatedStorage.Shared.Constants)

local log = Sdk.Log.scoped("HelloService")

local HelloService = {
	Name = "HelloService",
}

function HelloService.Init(_self: typeof(HelloService))
	log.debug("init")
end

function HelloService.Start(_self: typeof(HelloService))
	log.info("server started", { game = Constants.GAME_SLUG, sdk = Sdk.version })
end

return HelloService
