# FACTORY-BACKLOG

Complejidad: S (≤1 día-agente), M (2–4), L (5–10), XL (>10). Riesgo: B/M/A. Valor esperado: B/M/A/MA (muy alto).
P0 = necesario para el MVP de la fábrica (30 días). P1 = 90 días / piloto. P2 = segundo juego y escala B. P3 = escala C/D u opcional.

## Progreso (actualizar en cada PR)

| Fecha | Top-20 | Backlog | Estado | Evidencia |
|---|---|---|---|---|
| 2026-09-26 | 1 Aprobar decisiones | — | **Pendiente (humano)** | Checklist en `ops/ROBLOX_SETUP.md` §Acción 1 |
| 2026-09-26 | 2 Identidad/grupo/Plus | P0-03 | **Pendiente (humano)** | `ops/ROBLOX_SETUP.md` §Acción 2 |
| 2026-09-26 | 3 Universes + API keys | P0-03 | **Pendiente (humano)** | `ops/ROBLOX_SETUP.md` §Acción 3 (scopes exactos) |
| 2026-09-26 | 4 Monorepo base | P0-01 | **Hecho** | `rokit.toml`, `.luaurc`, `stylua.toml`, `selene.toml`, `packages/sdk` (Log, Loader + 6 tests), `templates/game-template` |
| 2026-09-26 | 5 CI estático | P0-02 | **Hecho (pendiente de primera ejecución en GitHub)** | `.github/workflows/static.yml` + `tools/ci/check.sh`, verificado en local (Linux) |
| 2026-09-26 | 6 Studio plane | P0-04 | **Pendiente (humano, Win/macOS)** | `ops/ROBLOX_SETUP.md` §Acción 6 |

## P0

| ID | Component | Description | Dependency | Complexity | Risk | Expected value | Acceptance criteria |
|---|---|---|---|---|---|---|---|
| P0-01 | Repo | Estructura monorepo, `rokit.toml`, StyLua/Selene/`.luaurc`, CLAUDE.md, CODEOWNERS | — | S | B | A | `rokit install` y hooks funcionan en Linux y Win/macOS |
| P0-02 | CI | Workflow estático: stylua --check, selene, rojo sourcemap + luau-lsp analyze, rojo build | P0-01 | S | B | A | PR con error de formato/tipo falla; build artefacto `.rbxl` |
| P0-03 | Roblox setup | Grupo de la fábrica, 2FA, ID verification, Roblox Plus; universes CI y staging; API keys por nivel con IP allowlist | — (humano) | S | M | MA | Documento `ops/ROBLOX_ACCOUNTS.md` con IDs (sin secretos) |
| P0-04 | Studio plane | Instalar Studio, habilitar MCP integrado, conectar Claude Code; runbook | — | S | B | A | Claude ejecuta `start_stop_play` + `screen_capture` + `get_console_output` |
| P0-05 | Open Cloud client | Cliente Python generado desde OpenAPI oficial (subset: places publish, luau-execution, datastores v2, configs, analytics query, server logs) | — | M | M | A | Tests de contrato contra universe CI pasan |
| P0-06 | CI engine tests | `publish-ci-place` + `run-engine-tests` (Luau Execution + Jest-Lua + parseo JSON) | P0-02, P0-05 | M | M | MA | Test que falla rompe el PR; tiempo total < 6 min |
| P0-07 | SDK | Loader + Observability (logger estructurado, error capture) | P0-01 | S | B | A | Servicios arrancan en orden; errores con contexto |
| P0-08 | SDK | Net: spike Zap vs Blink → decisión DEC-007; wrapper con validación y rate limiting | P0-07 | M | M | A | Fuzz test de remotes: payloads inválidos rechazados, spam limitado |
| P0-09 | SDK | PlayerData (ProfileStore) + schema v1 + migración ejemplo + autosave/BindToClose | P0-07 | M | A | MA | Engine tests: guardar/cargar, session lock, migración v1→v2 |
| P0-10 | SDK | Economy (ledger idempotente) + Products (ProcessReceipt idempotente) + Policy (PolicyService) | P0-09 | M | A | MA | Tests: sin duplicados con receipts repetidos; balance ≥ 0; gating paid random |
| P0-11 | SDK | RemoteConfig (ConfigService wrapper, defaults tipados por codegen) + Analytics (taxonomía, custom fields fijos) | P0-07 | M | M | A | Config de prueba cambia valor en servidor sin publicar; eventos visibles en dashboard |
| P0-12 | Template | `templates/game-template` + `factory new-game` | P0-07..11 | S | B | A | Nuevo juego compila, pasa CI y publica a CI place |
| P0-13 | Trends | Collector v0 (seeds + recommendations BFS, snapshots `/v1/games` y votes, Postgres) | P0-03 (DB) | M | M (STOP-01) | A | ≥3 semanas de snapshots horarios de ≥1,000 universes sin errores de rate limit |
| P0-14 | MCP | `roblox-cloud-mcp` v0: READ, RUN_TESTS, publish CI/staging con plan/dry-run, snapshot, audit log | P0-05 | M | M | MA | Publicar staging requiere plan; audit log registra todo; prod rechazado sin aprobación |
| P0-15 | Skills | S04, S06, S10, S11, S12, S13 v1 + subagentes Engineer/Reviewer/Release + hooks | P0-12, P0-14 | M | M | A | WP "daily reward" completado por agentes con PR aprobado por Reviewer |
| P0-16 | Security | Scanner Lune (remotes, backdoors, patrones prohibidos) en CI | P0-02 | S | B | A | Detecta `require(123)`, `loadstring`, remotes sin validador en fixtures |
| P0-17 | Policy | Policy engine v0 (POL-001..010) | P0-12 | M | M | A | Fixtures de violación → BLOCK; juego limpio → PASS |
| P0-18 | Release | GitHub Environments (staging auto, production con reviewers); workflow de release con snapshot + publish + smoke (server logs) | P0-14 | S | M | MA | Release a "prod de prueba" sólo tras aprobación; rollback documentado y probado |
| P0-19 | Demo E2E | Pipeline completo sobre hello-factory hasta publicación 16+ de prueba y eventos en Analytics | P0-01..18 | M | M | MA | Checklist de `21_IMPLEMENTATION_ROADMAP.md` §4 semana 4 completada |

