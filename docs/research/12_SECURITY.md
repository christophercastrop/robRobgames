# 12 — Security, Anti-Exploit y Data Safety

> Alcance: **defensa de nuestros propios juegos**. No se desarrollan herramientas ofensivas contra terceros.

## 1. Principio: NEVER TRUST THE CLIENT

Modelo de amenaza [INFERENCIA, patrón conocido de la plataforma]: el cliente está bajo control total del atacante (ejecutores de scripts pueden
leer/modificar cualquier cosa replicada al cliente, invocar cualquier RemoteEvent/RemoteFunction con argumentos arbitrarios y a cualquier ritmo,
y mover su personaje — el servidor tiene *network ownership* del personaje cedida al cliente por defecto).

Reglas de arquitectura (enforced por SDK + auditoría):

1. **Estado autoritativo sólo en servidor**: monedas, inventario, progreso, cooldowns, precios, resultados de RNG, posiciones relevantes para recompensas.
2. **El cliente pide, el servidor decide**: los remotes transmiten *intenciones* (`RequestUpgrade(upgradeId)`), nunca resultados (`AddCoins(500)`).
3. **Validación total de payloads**: tipos, rangos, enteros, NaN/inf, longitud de strings, IDs existentes, pertenencia (¿el objeto es del jugador?),
   distancia/línea de visión al interactuar, estado de la máquina de estados del jugador.
4. **Rate limiting por jugador y por remote** (token bucket en `Net`), con sanción progresiva (ignorar → flag → kick → restricción temporal vía User Restrictions API).
5. **RemoteFunctions cliente←servidor prohibidas** (`InvokeClient` puede colgar al servidor). Servidor→cliente sólo eventos.
6. **Nada secreto en ReplicatedStorage** (tablas de loot con pesos ocultos, lógica anti-cheat, claves).
7. **Compras sólo por `ProcessReceipt`** idempotente; ownership de passes verificado en servidor (`UserOwnsGamePassAsync`) y cacheado con TTL.
8. **Transacciones económicas idempotentes** con `txId`; ledger de auditoría (muestreo) para detectar anomalías.

Guía oficial de referencia [HV]: `scripting/security/` del Creator Hub — *security tactics* (never trust the client, server authority, security by design),
*client-server boundary* (validación de contexto/tipos/valores, **NaN**, rate limiting con token bucket, ProximityPrompt/ClickDetector/DragDetector, DataStore y
MarketplaceService), *network ownership* (validación de movimiento), *server-side detection* (heurísticas, **honeypots**, consecuencias), *access control*
(teleports seguros; todo lo replicado al cliente es legible/decompilable), *third-party vulnerabilities*.

## 2. Patrones de explotación y controles

