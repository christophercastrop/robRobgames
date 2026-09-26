# SKILLS-INVENTORY

Detalle y Definition of Done en `docs/research/05_CLAUDE_SKILLS.md`. Permisos según `04_MCP_ARCHITECTURE.md` §5.
Trigger: **auto** (Claude la invoca por descripción), **user** (`disable-model-invocation: true`), **cron** (lanzada por el orquestador), **fork** (`context: fork`).

| Skill | Agent | Inputs | Outputs | Tools | Permission | Trigger |
|---|---|---|---|---|---|---|
| S01 `roblox-market-intel` | Market Analyst | vistas `trend_*`, KB de géneros, fuentes permitidas | `research/market/*.md`, `opportunity_candidates.yaml` | Read, Bash(`factory trends *`), WebSearch/WebFetch | READ | auto + cron semanal |
| S02 `roblox-opportunity-scoring` | Market Analyst | candidatos, features, portfolio | `opportunities/<id>.yaml` | Bash(`factory score *`) | READ | auto |
| S03 `roblox-game-concept` | Game Designer | opportunity, KB patrones/necesidades | `design/concepts.md`, `originality-report.md` | Read/Write, Bash(`factory originality *`) | WRITE_LOCAL | auto (tras G0) |
| S04 `roblox-gdd` | Game Designer | concepto aprobado | `GDD.md`, `work-packages/*.md` | Read/Write | WRITE_LOCAL | auto (tras G1) |
| S05 `roblox-economy-design` | Game Designer | GDD, KB economía | `config/economy.yaml`, informe econsim, `monetization.md` | Read/Write, Bash(`factory econ *`) | WRITE_LOCAL | auto |
| S06 `roblox-luau-engineering` | Engineer | WP, SDK, TECH.md | PR (código + tests) | Read/Edit/Write, Bash(rojo, stylua, selene, luau-lsp, lune), Studio MCP | WRITE_LOCAL, RUN_TESTS | auto (paths `games/**`, `packages/**`) |
| S07 `roblox-ui-engineering` | Engineer | WP de UI, design system | PR UI + capturas | idem + `screen_capture` | WRITE_LOCAL, RUN_TESTS | auto (paths `**/client/ui/**`) |
| S08 `roblox-data-safety` | Engineer | cambios de esquema | schema vN, migraciones, tests, runbook | idem + `cloud.snapshot_datastores` | WRITE_LOCAL, RUN_TESTS, WRITE_CLOUD(snapshot) | auto (paths `**/PlayerData/**`, `schema/**`) |
| S09 `roblox-performance` | Engineer / Reviewer | build, perf harness | perf report | Bash, Studio MCP, `cloud.query_metrics` | RUN_TESTS, READ | auto + gate G3 |
| S10 `roblox-testing` | Engineer / Reviewer | WP, guiones E2E | tests, e2e reports | Bash, Studio MCP, `cloud.run_luau_task` | RUN_TESTS | auto |
| S11 `roblox-security-audit` | Reviewer | PR diff, build | `security-report.md` | Read, Bash(`factory security scan`) | READ | fork, en cada PR |
| S12 `roblox-policy-compliance` | Reviewer | build, metadata, LEDGER, economy.yaml | `policy-report.md`, `questionnaire-draft.md` | Bash(`factory policy scan`) | READ | fork, en PR y release |
| S13 `roblox-release` | Release Manager | build aprobado | `release/<v>.md`, publish staging, plan prod | `roblox-cloud-mcp` | PUBLISH_STAGING (+PROD con aprobación) | **user** |
| S14 `roblox-analytics` | Live Analyst | Analytics Query, warehouse | informes semanales/gate | `cloud.query_metrics`, SQL | READ | cron diario/semanal + auto |
| S15 `roblox-experimentation` | Live Analyst | hipótesis, configs | experiment record, decisión | `cloud.experiment_*`, `cloud.config_*` | WRITE_CLOUD (+ECONOMY_CHANGE si precios) | auto (lanzar = aprobación) |
| S16 `roblox-liveops` | Live Analyst / Designer | calendario, configs | planes de cambio, eventos, notificaciones | `cloud.config_*`, `cloud.event_upsert`, `cloud.notify_users` | WRITE_CLOUD (+ECONOMY_CHANGE) | cron diario |
| S17 `roblox-learning-loop` | Live Analyst | postmortems, experimentos | `knowledge/**` | Read/Write | WRITE_LOCAL | auto tras gate/incidente/kill |
| S18 `roblox-incident-response` | Live Analyst | alertas | incident issue, mitigación, RCA | `roblox-cloud-mcp` (kill switches pre-aprobados) | WRITE_CLOUD (runbook) / PROD con aprobación | auto (alerta) |
| S19 `roblox-asset-pipeline` (opcional) | Asset Producer | GDD §7–8, asset-spec | assets + LEDGER | Studio MCP generate_*, Blender MCP (exp.), `cloud.upload_asset` | WRITE_LOCAL, WRITE_CLOUD (tras policy) | user |
