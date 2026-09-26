--!strict
-- Punto de entrada del Factory SDK. Módulos núcleo previstos (docs/research/10_SHARED_GAME_SDK.md §2):
-- Net, PlayerData, Economy, Products, Policy, RemoteConfig, Analytics, LiveOps, Moderation… (backlog P0-08..P0-11).

return {
	Log = require("@self/Log"),
	Loader = require("@self/Loader"),
	version = "0.1.0",
}