| Ataque | Mecanismo | Control |
|---|---|---|
| RemoteEvent abuse | Disparar remotes con args arbitrarios/masivos | Zap IDL (tipos), validadores, rate limit, sanciones |
| RemoteFunction abuse | Respuestas manipuladas, yields infinitos | Sin `InvokeClient`; timeouts; servidor nunca confía en return del cliente |
| Speed hacks | WalkSpeed/CFrame modificados en cliente | Validación de desplazamiento por tick (distancia máx. por Δt con tolerancia de latencia); rewind/teleport back; flags |
| Teleport hacks | CFrame arbitrario | Checkpoints validados en servidor; recompensas por zona verifican trayectoria/tiempo mínimo |
| Noclip / fly | Física local | Raycasts de sanity en servidor para zonas críticas; `HumanoidStateType` inválidos |
| Forged purchases | Llamar al remote de "grant" o falsificar "compra completada" | Grants **sólo** en `ProcessReceipt`/verificación server-side; no existe remote de grant |
| Currency exploits | Remotes de recompensa repetibles, farm automatizado | Recompensas derivadas de estado de servidor, cooldowns server-side, límites por fuente/minuto, detección de outliers (z-score de ingreso/hora) |
| Duplication | Carreras entre guardado, trading, teleports y leave | Session locking (ProfileStore), trades atómicos en un solo `UpdateAsync`/transacción de perfil, bloqueo de inventario durante teleport |
| Inventory exploits | Equipar/vender ítems no poseídos | Ownership check en cada operación |
| Replay | Reenviar mensajes válidos | Nonces/seq por acción de alto valor; estado (cooldown) que invalida el replay |
| Rate abuse / DoS de servidor | Spam de remotes pesados | Token bucket + coste por remote; desconexión |
| DataStore corruption | Escribir datos malformados vía flujos legítimos | Esquema validado antes de guardar; `UpdateAsync` con validación; versiones y rollback |
| Backdoors en assets | Modelos del Creator Store con `require(<id>)`, `getfenv`, `loadstring`, scripts ofuscados | Prohibido insertar assets externos no auditados; scanner estático en CI (§7); `LoadStringEnabled=false` |
| Chat/texto de usuario | Texto sin filtrar mostrado a otros | `TextService:FilterStringAsync` obligatorio para cualquier texto de usuario visible a otros (SDK `Moderation`); Roblox puede **retirar el juego** si detecta que no se filtra [HV `safety.md`] |
| Jugadores disruptivos / alts | Acoso, estafas, reincidencia con cuentas alternativas | `Players:BanAsync()` con razón pública/privada y aplicación a alts conocidas; `Kick` para expulsión puntual; `IsVerified` para gating de ranking/trading [HV `safety.md`, `production/bans.md`] |
| Detección de cheats | Exploits no previstos | Heurísticas server-side + **honeypots** (remotes/objetos señuelo que sólo un exploiter tocaría) [HV `server-side-detection.md`] |
| Precio arbitraje regional | Comprar barato en una región y transferir | `GetUsersPriceLevelsAsync` para condicionar trading/gifting [HV `regional-pricing.md`] |

## 3. `roblox-security-audit` (§44) — checklist ejecutable

La skill S11 ejecuta `factory security scan games/<slug>` (estático) y una revisión LLM adversarial (fork). Salida: `security-report.md` con severidades.

**Estático (automático, bloqueante)**:
- [ ] Inventario de remotes (Zap IDL + `Instance.new("RemoteEvent")` fuera del IDL = hallazgo).
- [ ] Cada handler de servidor llama a un validador del SDK antes de usar argumentos (AST check con Lune/`luau` parser o regex conservador + revisión).
- [ ] Ningún handler muta `Economy`/`Inventory`/`PlayerData` sin pasar por la API del SDK.
- [ ] `ProcessReceipt` definido exactamente una vez; todos los productos del `economy.yaml` tienen handler.
- [ ] Sin `InvokeClient`, `loadstring`, `getfenv`, `setfenv`, `require(<número>)`.
- [ ] Sin uso de `PromptProductPurchaseFinished` para conceder.
- [ ] Rate limits declarados para todos los remotes.
- [ ] Sin datos sensibles en `ReplicatedStorage`/`StarterPlayer` (lista de patrones: tablas `Weights`, `Secret`, `ApiKey`).
- [ ] `HttpService` sólo hacia allowlist; secrets vía secret store.

**Revisión adversarial (LLM, fork)**: transiciones de estado imposibles (p. ej. `prestige` con requisitos no cumplidos), carreras en compras/trades/teleports,
exploits de economía (sources sin límite), abuso de rewarded ads, bypass de PolicyService.

**Dinámico (engine tests)**: fuzzing de cada remote con payloads malformados/masivos; asserts de invariantes (balance ≥ 0, inventario ⊆ catálogo, sin duplicados).

**Producción**: detección de anomalías económicas (ingreso/hora por jugador > p99.9 del juego), velocidad imposible, conteo de rate-limit hits →
`exploit_signals` → Live Analyst → restricciones temporales automáticas (A3) y permanentes con revisión humana (A2).

