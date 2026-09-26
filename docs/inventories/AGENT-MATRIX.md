# AGENT-MATRIX

Ver `docs/research/06_AGENT_ARCHITECTURE.md`. "Can Write" = escritura en repo (Git); "Can Publish" = publicación en Roblox.

| Agent | Responsibility | Skills | MCP | Can Write | Can Publish | Human Gate |
|---|---|---|---|---|---|---|
| Orchestrator (código) | State machine, colas, presupuestos, asignación, gates técnicos | — (invoca subagentes) | GitHub MCP | Sólo `STATE.yaml`/issues | No | Transiciones de producto (G0, G1, G2, G4–G6, KILL) |
| Market Analyst | Trends, oportunidades, monetización visible | S01, S02 | GitHub (issues), Postgres read-only (opc.) | `research/`, `opportunities/` | No | G0 en portfolio review |
| Game Designer | Conceptos, GDD, economía, plan LiveOps, originalidad | S03, S04, S05, (S16 plan), (S19 briefs) | GitHub | `games/<slug>/design/`, `config/economy.yaml` | No | G1 (elección de concepto), aprobación de GDD |
| Engineer (1..N, cloud) | Implementar WPs, tests | S06, S07, S08, S09, S10 | GitHub; `roblox-cloud-mcp` (RUN_TESTS en CI) | `games/**`, `packages/**` vía PR | No (sólo place CI) | Merge requiere Reviewer + CI; humano en cambios de SDK núcleo |
| Studio Engineer (Studio plane) | Playtests, UI/visual QA, blockouts | S07, S10, S19 | **Studio MCP oficial** | Vía PR (Rojo) | No | Humano revisa capturas de UI |
| Reviewer (QA+Sec+Policy, fork) | Revisión independiente, bloqueo | S10, S11, S12, S09 | GitHub (comentarios) | No (sólo informes) | No | Humano resuelve WARN de policy |
| Release Manager | Staging, planes de producción, rollback | S13 | `roblox-cloud-mcp` (PUBLISH_STAGING) | `release/` | **Staging sí; producción sólo con aprobación** | **Siempre** para producción, economía, restart |
| Live Analyst | Métricas, experimentos, LiveOps, incidentes, KB | S14, S15, S16, S17, S18 | `roblox-cloud-mcp` (READ, WRITE_CLOUD acotado) | `knowledge/`, `config/liveops/` | Configs no económicos (A3); económicos con aprobación | Experimentos de precio, ofertas, bans permanentes, rollback |
| Asset Producer (opcional) | Briefs, variantes, validación de assets | S19 | Studio MCP (generate_*), Blender MCP (exp.) | `assets/` | Subida de assets tras policy scan | Arte final, música, IP |
