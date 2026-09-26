# ROBLOX GAME FACTORY — RECOMMENDED ARCHITECTURE

**Fecha de corte: 2026-09-26.** Documento final. Cada sección enlaza al detalle. Decisiones = PROPUESTAS (`DECISIONS.md`).

## A. Qué construir

1. **Monorepo `roblox-factory`** con juegos, SDK, UI kit, servicios de fábrica, MCP propio, skills y KB (DEC-001).
2. **Shared Game SDK (Luau)**: Loader, Net (Zap), PlayerData (ProfileStore wrapper), Economy (ledger idempotente), Products/Entitlements, Policy, RemoteConfig/FeatureFlags (sobre ConfigService), Experiments (exposición), Analytics (taxonomía común), LiveOps, Observability, AntiCheat primitives, Moderation, Localization, Social, UI design system (Vide) — `10_SHARED_GAME_SDK.md`.
3. **`roblox-cloud-mcp`**: capa fina sobre Open Cloud con niveles de permiso, dry-run/plan, aprobación humana ligada a hash, auditoría (DEC-003) — `04_MCP_ARCHITECTURE.md`.
4. **CI de juegos**: estático (StyLua/Selene/luau-lsp) → Lune unit → Rojo build → **Jest-Lua vía Open Cloud Luau Execution** → security scan → policy scan → staging → aprobación → producción — `09` §6.
5. **Trend Engine** (sólo endpoints documentados, ⛔ STOP-01) y **Opportunity Engine** bayesiano explícito — `07`, `08`.
6. **Economy simulator** (agent-based Monte Carlo sobre `economy.yaml`) — `14` §4.
7. **Factory Policy Engine** + **security/backdoor scanner** — `18`, `12`.
8. **Orquestador mínimo** (state machine, colas, presupuestos) en Python — `06` §3–4.
9. **Knowledge base** en Git con scope/contexto/caducidad — `19` §3.

## B. Qué reutilizar

- **Roblox oficial**: Studio MCP integrado; Open Cloud (place publishing, Luau Execution, DataStores, Configs, Experiments, Analytics Query, server logs, assets, passes/products, notifications, events, user restrictions); ConfigService; Experiments; AnalyticsService; price optimization/regional pricing; thumbnail personalization; Ads Manager.
- **OSS**: Rojo, Rokit, Wally, StyLua, Selene, luau-lsp, Lune, Jest-Lua, Zap (o Blink), ProfileStore, Vide, Charm, Trove, jecs (opcional), Postgres/pgvector, Metabase/Grafana.
- **Anthropic**: Claude Code (skills, subagents, hooks, headless), Claude Agent SDK, Batch API, MCP Python SDK.
- **GitHub**: repos, Actions, Environments (aprobaciones), Issues/Projects, GitHub MCP.

## C. Qué NO construir

MCP de Studio propio · sistema propio de remote config o de asignación A/B · framework propio de ECS/red/UI · control plane UI (hasta ≥5 juegos) · bots que entran en
servidores publicados como usuarios · scraping de sorts/charts no documentados · generador 3D propio · device farm · warehouse event-level antes de resolver STOP-04 ·
cliente de Open Cloud a mano (se genera desde el OpenAPI) · multi-repo.

## D. Skills definitivas (19)

S01 `roblox-market-intel` · S02 `roblox-opportunity-scoring` · S03 `roblox-game-concept` · S04 `roblox-gdd` · S05 `roblox-economy-design` ·
S06 `roblox-luau-engineering` · S07 `roblox-ui-engineering` · S08 `roblox-data-safety` · S09 `roblox-performance` · S10 `roblox-testing` ·
S11 `roblox-security-audit` (fork) · S12 `roblox-policy-compliance` (fork) · S13 `roblox-release` (user-only) · S14 `roblox-analytics` ·
S15 `roblox-experimentation` · S16 `roblox-liveops` · S17 `roblox-learning-loop` · S18 `roblox-incident-response` · S19 `roblox-asset-pipeline` (opcional).
Detalle: `05_CLAUDE_SKILLS.md`, `inventories/SKILLS-INVENTORY.md`.

## E. MCP definitivos

| MCP | Estado |
|---|---|
| Roblox Studio MCP (integrado, oficial) | **Usar** (Studio plane) |
| `roblox-cloud-mcp` (propio, fino) | **Construir** (Cloud plane) |
| GitHub MCP (oficial) | **Usar** |
| Postgres | CLI read-only por defecto; `crystaldba/postgres-mcp` opcional |
| Playwright MCP | Limitado (páginas públicas propias) |
| Blender MCP | Experimental F8, aislado |
| Filesystem/Git/Fetch | No (nativos de Claude Code) |
| MCPs Roblox de terceros | No |

## F. Toolchain definitivo

