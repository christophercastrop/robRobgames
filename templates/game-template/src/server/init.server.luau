--!strict
-- Punto de entrada del servidor: registra servicios y arranca. La línea "server started" es la que verifica
-- el checklist del Studio plane (ops/ROBLOX_SETUP.md, acción 6).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sdk = require(ReplicatedStorage.Sdk)

local loader = Sdk.Loader.new()
loader:add(require(script.HelloService))
loader:start()
