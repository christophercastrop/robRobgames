# 06 — Agent Architecture, Orchestrator y State Machine

## 1. Crítica de la jerarquía propuesta en el brief

La jerarquía de ~16 agentes (Director → Market, Strategy, Design, TD{Gameplay, Backend, UI, Data, Perf}, Art, QA, Security, Economy,
Monetization, Growth, Analytics, LiveOps) replica un organigrama humano. Con agentes LLM esto es **ineficiente** [INFERENCIA]:

1. **Coste de coordinación**: cada frontera entre agentes obliga a serializar contexto en artefactos; 16 agentes ⇒ muchas fronteras con poco valor.
2. **Contexto duplicado**: Gameplay/Backend/UI/Data comparten el mismo repo, SDK y convenciones; separarlos multiplica tokens de lectura.
3. **Responsabilidad difusa**: "Economy" vs "Monetization" vs "Growth" discuten el mismo modelo sources/sinks/pricing.
4. **Lo que sí debe separarse** no es la especialidad sino la **independencia**: quien implementa no debe ser quien audita (seguridad, QA, políticas),
   y quien propone gastar/cambiar precios no debe poder ejecutarlo.

**Principio de diseño**: separar agentes por **(a) permisos**, **(b) independencia de revisión** y **(c) plano de ejecución** (cloud vs Studio);
especializar mediante **skills**, no mediante agentes.

## 2. Arquitectura propuesta [DEC-012]

```text
                    ┌──────────────────────────────────────────────┐
                    │ Factory Orchestrator (código determinista)   │
                    │ state machine · colas · gates · presupuesto  │
                    └───────────────┬──────────────────────────────┘
                                    │ asigna work items (GitHub Issues)
     ┌───────────────┬──────────────┼───────────────┬────────────────┬───────────────┐
     ▼               ▼              ▼               ▼                ▼               ▼
 Market Analyst  Game Designer   Engineer(s)    Reviewer (QA+Sec+   Release Mgr    Live Analyst
 (S01,S02)       (S03,S04,S05,   (S06,S07,S08,  Policy) (S10,S11,   (S13)          (S14,S15,S16,
                  S16 plan,S19)   S09,S10)       S12) — fork,       gated perms     S17,S18)
                                  N en paralelo  independiente
     │               │              │               │                │               │
     └──── artefactos en Git (YAML/MD) + factory DB ─┴──── Human approvals (GitHub Environments) ─┘
```

| Agente | Tipo | Modelo sugerido [DEC] | Por qué existe separado |
|---|---|---|---|
| **Orchestrator** | Código Python (no LLM) + un LLM "planner" invocado puntualmente | Opus (planner) | Las transiciones de estado, presupuestos y gates deben ser deterministas y auditables |
| **Market Analyst** | Subagente Claude Code (cloud) | Sonnet (bulk) / Opus (síntesis) | Trabaja sobre datos, permisos READ |
| **Game Designer** | Subagente | Opus | Decisiones de producto de alto impacto; necesita contexto amplio del juego |
| **Engineer** (1..N) | Subagente(s) en worktrees aislados; uno "Studio Engineer" en Studio plane | Opus / Sonnet para WPs simples | Paralelizable por work package; permisos WRITE_LOCAL/RUN_TESTS |
| **Reviewer** (QA + Security + Policy) | Subagente `context: fork`, sin acceso de escritura al código | Opus | **Independencia**: no ve el razonamiento del Engineer; bloquea merges |
| **Release Manager** | Subagente con acceso a `roblox-cloud-mcp` | Sonnet | Único con PUBLISH_STAGING; prepara planes para aprobación humana |
| **Live Analyst** | Subagente programado (cron) | Sonnet (monitorización) / Opus (análisis) | Bucle post-lanzamiento: métricas, experimentos, LiveOps, incidentes, KB |
| **Asset Producer** (opcional) | Subagente + humano | — | A1: genera briefs y variantes; humano cura |