## 4. Data safety (§45)

Hechos [HV `cloud-services/data-stores/*`, `extended-services.md`, OpenAPI]: límites de throughput por experiencia con errores `*ExperienceThrottled`;
key ≤ 50 caracteres; almacenamiento incluido 100 MB + 1 MB × lifetime players; versiones de entradas listables y recuperables; **snapshot** de data stores vía
API; **undelete** de data store (BETA); RTBF con plantillas `{UserId}` (hasta 100) configurables en Data Stores Manager o por API.

| Tema | Patrón de la fábrica |
|---|---|
| Escrituras | `UpdateAsync` (read-modify-write atómico) siempre; `SetAsync` prohibido para datos de jugador |
| Session locking | ProfileStore (lock de sesión con robo tras timeout) detrás de `PlayerData` |
| Retries | Backoff exponencial con jitter; presupuesto de peticiones (`GetRequestBudgetForRequestType`) consultado antes de escrituras no críticas |
| Autosave | Cada 3–5 min + en `PlayerRemoving` + `BindToClose` (con límite de 30 s de cierre) [HT, límite conocido de BindToClose] |
| Esquema y versionado | `schemaVersion` en cada perfil; migraciones puras `vN→vN+1` testeadas con fixtures; nunca borrar campos en la misma release que dejan de usarse |
| Migración | Lazy (al cargar) + tests de engine con muestras sintéticas + canario (flag por % de jugadores) |
| Backups | `data-stores:snapshot` antes de cada release con migración; exportación periódica de muestras para tests de migración (sin PII) |
| Corrupción / recuperación | `listRevisions` + restauración de versión por jugador (herramienta de soporte con aprobación en prod); detector de perfiles inválidos al cargar → cuarentena en lugar de sobrescribir |
| Compras | Registro del `PurchaseId` en el perfil **antes** de devolver `PurchaseGranted` |
| Privacidad / RTBF | Todas las claves con patrón `…_{UserId}` para que la plantilla RTBF funcione; nada de PII (nombres reales, emails) en datos propios; exportación a analytics externos sólo con `userId` pseudonimizado (hash con salt) |
| Datos fuera de Roblox | Minimizar; si se envían eventos a un warehouse propio, documentar base legal y retención; revisar con asesoría (⛔ STOP-04 si se planea recolectar datos de menores fuera de Roblox) |

## 5. Seguridad de la fábrica (no sólo de los juegos)

| Riesgo | Control |
|---|---|
| Fuga de API keys de Open Cloud | Claves por entorno y nivel, IP allowlist, expiración ≤90 días, sólo en secret store/GitHub Environments; el LLM nunca las ve |
| Agente ejecuta acción destructiva | Niveles de permiso + dry-run + aprobación humana ligada a hash (`04_MCP_ARCHITECTURE.md`) |
| Prompt injection desde datos externos (descripciones de juegos de terceros, webs, comentarios) | Tratar como datos; agentes de Market Intel sin permisos de escritura cloud; separación de agentes |
| Supply chain (Wally packages, plugins, MCPs de terceros) | Lockfiles, revisión de diffs de deps, allowlist de paquetes, sin plugins de Studio de terceros con red |
| Cuenta Roblox del grupo comprometida | 2FA obligatoria (además requisito de publicación), roles mínimos en el grupo, cuentas separadas para automatización |

## 6. Scanner de backdoors (asset hygiene)

`tools/scan-place.luau` (Lune, lee `.rbxl/.rbxm`): recorre todos los `Script/LocalScript/ModuleScript`, marca: `require` con literal numérico, `getfenv/setfenv`,
`loadstring`, strings ofuscados (alta entropía, `\x` masivo), `HttpService` a dominios no allowlist, `MarketplaceService:Prompt*` inesperados, scripts dentro de
modelos de arte. Corre en CI sobre el build y sobre cualquier asset importado.