`rokit.toml`: rojo 7.7.0 · stylua 2.5.2 · selene 0.31.0 · luau-lsp 1.70.0 · lune 0.10.5 · wally 0.3.2. Runtime: Jest-Lua 3.10 (pin), Zap, ProfileStore, Vide, Charm, Trove.
Lenguaje: Luau `--!strict` (no roblox-ts). Servicios: Python. Detalle: `02_TOOLCHAIN.md`.

## G. Arquitectura multiagente

Orquestador determinista + 6 roles LLM (Market Analyst, Game Designer, Engineer×N en worktrees, Reviewer independiente en fork, Release Manager con permisos gated,
Live Analyst programado). Especialización vía skills; separación por permisos e independencia; memoria explícita en Git/DB. State machine
DISCOVERED→…→LIVE/SCALING/MAINTENANCE/PAUSED/KILLED/ARCHIVED con gates G0–G6. Detalle: `06_AGENT_ARCHITECTURE.md`, `inventories/AGENT-MATRIX.md`.

## H. Trend Engine

Recolector horario de `/v1/games` (+votes, recommendations, thumbnails) para 2–5k universes; features (r7, r28, aceleración, momentum, z robusto, relativo a género,
cohortes de edad); estados (EXPLODING…REVIVING) con umbrales a calibrar por backtest; clasificación tema/mecánica/meta-loop (taxonomía oficial + LLM batch + visión +
5% humano); clusters con `clone_wave`/`novel`; señales sociales vía YouTube/Twitch/Reddit APIs. Detalle: `07_TREND_INTELLIGENCE.md`.

## I. Game SDK

Ver A.2 y `10_SHARED_GAME_SDK.md`. Arquitectura de juego por defecto: Service/Controller + bus de eventos + estado reactivo + red tipada; ECS opcional.

## J. QA/E2E

Capas: unit (Lune, A4) · engine/integration/persistence/network/exploit (Jest-Lua en Luau Execution, A4) · simulación (econsim + SimPlayer, A4) · playtest automatizado
(Studio MCP, A3 experimental) · visual QA (detección A3, juicio A1) · multi-cliente y dispositivos (humanos). Performance gates por plataforma con foco en Android 2–4 GB.
Detalle: `11_QA_E2E.md`.

## K. Analytics

Roblox-native primero (AnalyticsService con taxonomía común y custom fields fijos; dashboard; Query API; Experiments; server logs); Metabase sobre Postgres; warehouse
propio sólo tras STOP-04. North-star por fase: bounce <60 s y play days D2–7 (soft launch) → D8–28 × ARPDAU (LIVE) → EV/€ (fábrica). Detalle: `13_ANALYTICS.md`.

## L. Monetización

Passes, dev products, suscripciones (battle pass), rewarded video, Plus prompts, private servers (si social), Creator Rewards como base; price optimization/regional
pricing con precios dinámicos; sin paid random items en el núcleo; toda mutación de precios = ECONOMY_CHANGE humano. Detalle: `14_MONETIZATION.md`.

## M. LiveOps

Módulo LiveOps data-driven (daily, quests declarativas, eventos, rotaciones, ofertas, season pass) sobre ConfigService + calendario YAML; Experience Events y
notificaciones con plantillas; experimentos nativos con plantilla pre-registrada. Detalle: `16_LIVEOPS.md`.

## N. Infraestructura

Cloud plane: GitHub Actions + Postgres + VPS/cron + Metabase + secret management (Environments). Studio plane: 1 workstation Win/macOS con Studio + Claude Code.
Roblox: universe CI compartido; staging y prod por juego. Detalle: `19_FACTORY_INFRASTRUCTURE.md`.

## O. Costes

LEAN: inicial $1.5–4k, mensual $0.3–0.6k + operador, ≈$1.5–5k por juego hasta G4/G5. PROFESSIONAL: $15–40k/mes. SCALE: $60–150k/mes. El coste dominante son personas
y LiveOps; LLM ≈ $1–2.5k por juego hasta soft launch. CPI de ads no observable hasta calibrar. Detalle: `20_COST_MODEL.md`.

## P. Riesgos

Top: baja retención/calidad, trend chasing, clones/IP, cambios de plataforma y APIs beta, volatilidad de discovery, exploits, alucinación de agentes, carga de
mantenimiento del portfolio. Registro completo: `RISK-REGISTER.md`; ataque sin suavizar: `RED-TEAM.md`.

## Q. Roadmap

F1 toolchain + trend collector → F2 SDK + template + engine tests → F3 skills + `roblox-cloud-mcp` v0 → F4 piloto MVP → F5 soft launch + analytics + LiveOps →
F6 Trend/Opportunity v1 → F7 orquestador → F8 assets → F9 control plane. 30/90 días en `21_IMPLEMENTATION_ROADMAP.md`; backlog en `FACTORY-BACKLOG.md`.

## R. MVP de la fábrica

