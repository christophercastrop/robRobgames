# 21 — Implementation Roadmap, MVP de la fábrica, Piloto, 30/90 días y KPIs

## 1. Orden de fases (§80) — modificado por dependencias

Cambios respecto al orden del brief y por qué:
- **El Trend collector arranca en la Fase 1**, no en la 6: necesita **≥90 días de histórico** para backtesting; recolectar es barato; analizar puede esperar.
- **No hay "Fase MCP de Studio"**: el MCP oficial ya existe (se configura en la Fase 1). `roblox-cloud-mcp` se construye **mínimo** en la Fase 3 porque el piloto
  lo necesita para publicar con permisos.
- **Analytics se instrumenta dentro del SDK (Fase 2)**, no después: sin eventos desde el día 1, el soft launch no produce datos útiles.
- **Orchestrator al final**: primero se automatiza cada paso con humanos coordinando; sólo se orquesta lo que ya funciona manualmente.

| Fase | Contenido | Semanas | Salida verificable |
|---|---|---|---|
| **F0** | Investigación y arquitectura | hecho | Estos documentos |
| **F1** | Toolchain, monorepo, CI estático, Studio plane (MCP oficial), universes CI/staging, **trend collector** | 1 | `rokit install && rojo build` en CI verde; snapshots horarios en DB |
| **F2** | Game template + SDK core (Loader, Net/Zap, PlayerData, Economy, Products, Policy, RemoteConfig, Analytics, Observability) + engine tests vía Luau Execution | 2–4 | Juego "hello-factory" con compra de prueba, guardado y eventos; tests de engine en CI |
| **F3** | Skills v1 (S04, S06, S10, S11, S12, S13) + subagentes + hooks; `roblox-cloud-mcp` v0 (READ, RUN_TESTS, publish CI/staging, snapshot, audit) | 3–5 | Un WP implementado de punta a punta por agentes con PR revisado y staging publicado |
| **F4** | **Piloto**: concept→GDD→MVP; econsim v0; policy engine v0; security scanner; E2E Studio MCP | 5–10 | MVP pasa G3 |
| **F5** | Soft launch 16+, Analytics Query ingest, dashboards, Experiments, LiveOps v1 (daily, quests, eventos), incident runbooks | 10–13 | Datos G4 en curso; primer experimento |
| **F6** | Trend Engine v1 (features, estados, clasificación, backtest) + Opportunity Engine v1 | 12–16 | Informe de oportunidades con backtest; selección del juego 2 |
| **F7** | Orchestrator (state machine + colas + presupuestos) + portfolio review semanal asistida | 16–22 | 2 juegos en paralelo con coordinación automática |
| **F8** | Asset pipeline ampliado (Blender MCP experimental, creative variants), localización automatizada | 20+ | Kits reutilizables; tests de thumbnails |
| **F9** | Control plane UI, escalado (Escenario C) | cuando ≥5 juegos | — |

## 2. MVP de la fábrica (§81)

El **mínimo sistema** que demuestra `idea → game design → implementation → automated tests → staging → human playtest → publish → analytics`:

| Paso | Componente mínimo | Qué NO se construye aún |
|---|---|---|
| idea | Revisión manual de Charts + Trend collector (datos) + skill S01 manual | Opportunity Engine automático |
| game design | Skills S03–S05 + plantillas GDD/economy.yaml | Concept generator automático |
| implementation | Monorepo + SDK core + S06 + Claude Code (Engineer) | Múltiples Engineers en paralelo |
| automated tests | Lune unit + Jest-Lua vía Luau Execution + security scan | Visual QA con visión |
| staging | `roblox-cloud-mcp` v0 publish + GitHub Environment | Canary/rollout |
| human playtest | Guion + formulario; Studio MCP smoke | E2E exhaustivo |
| publish | Aprobación humana + publish | Automatización de releases |
| analytics | AnalyticsService (taxonomía) + dashboard nativo + Query API manual | Warehouse propio |

## 3. Proyecto piloto (§82)

**Objetivo**: validar toolchain, agentes, skills, MCP, SDK, QA, publishing, analytics y LiveOps — **no** maximizar ingresos.

Criterios de selección de género (ponderados) [DEC-028]:

