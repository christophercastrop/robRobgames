# 10 — Shared Game SDK, Arquitectura de Juegos y Project Template

## 1. Patrones arquitectónicos (§35)

| Patrón | Fortalezas | Debilidades | Cuándo |
|---|---|---|---|
| Monolito de scripts | Rápido para prototipos | Imposible de testear/escalar; acoplamiento | **Sólo greybox** (G2), se tira |
| **Service/Controller** (servicios en servidor, controllers en cliente, init/start en dos fases) | Simple, legible por LLMs, testeable con DI ligera; estándar de facto (Knit popularizó el patrón) | Riesgo de "god services" | **Por defecto** para MVP y LIVE |
| ECS (jecs) | Rendimiento con miles de entidades; composición | Curva de aprendizaje; debugging; UI mixta | Juegos con muchas entidades simuladas (tower defense con oleadas grandes, simulaciones) |
| Event-driven (bus interno) | Desacopla analytics, quests, logros del core | Flujo difícil de seguir si se abusa | **Siempre** para sistemas transversales (analytics, quests, achievements escuchan eventos de dominio) |
| Reactive (Charm/Vide) | UI y estado derivado consistentes | — | **Siempre** en cliente/UI |
| Modular packages | Reuso entre juegos | Versionado | SDK de la fábrica |

**[DEC-016]** Arquitectura por defecto = **Service/Controller + bus de eventos de dominio + estado reactivo en cliente + red tipada (Zap)**.
ECS opcional por juego si el TECH plan lo justifica con números (entidades simultáneas > ~500 [HIPÓTESIS]).

Recomendación por tamaño:

| Tamaño | Arquitectura |
|---|---|
| Prototipo (≤1 semana) | Scripts + módulos del SDK; sin Zap (RemoteEvents simples, validados) |
| MVP pequeño (1 place, ≤20 servicios) | Service/Controller + SDK completo |
| Juego grande / multi-place | Idem + paquetes de dominio por feature (`src/features/<feature>/{server,client,shared}`) + TeleportService + servicios de lobby/match |

## 2. SDK: qué se comparte y qué no (§36)

Criterio: se comparte si (a) ≥2 juegos lo necesitan igual, (b) su fallo es caro (dinero, datos, seguridad), o (c) acelera la instrumentación común.

| Módulo | Compartir | Motivo / notas |
|---|---|---|
| `Loader` (service/controller lifecycle) | **Sí** | Base de todo |
| `Net` (wrappers Zap + rate limiting + validación) | **Sí** | Seguridad |
| `PlayerData` (ProfileStore detrás de interfaz) + `DataMigration` + `SaveSystem` | **Sí** | Riesgo de pérdida de datos |
| `Currencies` / `Inventory` / `Economy` (ledger server-authoritative, idempotencia) | **Sí** | Riesgo de exploits/duplicación |
| `Products` / `Entitlements` (ProcessReceipt idempotente, passes, suscripciones, rewarded ads) | **Sí** | Dinero real |
| `Policy` (wrapper PolicyService: paid random items, trading, social links, subs) | **Sí** | Compliance obligatorio |
| `RemoteConfig` / `FeatureFlags` (wrapper **ConfigService**, tipado, fallbacks, snapshot por ronda) | **Sí (fino)** | **No** reimplementar remote config: Roblox lo ofrece nativo |
| `Experiments` (lectura de variante vía configs + logging de exposición) | **Sí (fino)** | Experiments nativo hace la asignación |
| `Analytics` (taxonomía común sobre AnalyticsService + exportador opcional) | **Sí** | Comparabilidad entre juegos |
| `LiveOps` (daily rewards, quests/challenges, eventos, rotaciones, ofertas; data-driven por configs) | **Sí** | Evitar reimplementar |
| `Quests` / `Achievements` / `DailyRewards` | **Sí** (dentro de LiveOps) | |
| `Progression` / `Prestige` | **Parcial** (primitivas: XP curves, rebirth transaction) | La forma varía por juego |
| `Observability` (logger estructurado, error capture, métricas de servidor, heartbeat) | **Sí** | Incidentes |
| `AntiCheat` (validadores de movimiento, sanity checks, rate limits, flags de sospecha) | **Sí** (primitivas) | Reglas específicas por juego |
| `Moderation` (wrappers de `TextService:FilterStringAsync`, `Players:BanAsync`/`Kick`, gating con `Player:IsVerified`, salvaguardas de UGC, panel de moderación server-side) | **Sí** | Obligatorio: sin filtrado Roblox puede retirar el juego [HV `safety.md`] |
| `Localization` (helpers + extracción de strings) | **Sí** | |
| `Notifications` (experience notifications con plantillas) | **Sí** | |
| `Social` / `Parties` (invites, friends-in-server, share links) | **Sí** (primitivas) | Co-play es señal de discovery |
| `UI` (design system: tokens + componentes Vide) | **Sí** | Paquete `packages/ui` |
| `Audio` (bus de SFX/música, volúmenes) | **Parcial** | Librería de assets compartida aparte |
| `Matchmaking` (lobbies, reserved servers) | **Opcional** | Sólo juegos session-based |
| Gameplay específico (combate, física, IA de enemigos) | **No** | Diferenciación; va en el juego |

## 3. Contratos clave (esbozo Luau)