idea (manual + collector) → GDD (skills) → implementación (SDK + Engineer) → tests (Lune + Luau Execution) → staging (MCP propio) → playtest humano →
publicación con aprobación → analytics nativas. Demostrado primero con "hello-factory" (día 30). `21` §2.

## S. Primer juego piloto

**Incremental Simulator cooperativo de sesión corta** (1 place, rating Minimal, sin paid random items; passes + dev products + rewarded video + Plus prompt; daily +
quests + 1 evento). Tema decidido en G1 con datos del collector. Objetivo: validar la fábrica, no maximizar ingresos. `21` §3, DEC-028.

## T. Preguntas todavía abiertas

1. ⛔ STOP-01: ¿uso comercial automatizado de endpoints documentados (anónimos) de `games.roblox.com` aceptable? ¿Y endpoints no documentados de sorts?
2. ⛔ STOP-04: ¿recolección de eventos de jugadores fuera de Roblox (base legal, menores)?
3. ⛔ STOP-05: entidad legal, titularidad de cuentas/grupo, fiscalidad DevEx.
4. ⛔ STOP-03: CPI/CAC real de Roblox Ads y benchmarks de retención por género (medir en soft launch).
5. ⛔ STOP-06: semántica de `matchmaking-api/game-instances/launch-update`.
6. ¿Contexto exacto de Luau Execution (sin Players; acceso a DataStores del universe; `SavePlaceAsync`)? → spike F1.
7. ¿Duración típica de la evaluación all-ages y criterios cuantitativos? (no publicados).
8. ¿Zap vs Blink? (spike de 1 día, DEC-007).
9. ¿Vide aguanta UI compleja de tiendas/inventarios? (spike F2, DEC-006).
10. ¿Qué nivel de fiabilidad tienen los guiones E2E con el MCP de Studio en 3 ejecuciones consecutivas? (P1-04).
11. ¿Tasa base de éxito del proceso (G4) — medible sólo tras ~10 lanzamientos.
12. ¿Presupuesto y apetito de riesgo del propietario (LEAN vs PROFESSIONAL)?

---

# TOP 20 NEXT ACTIONS

Ordenadas por dependencia y valor práctico.

1. **Aprobar/rechazar las decisiones clave** DEC-001, 002, 003, 010, 011, 012 y elegir presupuesto (LEAN/PRO) — 30 min humano.
2. **Resolver STOP-05 mínimo**: crear grupo Roblox de la fábrica, 2FA, ID verification, Roblox Plus; definir titular de DevEx.
3. **Crear universes** CI y `hello-factory [STAGING]` en Creator Hub; generar API keys por nivel (CI, staging) con IP allowlist y expiración.
4. **Monorepo base** (P0-01) con `rokit.toml` pinneado, configs de StyLua/Selene/luau-lsp, CLAUDE.md.
5. **CI estático** (P0-02): format, lint, typecheck, `rojo build`.
6. **Studio plane**: habilitar "Studio as MCP server", conectar Claude Code, verificar playtest + captura + consola (P0-04).
7. **Spike Luau Execution** (1 día): contexto de ejecución, DataStores, límites reales, tiempos; documentar (pregunta abierta 6).
8. **Cliente Open Cloud generado** desde el OpenAPI oficial (subset P0-05) + tests de contrato.
9. **Runner de engine tests** (P0-06): publish CI place + Luau Execution + Jest-Lua; PR que falla si falla un test.
10. **Arrancar el Trend collector** (P0-13) con endpoints documentados a ≤1 req/s mientras se resuelve STOP-01 — el histórico no se puede recuperar después.
11. **Spike Zap vs Blink** (1 día) → cerrar DEC-007; implementar `Net` con validación y rate limiting.
12. **PlayerData + Economy + Products + Policy** en el SDK con engine tests de persistencia, idempotencia y fuzzing (P0-09, P0-10).
13. **RemoteConfig + Analytics** (P0-11) con taxonomía común y custom fields fijos.
14. **Template + `factory new-game`** (P0-12) y juego "hello-factory".
15. **`roblox-cloud-mcp` v0** (P0-14): READ, RUN_TESTS, publish CI/staging con plan/dry-run, snapshot, audit log; GitHub Environments para producción (P0-18).
16. **Security scanner + Policy engine v0** en CI (P0-16, P0-17).
17. **Skills v1 + subagentes + hooks** (P0-15); ejecutar el WP "daily reward" de punta a punta por agentes.
18. **Demo E2E completa** con hello-factory hasta una publicación 16+ de prueba con aprobación humana y eventos en Analytics (P0-19).
19. **Gate G1 del piloto**: S01 sobre 3–4 semanas de datos → 3–5 conceptos de Incremental Simulator cooperativo → elección humana → GDD + economy.yaml + econsim.
20. **Plan de soft launch del piloto**: questionnaire, calibración de ads ($300–500), dashboards Metabase, primer experimento de onboarding, runbooks de incidentes.
