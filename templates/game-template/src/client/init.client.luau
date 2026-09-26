--!strict
-- Punto de entrada del cliente. El cliente sólo presenta y pide; nunca decide economía ni progreso (12_SECURITY.md).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sdk = require(ReplicatedStorage.Sdk)

local loader = Sdk.Loader.new()
loader:start()
