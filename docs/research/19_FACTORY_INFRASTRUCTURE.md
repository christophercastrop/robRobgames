# 19 — Factory Infrastructure: control plane, KB, repos, build-vs-buy, diagrama

## 1. Diagrama final (§71) — arquitectura recomendada

```text
                               ┌────────────── HUMANOS ──────────────┐
                               │ Portfolio review semanal · approvals │
                               │ playtests · arte clave · legal       │
                               └──────────────┬──────────────────────┘
                                              │ (GitHub Environments / Issues)
┌─────────────────────────────── FACTORY CONTROL PLANE (Cloud plane, Linux) ────────────────────────────────┐
│  Orchestrator (Python, state machine, colas, presupuestos)  ◄──►  Factory DB (Postgres + pgvector)          │
│      │                                                            games · opportunities · experiments ·      │
│      │ lanza subagentes (Claude Code headless / Agent SDK)        trends · costs · audit_log · kb_index      │
│      ▼                                                                                                        │
│  Market Analyst ─ Game Designer ─ Engineers ─ Reviewer ─ Release Mgr ─ Live Analyst   (Skills S01–S19)        │
│      │                │              │           │           │              │                               │
│  Trend Engine     econsim         GitHub CI   policy/sec   roblox-cloud-mcp (permisos, dry-run, auditoría)  │
│  (collectors)                     (Lune/Rojo/  scanners         │                                            │
│                                    luau-lsp)                    ▼                                            │
└──────────────────────────────────────────────────────── Roblox Open Cloud ─────────────────────────────────┘
                                                   │ publish · Luau Execution · configs · experiments ·
                                                   │ analytics · server logs · datastores · assets
┌────────── STUDIO PLANE (Win/macOS) ──────────┐    ▼
│ Claude Code + Studio MCP oficial + rojo serve │  Universes: CI ─► STAGING ─► (human approval) ─► PRODUCTION
│ playtests, UI/visual QA, world blockouts      │                                                   │
└───────────────────────────────────────────────┘                                                  Players
                                                                                                    │
         Knowledge Base (Git: knowledge/) ◄── Live Analyst / postmortems ◄── Analytics + logs + experiments
                 │
                 └──► Market Intelligence / Opportunity priors / Designer / SDK (siguiente juego)
```

Diferencias vs el diagrama del brief: (1) el **Director** es código + humano (no un LLM autónomo); (2) dos **planos de ejecución** explícitos;
(3) el **MCP de Roblox se divide** en Studio MCP oficial y `roblox-cloud-mcp` (capa de permisos); (4) QA/Security es un **revisor independiente**;
(5) el bucle de aprendizaje alimenta **priors cuantitativos** del Opportunity Engine, no sólo "conocimiento".

## 2. Control plane (§68): ¿aplicación propia?

| Necesidad | Solución por fase |
|---|---|
| Games, estados, gates | Fase 1–6: `STATE.yaml` + GitHub Issues/Projects + tabla `games`. Fase 9: UI mínima |
| Concepts, GDDs | Git (Markdown/YAML) |
| Experiments | Experiments nativo + `knowledge/experiments/` + tabla |
| Agents (runs, coste) | Tabla `agent_runs` (tokens, duración, resultado) desde el orquestador; Claude Console/Admin API para facturación |
| Builds, deployments | GitHub Actions + Releases + tabla `releases` |
| Metrics | Warehouse (Postgres) + Metabase/Grafana |
| Economy / LiveOps | YAML en Git + configs nativos |
| Incidents | GitHub Issues con labels |
| Knowledge | Git (`knowledge/`) + índice vectorial (pgvector) |
| Costs | Tabla `costs` (LLM, infra, Robux ads, horas humanas) |

**[DEC-027]** No construir una aplicación de control plane propia hasta que se gestionen ≥5 juegos activos (Escenario C). Antes: GitHub + Postgres + Metabase.

