# RISK-REGISTER (§87)

Probabilidad/Impacto: B (bajo), M (medio), A (alto), MA (muy alto). Owner = rol responsable (humano o agente).

| # | Riesgo | Probability | Impact | Detection | Mitigation | Owner |
|---|---|---|---|---|---|---|
| R01 | **Trend chasing** (llegar tarde a modas; clusters en `clone_wave`) | A | A | Estado `clone_wave`, vida media de clusters, retraso detección→lanzamiento | Penalizar saturación y moda en score; apostar a necesidades y combinaciones, no al top; lead time corto | Market Analyst + humano |
| R02 | **Low-quality content** | A | MA | G2 playtests, bounce <60 s, D1 vs benchmark | Gates G2/G4 estrictos; arte humano en lo clave; kill temprano | Game Designer + humano |
| R03 | **Clone risk** / penalización de discovery por no-unicidad | M | A | Originality report, quality status banner del dashboard | Pipeline no-clone, POL-011/012, Reviewer adversarial | Reviewer |
| R04 | **Copyright/IP** | M | MA | Policy scan, DMCA, rechazos de moderación | LEDGER obligatorio, sin IP de terceros (STOP-02), música licenciada | Reviewer + legal |
| R05 | **AI asset inconsistency** | A | M | Revisión de arte, feedback de playtests | Kits de arte humanos por género; IA sólo para relleno/variantes | Asset Producer + humano |
| R06 | **Technical debt** (código generado sin cohesión) | A | A | Métricas de CI, complejidad, bugs escapados | SDK + arquitectura por defecto + Reviewer + refactors programados | Engineer lead |
| R07 | **API dependency** (83% beta/experimental) | A | A | Tests de contrato semanales; changelog de creator-docs | Adaptadores aislados; fallbacks manuales; monitor de diffs del OpenAPI | Release Manager |
| R08 | **Roblox policy changes** (publicación, monetización, edad) | A | A | Diff trimestral/semanal de `Roblox/creator-docs` y DevForum | Policy engine actualizable; revisión humana; diversificar audiencias | Reviewer + humano |
| R09 | **Discovery volatility** (cambios de algoritmo) | A | A | Caídas bruscas de impresiones (Home Recommendations dashboard) | Optimizar retención real (señales documentadas), co-play, comunidad propia, notificaciones | Live Analyst |
| R10 | **Ad dependence** (juegos que sólo viven de UA) | M | A | % tráfico sponsored; ROAS | Ads sólo para medir/escalar con LTV>CAC; ranking no usa tráfico de ads | Humano |
| R11 | **Poor retention** | A | MA | D1/D7, play days D2–7/D8–28 | Gates, experimentos de onboarding, kill | Live Analyst |
| R12 | **Economy inflation** | M | A | Balance medio por cohorte, econsim vs real | econsim previo, sinks, configs para ajustar | Game Designer |
| R13 | **Exploits** | A | A | exploit_signals, anomalías económicas | NEVER TRUST THE CLIENT, Zap, rate limits, scanner, auditoría | Reviewer + Live Analyst |
| R14 | **Data loss** | B | MA | Errores de guardado, perfiles inválidos, tickets | ProfileStore, UpdateAsync, snapshots, migraciones testeadas, cuarentena | Engineer (data) |
| R15 | **Agent hallucination** (APIs/reglas inventadas) | A | A | Tests de contrato, CI, Reviewer, OpenAPI como fuente | "No inventes endpoints" en CLAUDE.md; cliente generado; etiquetas epistémicas | Todos |
| R16 | **Unsafe production changes** | M | MA | Audit log, alertas post-release | Niveles de permiso, plan_hash, aprobaciones, kill switches, rollback | Release Manager + humano |
| R17 | **Cost explosion** (tokens/loops, ads) | M | A | Presupuestos por work item y diarios; `agent_runs` | Cortes automáticos a 2×, modelos más baratos para bulk, batch, caching | Orchestrator + humano |
| R18 | **Portfolio maintenance burden** | A | A | Horas LiveOps/juego; juegos LIVE con ingresos < coste | MAINTENANCE automatizado, kill disciplinado, WIP limits | Humano (portfolio) |
| R19 | **Evaluación all-ages lenta o fallida** (2026-05) | M | A | Estado en Creator Hub | Diseñar para 16+ primero; promoción a 16+; actualizaciones | Humano |
| R20 | **Dependencia de Studio plane** (estación Win/macOS, MCP experimental) | M | M | Fallos de E2E | Mantener tests server-side A4 como red principal | Engineer |
| R21 | **Cuenta/grupo Roblox sancionado** (política) | B | MA | Notificaciones de moderación | Compliance estricto; cuentas separadas por función; sin prácticas de riesgo | Humano |
| R22 | **Legal/fiscal** (DevEx, impuestos, menores, privacidad) | M | A | Asesoría | STOP-04/05 resueltos antes de monetizar | Humano |
| R23 | **Prompt injection** desde datos externos | M | A | Revisión de acciones anómalas | Separación de agentes/permisos; datos externos como no confiables | Security |
| R24 | **Bus factor de dependencias OSS** (ProfileStore, Jest-Lua, Wally) | M | M | Actividad de repos | Wrappers; pin; plan de reemplazo | Engineer lead |