Total: **6 roles LLM + orquestador** (7 con Asset Producer). Escala horizontal = más instancias de Engineer y más juegos en paralelo, no más tipos de agente.

## 3. Factory Orchestrator (§66)

**Responsabilidades** y su implementación:

| Responsabilidad | Implementación | Autonomía |
|---|---|---|
| Opportunity discovery | Job diario: ingesta trends → features → candidatos → S01/S02 | A3 |
| Portfolio management | Asignación de presupuesto (horas-agente, €) por estado; límite WIP por estado | A1 (propone) / humano decide |
| Task decomposition | S04 genera work packages; orquestador los convierte en Issues con dependencias | A3 |
| Agent assignment | Regla: tipo de WP → rol; cola por prioridad; límite de concurrencia | A3 |
| Artifact management | Git (artefactos) + factory DB (índice, estado, métricas) | A3 |
| Quality gates | CI checks + Reviewer + policy engine; gates de producto con umbrales calibrados | A3 técnica / A2 producto |
| Testing | CI + playtests programados | A3 |
| Publishing coordination | Release Manager + GitHub Environments | A2 |
| LiveOps coordination | Calendario en DB, ejecución vía configs | A2→A3 (contenido pre-aprobado) |
| Analytics feedback | Live Analyst → informes → propuestas de backlog | A3 análisis / A1 decisiones |

**Stack** [DEC-014]: Python (FastAPI mínimo o sólo CLI + cron), Postgres, GitHub Issues/Projects como cola visible, Claude Code headless (`claude -p`)
o **Claude Agent SDK** para lanzar subagentes desde el orquestador. No se construye UI propia hasta Fase 9 (ver `19_FACTORY_INFRASTRUCTURE.md`).

**Presupuestos**: cada work item lleva `token_budget` y `wall_clock_budget`; el orquestador corta y escala a humano si se excede 2× (evita loops caros).

## 4. State machine del juego (§67)

```text
DISCOVERED → RESEARCHING → CONCEPT → VALIDATING → PROTOTYPE → MVP → QA → SOFT_LAUNCH → LIVE → SCALING
                 │            │          │            │         │      │        │           │       │
                 └────────────┴──────────┴────────────┴─────────┴──────┴────────┴───────────┴───────┴──► KILLED → ARCHIVED
                                                                          PAUSED ◄──► (cualquier estado activo)
LIVE/SCALING → MAINTENANCE (LiveOps mínimo) → KILLED/ARCHIVED
```

| Transición | Gate | Evidencia requerida | Quién decide |
|---|---|---|---|
| DISCOVERED→RESEARCHING | G0a: señal de mercado | Candidate con score ≥ umbral de cola | Orquestador (A3) |
| RESEARCHING→CONCEPT | **G0 Market Signal** | Opportunity report (S02), riesgo IP ≤ medio | Humano (A2) en la revisión semanal de portfolio |
| CONCEPT→VALIDATING | **G1 Concept** | 3–5 conceptos, originality PASS, diferenciación explícita | Humano elige 1 |
| VALIDATING→PROTOTYPE | G1b | Validación barata: *fake-door* (no aplica en Roblox para usuarios reales sin juego) ⇒ en su lugar: playtest de paper-prototype/greybox interno + revisión de 2 humanos | Humano |
| PROTOTYPE→MVP | **G2 Prototype (¿es divertido?)** | Greybox jugable; playtest con ≥5–10 humanos externos al equipo; métricas cualitativas + tiempo de sesión en playtest | Humano |
| MVP→QA | **G3 MVP (¿funciona técnicamente?)** | Todos los checks CI, perf gates, security 0 críticos, policy PASS, persistencia probada | Automático (A3) |
| QA→SOFT_LAUNCH | G3b Release | Aprobación de release a audiencia **16+** (requisito de plataforma), questionnaire enviado | Humano |
| SOFT_LAUNCH→LIVE | **G4 Retention** + **G5 Monetization** | Ver `08_OPPORTUNITY_ENGINE.md` §5 (umbrales relativos a benchmarks de género) y evaluación de Roblox para all-ages completada | Humano |
| LIVE→SCALING | **G6 Scale** | Unit economics positivos con UA de prueba, LTV/CAC | Humano (gasto) |
| cualquier→KILLED | Kill criteria | `08_OPPORTUNITY_ENGINE.md` §6 | Humano (propuesto por Live Analyst) |
| cualquier→PAUSED | Capacidad/prioridad | — | Humano |
| KILLED→ARCHIVED | Postmortem + KB | S17 completado; universe a privado; datos retenidos según política | Automático tras postmortem |