## P1

| ID | Component | Description | Dependency | Complexity | Risk | Expected value | Acceptance criteria |
|---|---|---|---|---|---|---|---|
| P1-01 | Design | Skills S03, S05 + plantillas concepto/GDD/economy.yaml | P0-15 | M | M | A | Concepto y GDD del piloto aprobados en G1 |
| P1-02 | econsim | Simulador agent-based v0 + reglas de economía rota + paridad Luau | P1-01 | M | M | A | Informe con inflación, walls y sensibilidad; test de paridad en CI |
| P1-03 | UI | `packages/ui` design system v1 (tokens + 15 componentes) + place `ui-gallery` | P0-12 | L | M | A | Capturas en 4 resoluciones sin overlaps/texto cortado |
| P1-04 | QA | Guiones E2E Studio MCP (tutorial, compra, guardado/rejoin) + informe con capturas | P0-04 | M | M (experimental) | A | 3 guiones verdes en 3 ejecuciones seguidas |
| P1-05 | QA | Perf harness (heartbeat, memoria, handlers p95) + gates | P0-07 | M | M | A | Gate bloquea regresión sintética |
| P1-06 | LiveOps | Módulo LiveOps v1: daily rewards, quests declarativas, eventos, rotaciones (configs) + calendario YAML | P0-11 | L | M | A | Evento activado por config sin publicar; quests por eventos de dominio |
| P1-07 | Monetization | Rewarded video (AdService) + Plus prompt + passes/products del piloto vía API con aprobación | P0-10, P0-14 | M | M | A | Recompensa = dev product; `ECONOMY_CHANGE` exige aprobación |
| P1-08 | Pilot | MVP del piloto (WPs del GDD) | P1-01..07 | XL | A | MA | Pasa G3 |
| P1-09 | Compliance | Questionnaire draft + policy full scan + originality report | P0-17 | S | M | A | Humano envía cuestionario con borrador |
| P1-10 | Analytics | Ingest Analytics Query API → Postgres + Metabase (salud, retención, economía, monetización) | P0-05 | M | M | A | Dashboard con D1/D7, bounce, ARPDAU del piloto |
| P1-11 | Experiments | Plantilla + S15 + primer experimento (onboarding) vía Experiments nativo | P1-10 | M | M | A | Experimento lanzado con MDE calculado y regla pre-registrada |
| P1-12 | Incidents | Reglas de detección + runbooks + S18 + kill switches | P1-10 | M | M | A | Simulacro de incidente resuelto con flag en < 15 min |
| P1-13 | Ads | Campaña de calibración ($300–500) + registro de CPI/CAC | soft launch | S | M | A | CPI medido y registrado en cost model |
| P1-14 | KB | Estructura `knowledge/` + S17 + postmortem de fase | P1-08 | S | B | A | ≥10 findings con scope/contexto |
| P1-15 | Trends | Features, estados, clasificación (Haiku batch), clusters, backtest | P0-13 (≥90 días) | L | M | A | Backtest con lift > baseline documentado |
| P1-16 | Opportunity | Score v1 con priors YAML + informe mensual | P1-15 | M | M | A | Top-5 oportunidades con intervalos y riesgos |