| Criterio | Peso |
|---|---|
| Ejercita economía + monetización + LiveOps + analytics (cobertura del SDK) | 30% |
| Bajo content burden y arte modular/estilizado | 20% |
| Lógica server-authoritative simple y testeable sin cliente | 15% |
| Compatible con rating Minimal/Mild y sin paid random items en el núcleo | 10% |
| Mobile-first viable | 10% |
| Co-play natural | 10% |
| Demanda existente (Trend collector) y posibilidad de diferenciarse | 5% (el piloto no busca ganar mercado) |

Shortlist evaluada con la taxonomía oficial:

| Candidato (genre → subgenre) | Cobertura SDK | Contenido | Testeable server-side | Co-play | Riesgo clon | Veredicto |
|---|---|---|---|---|---|---|
| Obby & platformer → Classic/Tower Obby | Baja (economía pobre) | Medio (niveles) | Media (física) | Baja | Muy alto | No |
| Simulation → **Incremental Simulator** | **Muy alta** (sources/sinks, prestige, boosts, passes, quests) | **Bajo-medio** | **Alta** | Media (co-op opcional) | Alto → exige diferenciación | **Recomendado** con giro original (tema + meta-loop cooperativo) |
| Simulation → Tycoon | Alta | Medio-alto (construcción) | Alta | Media | Alto | Alternativa |
| Strategy → Tower Defense | Alta | Alto (unidades, mapas, balance) | Media | Alta | Medio | Segundo juego |
| Puzzle → Match & Merge | Media | Medio (UI) | Alta | Baja | Medio | Alternativa mobile |
| Party & casual → Minigame | Media | **Alto** (N minijuegos) | Media | **Muy alta** | Medio | No para piloto |

**Decisión propuesta**: piloto = **Incremental Simulator cooperativo de sesión corta** (1 place, 2–4 jugadores comparten un objetivo de grupo diario además del progreso
individual), tema original elegido en el Gate 1 tras 2–3 semanas de datos del Trend collector (la elección del **tema** es la que debe apoyarse en mercado);
rating Minimal; sin paid random items; monetización: 2–3 passes (x2, auto-collect, slot), 3–4 dev products (boosts, moneda), rewarded video (boost 15 min),
Plus prompt; LiveOps: daily rewards, quests semanales, 1 evento. Scope MVP: 4–6 semanas de trabajo de agentes con 1 humano.

Criterios de éxito del piloto (de la **fábrica**, no del juego): lead time concept→staging ≤ 6 semanas; ≥70% de WPs cerrados por agentes con CI verde a la primera
o segunda; 0 incidentes de datos; soft launch con analytics completas; decisión G4 tomada con datos suficientes; postmortem con ≥10 findings a la KB.

## 4. Primeros 30 días (§91)

### Día 1–3
- Crear monorepo `roblox-factory` (este repo): estructura, `rokit.toml`, StyLua/Selene/luau-lsp configs, CLAUDE.md.
- Cuenta/grupo Roblox de la fábrica: ID verification, 2FA, Roblox Plus; crear universes **CI** y **hello-factory [STAGING]** manualmente; API keys por nivel (CI: places+luau-execution+datastores CI; staging: publish).
- Studio plane: instalar Studio, activar "Studio as MCP server", conectar Claude Code; verificar `list_roblox_studios`, `start_stop_play`, `screen_capture`.
- CI estático en GitHub Actions (format/lint/typecheck/build).
- **Entregable**: `rojo build` de un place vacío en CI + playtest disparado desde Claude Code vía MCP.

### Día 4–7
- Script `tools/ci/publish-ci-place` (Open Cloud place publishing `Saved`) + `tools/ci/run-engine-tests` (Luau Execution + parseo de resultados Jest-Lua).
- Trend collector v0: seeds manuales (≈200 universes) + expansión por recommendations, snapshots horarios de `/v1/games` en Postgres (respetando ⛔ STOP-01: sólo endpoints documentados).
- SDK: `Loader`, `Observability` (logger), `Net` (Zap spike vs Blink: 1 día, decidir DEC-007).
- **Entregable**: PR que falla si un test de engine falla (demostración deliberada).