```lua
--!strict
-- packages/sdk/Economy/init.luau (servidor)
export type CurrencyId = string
export type Reason = { source: string, itemId: string?, txId: string } -- txId: idempotencia
local Economy = {}
function Economy.grant(player: Player, currency: CurrencyId, amount: number, reason: Reason): (boolean, string?) end
function Economy.spend(player: Player, currency: CurrencyId, amount: number, reason: Reason): (boolean, string?) end
-- Invariantes: amount > 0 y entero; límites por minuto por fuente (anti-farm); cada mutación → AnalyticsService economy event;
-- nunca invocable desde cliente directamente; balance nunca < 0.

-- packages/sdk/Products/init.luau
-- ProcessReceipt único por juego; handlers idempotentes por PurchaseId (persistido en PlayerData antes de devolver PurchaseGranted).

-- packages/sdk/RemoteConfig/init.luau
export type Snapshot = { get: (self: Snapshot, key: string) -> any }
function RemoteConfig.snapshot(): Snapshot end        -- envuelve ConfigService:GetConfigAsync()
function RemoteConfig.onUpdate(cb: () -> ()) end      -- ConfigSnapshot.UpdateAvailable; aplicar entre rondas
-- Fallbacks tipados en config/remote-config.yaml → codegen a shared/ConfigDefaults.luau
```

## 4. Feature flags (§34)

```text
FeatureFlagService   = RemoteConfig keys con prefijo `ff.` (bool) + kill switches `kill.` (bool, default false)
RemoteConfigService  = RemoteConfig keys tipadas (number/string/JSON) con owner y nivel (`econ.*`, `price.*` ⇒ ECONOMY_CHANGE)
ExperimentService    = lectura de config sujeta a Experiment nativo + evento `experiment_exposure`
EventService         = bus interno + Analytics
```

Qué puede cambiarse **sin publicar código** (seguro): parámetros de balance dentro de rangos validados, textos (vía localización), activación de
eventos/rotaciones ya implementados, kill switches, targeting de ofertas ya aprobadas. **No** seguro sin publicar: lógica nueva, nuevos productos sin
revisión de política, cambios de esquema de datos.

## 5. UI Factory / Design System (§48)

`packages/ui` (Vide + tokens):

- **Tokens**: spacing (4/8/12/16/24/32 escalados por `UIScale` según viewport), tipografía (familias con buena legibilidad en móvil, tamaños mínimos
  para phone), colores (tema por juego vía tokens, contraste AA), radios, sombras, z-layers.
- **Componentes**: Button (primary/secondary/purchase), IconButton, Panel, Card, Dialog/Modal, Toast, Tabs/Navigation rail, CurrencyDisplay (con animación de delta),
  RewardPopup, QuestList/QuestCard, ShopGrid/ShopItem (precio siempre desde `MarketplaceService`, nunca hard-coded → requisito para price optimization [HV]),
  OddsTable (paid random items: % que suman 100%, actualización dinámica [HV]), Settings (audio, gráficos, accesibilidad), Tooltip, ProgressBar, Timer
  (nunca falsos countdowns [HV monetization/index]).
- **Responsive**: layouts por breakpoint (phone portrait/landscape, tablet, desktop, 10-foot consola), safe areas (`GuiService:GetGuiInset`), touch targets ≥ ~44 px equivalentes.
- **Accesibilidad**: tamaño de texto escalable, no depender sólo del color, soporte de gamepad (selección de GUI), subtítulos/indicadores visuales para audio.
- **Localización**: cero literales; claves en tablas; tolerancia a textos +40% de longitud.
- Storybook-equivalente: place `ui-gallery` generado por Rojo con todos los componentes en todas las resoluciones → capturas automáticas (ver `11_QA_E2E.md`).

## 6. Project template (§37)

```text
roblox-factory/                      # MONOREPO (ver DEC-001)
├─ .claude/ (skills/, agents/, settings.json)
├─ .github/workflows/ (game-ci.yml reusable, sdk-ci.yml, trends-cron.yml, liveops-cron.yml)
├─ packages/
│   ├─ sdk/ (src/…, tests/unit, tests/engine, wally.toml, README, CHANGELOG)
│   └─ ui/
├─ templates/game-template/          # copiado por `factory new-game <slug>`
│   ├─ default.project.json, wally.toml, selene.toml, stylua.toml, .luaurc
│   ├─ src/{server,client,shared}/, src/net/game.zap
│   ├─ config/{economy.yaml,remote-config.yaml,liveops/}
│   ├─ design/{GDD.md,TECH.md,work-packages/}
│   ├─ tests/{unit,engine,sim,e2e}/
│   └─ STATE.yaml
├─ games/<slug>/                     # instancias del template
├─ factory/                          # Python: cli, trends, score, econ-sim, analytics ingest, policy engine, orchestrator
├─ mcp/roblox-cloud-mcp/
├─ knowledge/ (global/, genres/, experiments/, player/, engineering/, patterns/)
├─ tools/ (scripts Lune: place validation, asset scanner, codegen)
├─ docs/ (esta investigación + ADRs)
└─ rokit.toml
```

`factory new-game <slug>` crea el juego desde el template, registra universes (staging/prod se crean **manualmente** en Creator Hub — no hay
endpoint de creación de universes en el OpenAPI [HV: no aparece]), escribe `.env.example` con IDs y abre el Issue de Gate 1.

## 7. Versionado del SDK

SemVer; los juegos referencian el SDK **por ruta** en el monorepo (siempre "latest" del commit), con **tests de contrato** del SDK en CI y un
`sdk-compat` job que compila todos los juegos activos ante cada cambio del SDK. Para juegos en MAINTENANCE se congela una copia vendorizada
(`games/<slug>/vendor/sdk@x.y.z`) para no forzar regresiones.