## P2

| ID | Component | Description | Dependency | Complexity | Risk | Expected value | Acceptance criteria |
|---|---|---|---|---|---|---|---|
| P2-01 | Orchestrator | State machine + colas + presupuestos + asignación a subagentes | P1-* | L | M | A | 2 juegos avanzan con transiciones automáticas técnicas y humanas registradas |
| P2-02 | Portfolio | Informe semanal de portfolio (EV/€, WIP, kill proposals) | P2-01, P1-16 | M | B | A | Revisión semanal ≤ 45 min |
| P2-03 | MCP | `roblox-cloud-mcp` v1: configs, experiments, products (gated), notifications, events, user restrictions, ads read | P0-14 | M | M | A | Todas las herramientas con nivel y auditoría |
| P2-04 | Creative | Sistema de creative variants + thumbnail personalization | P1-10 | M | M | M | Test de thumbnails con guardrails ejecutado |
| P2-05 | Localization | Pipeline extract→translate→review→publish | P1-03 | M | B | M | 10 idiomas con revisión de tienda |
| P2-06 | Warehouse | Eventos propios pseudonimizados (tras STOP-04) + ledger económico muestreado + exploit signals | STOP-04 | L | A | M | Datos sin PII; retención definida |
| P2-07 | Security | Detección de anomalías económicas y de movimiento en producción + restricciones temporales automáticas | P1-12 | M | M | A | Falsos positivos < umbral en staging |
| P2-08 | SDK | Social/Parties, referral system, share links, notificaciones | P0-12 | M | B | A | Eventos de co-play medibles |
| P2-09 | Game 2 | Segundo juego desde oportunidad del Opportunity Engine | P1-16, P2-01 | XL | A | A | Lead time < piloto −30% |
| P2-10 | Finance | Modelo financiero `factory/finance` con datos reales | P1-13 | S | B | A | EV/€ por juego y portfolio |

## P3

| ID | Component | Description | Dependency | Complexity | Risk | Expected value | Acceptance criteria |
|---|---|---|---|---|---|---|---|
| P3-01 | Assets | Blender MCP experimental para props/kits en entorno aislado | — | M | A | M | 10 props válidos (tris/UV) en < X h |
| P3-02 | Assets | GenerationService/`generate_*` para variantes de props en runtime/Studio | — | M | M | M | Evaluación de calidad documentada |
| P3-03 | Control plane | UI propia (sólo si ≥5 juegos activos) | P2-01 | L | M | M | — |
| P3-04 | Visual QA | Diff perceptual automático y clasificador de problemas de UI | P1-04 | M | M | M | Detecta regresiones sembradas |
| P3-05 | Skills | Empaquetar skills/agents/hooks como plugin versionado | P0-15 | S | B | M | Instalable en otra máquina |
| P3-06 | Assistant | Export de conocimiento a Roblox Assistant Skills | DEC-013 | S | B | B | Skill funcional en Assistant |
| P3-07 | Matchmaking | Evaluar `matchmaking-api` launch-update/forecast (STOP-06) | — | S | M | M | Semántica documentada tras spike |
| P3-08 | Ads | Automatización A2 de campañas con topes (Ads API experimental) | P1-13, G6 | M | A | M | Ninguna campaña sin aprobación |