## 3. Knowledge flywheel (§59–60)

Estructura de un finding (`knowledge/<area>/<id>.md`):

```yaml
id: KB-ONB-0007
area: onboarding            # mechanics|experiments|code|bugs|performance|onboarding|retention|economy|monetization|creative
claim: "Primera recompensa antes de 30 s reduce first-play bounce <60s"
evidence: [EXP-gardenx-003]  # links a experimentos/incidentes/análisis
effect: {metric: first_play_bounce_60s, delta: -4.1pp, ci95: [-6.0, -2.2], n: 8400}
context: {genre_l2: "Incremental Simulator", audience: "16+ soft launch", platform_mix: "70% mobile", date: 2026-11}
scope: game                 # game → genre (≥2 juegos del género) → global (≥3 géneros)
confidence: medium
review_by: 2027-05-01
status: validated|superseded|refuted
```

Reglas anti-sobregeneralización: un finding sólo sube de `scope` cuando se **replica**; los agentes de diseño deben citar el `scope` y el `context` al usar un finding;
findings con `review_by` vencido se degradan a `hypothesis`. Patrones de código se convierten en **código del SDK o reglas de lint**, no en prosa.

## 4. Repositorios (§72): monorepo vs multi-repo

| Opción | Ventajas | Desventajas |
|---|---|---|
| Multi-repo (`roblox-factory`, `roblox-game-sdk`, `roblox-mcp`, `roblox-skills`, `roblox-analytics`, `game-template`, `game-{name}`) | Permisos por repo, releases independientes | Versionado cruzado del SDK, PRs multi-repo, agentes necesitan varios checkouts, skills duplicadas |
| **Monorepo** | Un checkout para el agente, cambios atómicos SDK+juegos, CI de compatibilidad trivial, skills/CLAUDE.md únicos, búsqueda global | Permisos más gruesos, CI debe filtrar por paths, crecimiento del repo (assets fuera de Git) |

**[DEC-001] Monorepo** (`roblox-factory`) mientras haya ≤10 juegos activos; extraer a repo propio sólo: (a) juegos con colaboradores externos que no deben ver el resto,
(b) el SDK si se decide publicarlo open source. Assets binarios grandes fuera de Git (subidos a Roblox; LEDGER guarda IDs + hashes; fuentes .blend en almacenamiento de objetos).

## 5. Build vs Buy (§70)

| Componente | Decisión | Justificación |
|---|---|---|
| Sync Git↔Studio | **USE OPEN SOURCE** (Rojo) | Estándar, activo |
| Toolchain CLIs | **USE OPEN SOURCE** (Rokit, StyLua, Selene, luau-lsp, Lune, Wally) | — |
| Test framework engine | **USE OPEN SOURCE** (Jest-Lua) | Usado por Roblox |
| Test runner en la nube | **BUY** (Open Cloud Luau Execution, gratis) + **WRAP** (script de runner) | Oficial |
| Studio MCP | **BUY** (oficial, gratis) | No construir |
| Open Cloud MCP | **BUILD (fino)** → **WRAP** del oficial cuando exista | El valor es la capa de permisos |
| GitHub MCP | **USE OPEN SOURCE** (oficial) | — |
| Orchestrator | **BUILD (mínimo)** sobre Claude Agent SDK / `claude -p` | Lógica de negocio propia (state machine, gates) |
| Remote config / flags | **BUY** (ConfigService) + **WRAP** (SDK) | Nativo |
| A/B testing | **BUY** (Experiments nativo) + **WRAP** (plantilla, exposición) | Nativo |
| Analytics básica | **BUY** (Roblox Analytics + Query API) | Nativo, alineado con discovery |
| Warehouse | **USE OPEN SOURCE** (Postgres) + Metabase | Barato |
| Trend Engine | **BUILD** | Ventaja competitiva, no existe como producto con API |
| Opportunity Engine | **BUILD** | Ventaja competitiva |
| Economy simulator | **BUILD** (numpy) | Específico del `economy.yaml` |
| Player data (session locking) | **USE OPEN SOURCE** (ProfileStore) + **WRAP** | Probado |
| Networking | **USE OPEN SOURCE** (Zap/Blink) | Codegen tipado |
| UI framework | **USE OPEN SOURCE** (Vide) + **BUILD** design system | Identidad propia |
| Game SDK | **BUILD** | Núcleo reutilizable de la fábrica |
| Policy engine | **BUILD** | No existe; crítico |
| Security scanner | **BUILD** (Lune) | Pequeño |
| Knowledge base | **BUILD (Git + pgvector)** | Simple |
| Control plane UI | **DO NOT BUILD** (hasta Escenario C) | YAGNI |
| Bots de E2E multi-cliente en servidores publicados | **DO NOT BUILD** | ToS; no oficial |
| Scraping de sorts/charts no documentados | **DO NOT BUILD** (⛔ STOP-01) | ToS |
| Propio framework de ECS/red/UI | **DO NOT BUILD** | Existen opciones mantenidas |
| Generador 3D propio | **DO NOT BUILD** | Usar Roblox generate_* / Blender |
| Device farm | **DO NOT BUILD** (dispositivos físicos baratos + humanos) | Coste/beneficio |