Estado persistido en `games` (factory DB) y espejado en `games/<slug>/STATE.yaml` para que cualquier agente lo lea sin DB.

## 5. Flujo "fábrica" (§83) mapeado a agentes

| Paso | Agente | Artefacto | Autonomía segura hoy |
|---|---|---|---|
| 1. Trend Engine detecta oportunidad | job + Market Analyst | `trend_alerts` | A3 |
| 2. Opportunity Engine evalúa | Market Analyst (S02) | `opportunities/<id>.yaml` | A3 (score) / A1 (recomendación) |
| 3. Portfolio Manager autoriza prototipo | **Humano** (con propuesta del planner) | decisión en `DECISIONS` del portfolio | A1 |
| 4. Game Designer produce GDD | Game Designer (S03–S05) | `GDD.md`, `economy.yaml` | A2 (humano aprueba GDD) |
| 5. Technical Director genera arquitectura | Engineer "lead" (S06) | `design/TECH.md`, WPs | A2 |
| 6. Agentes desarrollan | Engineers | PRs | A3 dentro de CI + review |
| 7. QA ejecuta tests | CI + Reviewer (S10) | reports | A3 |
| 8. Security revisa | Reviewer (S11) | `security-report.md` | A3 (bloqueo automático en críticos) |
| 9. Staging publica | Release Manager | place version | A3 |
| 10. Human playtest | **Humanos** (+ agente Studio para smoke) | `playtest-notes.md` | A0/A1 |
| 11. Production launch | Release Manager + **aprobación humana** | release record | A2 |
| 12. Analytics recoge datos | SDK + Roblox Analytics + ingest | warehouse | A3 |
| 13. Product Agent analiza | Live Analyst (S14) | informe semanal | A3 |
| 14. LiveOps propone cambios | Live Analyst (S16) | propuestas | A1–A2 |
| 15. Experimentos validan | Live Analyst (S15) + Experiments nativo | experiment record | A2 (lanzar) / A3 (leer) |
| 16. KB almacena aprendizajes | S17 | `knowledge/*` | A3 con revisión humana mensual |
| 17. Aprendizajes influyen | S01–S05 leen KB con filtros de scope | — | A3 |

## 6. Memoria de agentes (§61)

| Capa | Contenido | Dónde | Quién escribe | Caducidad |
|---|---|---|---|---|
| Global knowledge | Principios Roblox, políticas, SDK, patrones validados en ≥2 juegos | `knowledge/global/` + CLAUDE.md | S17 + humano | Revisión trimestral |
| Genre knowledge | Benchmarks y patrones por `genre_l1/l2` | `knowledge/genres/<genre>.md` | S01, S17 | Revisión trimestral |
| Game knowledge | GDD, decisiones, estado, deuda técnica | `games/<slug>/design/`, `STATE.yaml` | Designer, Engineers | Vida del juego |
| Experiment knowledge | Hipótesis, diseño, resultado, decisión | `knowledge/experiments/<id>.md` + tabla `experiments` | S15 | Permanente (con contexto) |
| Player behavior knowledge | Hallazgos de retención/onboarding/monetización | `knowledge/player/` | S14, S17 | Revisión semestral |
| Technical knowledge | Bugs, perf findings, incidentes | `knowledge/engineering/` | Engineers, S18 | Hasta que el SDK lo absorbe |

Los agentes **no** tienen memoria implícita entre sesiones: toda memoria es explícita en Git/DB (auditable, versionada, revisable).
