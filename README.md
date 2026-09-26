# ROBLOX AUTONOMOUS GAME FACTORY — Research & Blueprint

Investigación, arquitectura y blueprint E2E para una fábrica de juegos Roblox progresivamente automatizada
(Claude Code + Skills + MCP + Roblox Studio + Open Cloud + CI/CD + analytics + LiveOps).

**Fecha de corte de la investigación: 2026-09-26.** Todo lo marcado como `[HECHO VERIFICADO]` fue contrastado
ese día contra documentación oficial de Roblox (Creator Hub / repo `Roblox/creator-docs`, commit del 2026-09-26),
el OpenAPI oficial de Open Cloud, anuncios oficiales del DevForum o repositorios Git (fecha del último commit).

## Cómo leer esto

1. Empieza por [`docs/RECOMMENDED-ARCHITECTURE.md`](docs/RECOMMENDED-ARCHITECTURE.md) (documento final, secciones A–T + Top 20 next actions).
2. Después [`docs/research/00_EXECUTIVE_SUMMARY.md`](docs/research/00_EXECUTIVE_SUMMARY.md).
3. Para implementar: [`docs/FACTORY-BACKLOG.md`](docs/FACTORY-BACKLOG.md) y [`docs/research/21_IMPLEMENTATION_ROADMAP.md`](docs/research/21_IMPLEMENTATION_ROADMAP.md).

## Índice

| # | Documento | Contenido |
|---|---|---|
| — | [RECOMMENDED-ARCHITECTURE](docs/RECOMMENDED-ARCHITECTURE.md) | Arquitectura final recomendada (A–T), Top 20 next actions |
| 00 | [EXECUTIVE_SUMMARY](docs/research/00_EXECUTIVE_SUMMARY.md) | Visión, conclusiones, respuesta a la pregunta económica central |
| 01 | [ROBLOX_ECOSYSTEM_2026](docs/research/01_ROBLOX_ECOSYSTEM_2026.md) | Estado de Roblox a sept-2026: engine, servicios, publicación, plataforma |
| 02 | [TOOLCHAIN](docs/research/02_TOOLCHAIN.md) | Toolchain seleccionado, Git↔Studio workflow, librerías |
| 03 | [ROBLOX_OPEN_CLOUD](docs/research/03_ROBLOX_OPEN_CLOUD.md) | APIs verificadas (endpoint, scope, rate limit, estabilidad) |
| 04 | [MCP_ARCHITECTURE](docs/research/04_MCP_ARCHITECTURE.md) | MCP existentes, Studio MCP oficial, `roblox-cloud-mcp`, permisos |
| 05 | [CLAUDE_SKILLS](docs/research/05_CLAUDE_SKILLS.md) | Skills definitivas (fusiones y descartes) |
| 06 | [AGENT_ARCHITECTURE](docs/research/06_AGENT_ARCHITECTURE.md) | Sistema multiagente, orquestador, state machine |
| 07 | [TREND_INTELLIGENCE](docs/research/07_TREND_INTELLIGENCE.md) | Motor de tendencias, esquema, fórmulas de crecimiento, clasificación |
| 08 | [OPPORTUNITY_ENGINE](docs/research/08_OPPORTUNITY_ENGINE.md) | Scoring, portfolio, stage gates, kill system |
| 09 | [GAME_PRODUCTION_PIPELINE](docs/research/09_GAME_PRODUCTION_PIPELINE.md) | Pipeline E2E, concept generator, GDD, CI/CD, entornos |
| 10 | [SHARED_GAME_SDK](docs/research/10_SHARED_GAME_SDK.md) | SDK común, arquitectura de juegos, template |
| 11 | [QA_E2E](docs/research/11_QA_E2E.md) | Testing, E2E, visual QA, performance gates, device matrix |
| 12 | [SECURITY](docs/research/12_SECURITY.md) | Never trust the client, anti-exploit, data safety |
| 13 | [ANALYTICS](docs/research/13_ANALYTICS.md) | Analytics, taxonomía de eventos, métricas, dashboard, incidentes |
| 14 | [MONETIZATION](docs/research/14_MONETIZATION.md) | Economía, monetización oficial, simulador, unit economics |
| 15 | [DISCOVERY_AND_GROWTH](docs/research/15_DISCOVERY_AND_GROWTH.md) | Discovery, creative optimization, ads |
| 16 | [LIVEOPS](docs/research/16_LIVEOPS.md) | Plataforma LiveOps, configs, experiments |
| 17 | [ASSET_PIPELINE](docs/research/17_ASSET_PIPELINE.md) | 2D/3D/audio/anim, Blender MCP, UI factory, localización |
| 18 | [COMPLIANCE](docs/research/18_COMPLIANCE.md) | Políticas, Factory Policy Engine, no-clone controls |
| 19 | [FACTORY_INFRASTRUCTURE](docs/research/19_FACTORY_INFRASTRUCTURE.md) | Control plane, memoria, observabilidad, repos, build-vs-buy |
| 20 | [COST_MODEL](docs/research/20_COST_MODEL.md) | Costes, presupuestos LEAN/PRO/SCALE, escenarios A–D, Robux→beneficio |
| 21 | [IMPLEMENTATION_ROADMAP](docs/research/21_IMPLEMENTATION_ROADMAP.md) | Fases, MVP, piloto, 30 y 90 días, KPIs de fábrica |

Entregables transversales:

- [TOOLS-INVENTORY](docs/inventories/TOOLS-INVENTORY.md) · [MCP-INVENTORY](docs/inventories/MCP-INVENTORY.md) · [SKILLS-INVENTORY](docs/inventories/SKILLS-INVENTORY.md)
- [AGENT-MATRIX](docs/inventories/AGENT-MATRIX.md) · [AUTONOMY-MATRIX](docs/inventories/AUTONOMY-MATRIX.md) · [DATA-SOURCES](docs/inventories/DATA-SOURCES.md)
- [DECISIONS](docs/DECISIONS.md) · [FACTORY-BACKLOG](docs/FACTORY-BACKLOG.md) · [RISK-REGISTER](docs/RISK-REGISTER.md)
- [RED-TEAM](docs/RED-TEAM.md) · [REALITY-MATRIX](docs/REALITY-MATRIX.md) · [SOURCES](docs/SOURCES.md)
- [`docs/data/open-cloud-endpoints.txt`](docs/data/open-cloud-endpoints.txt): extracción de 230 operaciones Open Cloud relevantes desde el OpenAPI oficial.

## Disciplina epistémica (leyenda usada en todos los documentos)

| Etiqueta | Significado |
|---|---|
| `[HECHO VERIFICADO]` | Confirmado en documentación oficial, OpenAPI oficial, anuncio oficial o repositorio (fuente primaria) |
| `[HECHO DE TERCEROS]` | Documentado por fuente secundaria fiable; no contrastado en primaria |
| `[INFERENCIA]` | Conclusión razonable derivada de varios hechos |
| `[HIPÓTESIS]` | Requiere validación experimental |
| `[ESTIMACIÓN]` | Número calculado con supuestos explícitos |
| `[DECISIÓN PROPUESTA]` | Elección arquitectónica/de producto pendiente de aprobación humana |
| `⛔ STOP` | Condición de parada: decisión humana necesaria antes de construir |

En tablas se abrevia: **HV**, **HT**, **INF**, **HIP**, **EST**, **DEC**.