## 6. Infraestructura concreta (LEAN → SCALE)

| Pieza | LEAN | PROFESSIONAL | SCALE |
|---|---|---|---|
| Código/CI | GitHub (Team) + Actions | + runners self-hosted Linux | + runners dedicados, cachés |
| Studio plane | 1 PC/Mac del operador | 1 workstation dedicada (Win) para agente + 1 humano | 2–3 workstations |
| DB | Postgres gestionado pequeño (Neon/Supabase/RDS micro) | Postgres 2–4 vCPU | + réplica, Timescale |
| Jobs | GitHub Actions schedule | VPS pequeño con cron/queue (o Cloud Run jobs) | Cola (Redis/RQ) + workers |
| Dashboards | Metabase OSS | Metabase/Grafana | + alerting |
| Secretos | GitHub Environments | + Vault/1Password | idem |
| LLM | Plan Claude Max + API pay-as-you-go | API con presupuestos por workspace | + Batch API para bulk |
| Observabilidad de la fábrica | logs de Actions + tabla `agent_runs` | + trazas (OpenTelemetry opcional) | idem |

## 7. Escenarios de escala (§86)

| Escenario | Agentes (instancias) | Infra | LiveOps | Soporte/CM | QA | Observabilidad | Humanos (FTE aprox.) [EST] |
|---|---|---|---|---|---|---|---|
| **A: 1 juego** | 1 de cada rol, Engineers 1–2 | LEAN | Calendario manual asistido | 0.1 FTE | Humano 4 h/semana | Dashboard básico | 1 (founder-operator) |
| **B: 3 juegos** | Engineers 2–4, Live Analyst compartido | LEAN→PRO | Calendarios con plantillas | 0.3 | 8–12 h/semana | Alertas por juego | 1.5–2 |
| **C: 10 juegos** | Engineers 4–8 (colas), 2 Live Analysts | PRO | Plantillas + A3 para contenido pre-aprobado | 1 (CM + soporte) | 1 QA humano | Panel de fábrica + on-call | 3–5 |
| **D: 25+** | Pools de Engineers, orquestación con prioridades | SCALE | LiveOps "motor" + artista de contenido | 2–3 | 2 QA + device lab | SRE part-time | 6–10 |

[INFERENCIA] El cuello de botella al escalar no es el código (paralelizable) sino **arte coherente, playtests humanos, LiveOps de contenido y community
management**; por eso la estrategia de portfolio mata pronto y mantiene pocos juegos LIVE con LiveOps real (juegos en MAINTENANCE con LiveOps mínimo automatizado).