### Semana 2
- SDK: `PlayerData` (ProfileStore wrapper + schema v1 + migración de ejemplo), `Economy` (ledger idempotente), `Products` (ProcessReceipt idempotente), `Policy`, `RemoteConfig` (ConfigService), `Analytics` (taxonomía).
- Tests: unit (Lune) + engine (persistencia, compra sintética, economía, fuzz de remotes).
- **Entregable**: "hello-factory" con loop mínimo (clic→moneda→upgrade), compra de dev product de prueba, guardado/rejoin verificado en Studio vía MCP.

### Semana 3
- Skills v1: `roblox-gdd`, `roblox-luau-engineering`, `roblox-testing`, `roblox-security-audit`, `roblox-policy-compliance`, `roblox-release` + subagentes (Engineer, Reviewer, Release Mgr) + hooks.
- `roblox-cloud-mcp` v0 (READ, RUN_TESTS, publish CI/staging con dry-run/plan, snapshot, audit log).
- Security scanner (Lune) + policy engine v0 (POL-001..010).
- **Entregable**: un Issue "añadir daily reward" resuelto por agentes: PR → CI verde → Reviewer aprueba → staging publicado automáticamente.

### Semana 4
- `econsim` v0 sobre `economy.yaml` de hello-factory; paridad Python↔Luau.
- Market: S01 sobre 3 semanas de snapshots → shortlist de temas para el piloto; S03 genera 3–5 conceptos; **Gate 1 humano**.
- Guion E2E del tutorial con Studio MCP + informe con capturas.
- **Entregable (funcional)**: pipeline completo sobre hello-factory (idea→GDD→código→tests→staging→playtest humano→publish a un universe "production" de prueba 16+ con aprobación humana→eventos visibles en Analytics). Concepto del piloto aprobado.

## 5. Primeros 90 días (§92)

| Semana | Hito |
|---|---|
| 5–6 | GDD + economy.yaml del piloto; simulación; WPs; greybox → **G2** (playtest ≥8 externos) |
| 7–10 | MVP por agentes (Engineers ×1–2), UI con design system v1, LiveOps v1 (daily, quests), rewarded ads, Plus prompt; E2E críticos; perf gates; **G3** |
| 10 | Maturity questionnaire (humano), release 16+ (**soft launch**), campaña de calibración de ads ($300–500) |
| 11–13 | Analytics Query ingest + Metabase; primer experimento (onboarding); LiveOps semanal; incident runbooks; decisión **G4 preliminar** (si n suficiente) |
| 12–13 | Trend/Opportunity Engine v1 con backtest (≈90 días de datos) → propuesta de juego 2; postmortem de fase y KB |

Estado al día 90 (objetivo): toolchain operativo ✔, repo base ✔, SDK inicial ✔, skills v1 ✔, MCP: oficial en uso + `roblox-cloud-mcp` v0 ✔ (decisión documentada),
testing multicapa ✔, piloto en soft launch 16+ ✔, analytics ✔, LiveOps v1 ✔. Si la evaluación de Roblox para all-ages no ha terminado, se documenta como PAUSE externo.

## 6. Factory KPIs (§84)

| KPI | Definición | Objetivo inicial [HIPÓTESIS] |
|---|---|---|
| concept → prototype time | días desde G1 a greybox jugable | ≤ 7 |
| prototype → MVP time | días G2→G3 | ≤ 30 |
| cost/prototype | LLM + horas × tarifa + assets | ≤ $1k |
| cost/launched game (soft launch) | idem hasta G4 | ≤ $5k (LEAN) |
| defects/build | fallos de CI por PR (media) | < 0.5 tras mes 2 |
| escaped defects | bugs detectados en staging/prod por release | tendencia ↓ |
| rollback rate | releases revertidas / releases | < 10% |
| code reuse | % líneas del juego que vienen del SDK/template | ≥ 50% |
| asset reuse | % assets de kits compartidos | ≥ 40% |
| automation % | WPs cerrados por agentes sin edición humana de código | ≥ 60% |
| human hours/game | horas humanas hasta G4 | ≤ 80 |
| games tested/month | prototipos que llegan a G2 | 2–4 (PRO) |
| early kills | conceptos/prototipos matados antes de MVP / total | ≥ 60% |
| successful experiments | experimentos con decisión clara (ship/revert) / lanzados | ≥ 50% |
| prediction quality | Brier score del Opportunity Engine | mejora trimestral |
| EV/€ del portfolio | ver `20_COST_MODEL.md` §8 | > 1 a 12–18 meses (no garantizado) |
