# 05 — Claude Skills

## 1. Qué es una Skill hoy (verificado)

[HV — [Claude Code docs: Skills](https://code.claude.com/docs/en/skills), consultado 2026-09-26]

- Carpeta `.claude/skills/<skill-name>/SKILL.md` (proyecto; se commitea) o dentro de un **plugin** (`<plugin>/skills/...`, namespaced `/plugin:skill`).
- Frontmatter relevante: `name`, `description` (+ `when_to_use`) para auto-invocación; `disable-model-invocation: true` (sólo humano la invoca —
  usar para **releases, cambios económicos, borrados**); `user-invocable: false` (conocimiento de fondo); `allowed-tools` / `disallowed-tools`;
  `model`, `effort`; `context: fork` + `agent` (ejecutar en subagente aislado); `paths` (auto-invocar sólo para ciertos globs); `arguments`.
- **Progressive disclosure**: `SKILL.md` < 500 líneas; referencias en ficheros hermanos (`reference.md`, `scripts/`) que sólo se cargan cuando se necesitan.
- Inyección dinámica `` !`command` `` (p. ej. volcar métricas actuales o el estado del juego antes de razonar).
- En monorepos, las skills de subdirectorios se cargan al editar allí → skills **por juego** en `games/<slug>/.claude/skills/` si hace falta.
- Roblox Studio **Assistant** tiene su propio formato de skills (Markdown + frontmatter `name`, `description`, `enabled`) [HV `assistant/skills.md`].

**Portabilidad** [DEC-013]: las reglas de Luau/SDK se escriben una vez en `knowledge/engineering/*.md` y se referencian desde la Claude Skill
`roblox-luau-engineering` y desde una Assistant Skill generada por script (`factory skills export-assistant`). Una fuente, dos consumidores.

## 2. Evaluación de las 28 skills propuestas en el brief

Criterio: una skill existe si (a) tiene un **trigger** distinto, (b) produce un **artefacto verificable** distinto, y (c) su conocimiento no cabe
como sección de otra sin superar ~500 líneas. Dividir por "rol de experto" en lugar de por artefacto genera solapamientos y contexto duplicado.

| Propuesta | Veredicto | Destino |
|---|---|---|
| roblox-market-research | FUSIONAR | → `roblox-market-intel` |
| roblox-trend-intelligence | FUSIONAR | → `roblox-market-intel` (la lógica pesada vive en código `factory/trends`, no en la skill) |
| roblox-opportunity-scoring | MANTENER | `roblox-opportunity-scoring` |
| roblox-game-concept | MANTENER (+ originalidad) | `roblox-game-concept` |
| roblox-game-design | FUSIONAR | → `roblox-gdd` |
| roblox-core-loop-design | FUSIONAR | → `roblox-gdd` (sección core loop) |
| roblox-progression-design | FUSIONAR | → `roblox-gdd` / `roblox-economy-design` |
| roblox-economy-design | MANTENER | `roblox-economy-design` |
| roblox-monetization-design | FUSIONAR | → `roblox-economy-design` (economía y monetización son el mismo modelo de sources/sinks) |
| roblox-liveops-design | FUSIONAR | → `roblox-liveops` |
| roblox-luau-engineering | MANTENER | `roblox-luau-engineering` (con `reference/` por subsistema) |
| roblox-ui-engineering | MANTENER | `roblox-ui-engineering` |
| roblox-network-engineering | FUSIONAR | → `roblox-luau-engineering/reference/networking.md` (+ Zap IDL) |
| roblox-datastore-engineering | MANTENER (alto riesgo) | `roblox-data-safety` |
| roblox-performance-engineering | MANTENER | `roblox-performance` |
| roblox-world-design | FUSIONAR | → `roblox-asset-pipeline` (+ sección de GDD) |
| roblox-level-design | FUSIONAR | → `roblox-asset-pipeline` |
| roblox-asset-pipeline | MANTENER (A1–A2) | `roblox-asset-pipeline` |
| roblox-qa | FUSIONAR | → `roblox-testing` |
| roblox-e2e-testing | FUSIONAR | → `roblox-testing` |
| roblox-security-audit | MANTENER | `roblox-security-audit` |
| roblox-exploit-audit | FUSIONAR | → `roblox-security-audit` |
| roblox-publishing | MANTENER (user-only) | `roblox-release` |
| roblox-analytics | MANTENER | `roblox-analytics` |
| roblox-growth-analysis | FUSIONAR | → `roblox-analytics` |
| roblox-retention-analysis | FUSIONAR | → `roblox-analytics` |
| roblox-liveops | MANTENER | `roblox-liveops` |
| roblox-ab-testing | MANTENER | `roblox-experimentation` |
| roblox-postmortem | FUSIONAR | → `roblox-learning-loop` |
| roblox-knowledge-extraction | FUSIONAR | → `roblox-learning-loop` |
| *(nueva)* | AÑADIR | `roblox-policy-compliance` (gate de políticas; no estaba en el brief como skill) |
| *(nueva)* | AÑADIR | `roblox-incident-response` (runbooks; separada de LiveOps por trigger y permisos) |

**Resultado: 19 skills** — 18 núcleo + 1 opcional (`roblox-asset-pipeline`), a partir de 28 propuestas (−11 por fusión) + 2 nuevas.

## 3. Skills definitivas — especificación

Convención de artefactos: todo artefacto es un fichero en Git con frontmatter YAML (`status: hypothesis|validated|experiment|pending`),
para que otros agentes y el orquestador puedan leerlos de forma determinista.

### S01 `roblox-market-intel`
- **Responsabilidad**: interpretar datos del Trend Engine (no recolectarlos), identificar patrones de mercado, monetización visible y señales sociales.
- **Entradas**: vistas SQL `trend_*` (factory DB), `knowledge/genres/*.md`, consulta del usuario.
- **Salidas**: `research/market/<fecha>-<tema>.md` (hallazgos con etiquetas epistémicas), lista de `opportunity_candidates` (YAML).
- **Herramientas**: Read, Bash(`factory trends query *`), WebSearch/WebFetch (fuentes permitidas en DATA-SOURCES). **MCP**: ninguno obligatorio (Postgres read-only opcional).
- **Permiso**: READ. **DoD**: cada afirmación cuantitativa cita consulta/fuente; ≥3 competidores por oportunidad; separación tema/mecánica/meta-loop.

### S02 `roblox-opportunity-scoring`
- **Responsabilidad**: aplicar el modelo de `08_OPPORTUNITY_ENGINE.md` y documentar supuestos.
- **Entradas**: `opportunity_candidates`, features calculadas (`factory score features`), portfolio actual.
- **Salidas**: `opportunities/<id>.yaml` (score, componentes, incertidumbre, riesgos IP, recomendación GO/NO-GO al Gate 0).
- **Herramientas**: Bash(`factory score *`). **Permiso**: READ. **DoD**: score reproducible (mismo input → mismo output), riesgos IP evaluados, comparación con portfolio.

### S03 `roblox-game-concept`
- **Responsabilidad**: transformar una oportunidad en 3–5 conceptos originales (plantilla de §21 del brief) y ejecutar el **chequeo de originalidad**.
- **Entradas**: `opportunities/<id>.yaml`, `knowledge/patterns/*`, `knowledge/player-needs.md`.
- **Salidas**: `games/<slug>/design/concepts.md` + `originality-report.md`.
- **Permiso**: WRITE_LOCAL. **DoD**: cada concepto declara jugador objetivo, fantasía, core loop, MVP scope, content burden, complejidad (T-shirt), diferenciación explícita vs 3 competidores, riesgos; originality report sin bloqueos.

### S04 `roblox-gdd`
- **Responsabilidad**: GDD ejecutable (plantilla en `09_GAME_PRODUCTION_PIPELINE.md` §4), incluidos core loop, progresión, mundo/nivel a alto nivel, work packages.
- **Salidas**: `games/<slug>/design/GDD.md`, `design/work-packages/*.md` (tareas con criterios de aceptación y tests esperados).
- **Permiso**: WRITE_LOCAL. **DoD**: cada decisión etiquetada `validated/hypothesis/experiment/pending`; cada feature enlaza métrica y evento de analytics; WPs ≤ 1 día de agente.

### S05 `roblox-economy-design`
- **Responsabilidad**: economía (sources/sinks, curvas, prestige), monetización (catálogo de productos, precios iniciales **como hipótesis**), cumplimiento de paid random items.
- **Entradas**: GDD, `knowledge/economy/*`, simulador (`factory econ simulate`).
- **Salidas**: `design/economy.yaml` (fuente de verdad que el SDK consume para generar configs), informe de simulación, `design/monetization.md`.
- **Permiso**: WRITE_LOCAL (el *aplicar* precios es `ECONOMY_CHANGE` vía `roblox-release`). **DoD**: simulación Monte Carlo sin inflación descontrolada en horizonte 60 días; ningún producto viola políticas (odds, PolicyService); pricing con justificación.

### S06 `roblox-luau-engineering`
- **Responsabilidad**: implementar work packages sobre el SDK: arquitectura, patrones, networking (Zap), server authority.
- **Referencias**: `reference/architecture.md`, `networking.md`, `sdk-api.md`, `patterns.md`, `anti-patterns.md`.
- **Herramientas**: Read/Edit/Write, Bash(`rojo *`, `stylua *`, `selene *`, `luau-lsp *`, `lune *`); **MCP**: Studio MCP (Studio plane) para verificación.
- **Permiso**: WRITE_LOCAL, RUN_TESTS. **DoD**: CI local verde (format, lint, typecheck, unit), tests nuevos para cada WP, ningún RemoteEvent sin validación, sin `wait()` deprecated, `--!strict`.

### S07 `roblox-ui-engineering`
- **Responsabilidad**: UI con el design system del SDK (`packages/ui`), responsive, accesible, localizable.
- **DoD**: sin strings literales (todo en tablas de localización), componentes del DS, capturas en 4 resoluciones (phone portrait/landscape, tablet, desktop; +10-foot si consola) revisadas.

### S08 `roblox-data-safety`
- **Responsabilidad**: esquemas de datos, migraciones, ProfileStore, UpdateAsync, backups, recuperación, GDPR/RTBF.
- **Salidas**: `schema/player-data.v<N>.luau`, migraciones con tests, runbook de recuperación.
- **Permiso**: WRITE_LOCAL, RUN_TESTS; snapshot = WRITE_CLOUD. **DoD**: migración probada contra datos sintéticos + snapshot de staging; rollback probado; sin `SetAsync` sobre datos de jugador.

### S09 `roblox-performance`
- **Responsabilidad**: presupuestos y gates de rendimiento (`11_QA_E2E.md` §7), perfilado asistido, optimización.
- **DoD**: métricas del perf harness dentro de presupuesto por clase de dispositivo; regresiones >10% bloquean.

### S10 `roblox-testing`
- **Responsabilidad**: unit (Lune), engine (Jest-Lua vía Luau Execution), simulación server-side, playtest automatizado con Studio MCP, visual QA.
- **DoD**: plan de pruebas por WP; cobertura de caminos críticos (compra, guardado, migración, tutorial); reporte de playtest con capturas.

### S11 `roblox-security-audit`
- **Responsabilidad**: auditoría de trust boundaries, remotes, economía, compras, rate limits, backdoors en assets; revisión adversarial de PRs.
- **Contexto**: `context: fork` (revisor independiente, no ve el razonamiento del implementador).
- **DoD**: checklist de `12_SECURITY.md` completo; hallazgos con severidad; 0 críticos abiertos para pasar a staging.

### S12 `roblox-policy-compliance`
- **Responsabilidad**: ejecutar el Factory Policy Engine (`18_COMPLIANCE.md`) y preparar respuestas del Maturity & Compliance Questionnaire (el humano las envía).
- **DoD**: informe PASS/WARN/BLOCK con evidencias; nunca afirma "aprobado por Roblox".

### S13 `roblox-release` — `disable-model-invocation: true`
- **Responsabilidad**: empaquetar build, changelog, publicar a staging, preparar *plan* de producción para aprobación humana, post-release checks.
- **Herramientas**: `roblox-cloud-mcp` (publish, snapshot, configs). **Permiso**: PUBLISH_STAGING; producción sólo con aprobación.
- **DoD**: build hash = hash aprobado; snapshot previo; smoke test post-deploy; rollback plan documentado.

### S14 `roblox-analytics`
- **Responsabilidad**: taxonomía de eventos, instrumentación, consultas (Analytics Query API + warehouse), análisis de retención/crecimiento/cohortes, informes de gate.
- **DoD**: cada informe incluye tamaño de muestra, intervalos, sesgos (traffic mix), y separa correlación de causalidad.

### S15 `roblox-experimentation`
- **Responsabilidad**: diseñar y leer A/B tests (Experiments nativo + Configs), MDE, guardrails, decisión.
- **DoD**: plantilla de experimento completa (`16_LIVEOPS.md` §5); no se "mira antes de tiempo" sin corrección; decisión registrada en KB.

### S16 `roblox-liveops`
- **Responsabilidad**: calendario, eventos, rotaciones, ofertas (vía configs y catálogo LiveOps del SDK), notificaciones y Experience Events.
- **Permiso**: WRITE_CLOUD (contenido pre-aprobado); ofertas con precio = ECONOMY_CHANGE.

### S17 `roblox-learning-loop`
- **Responsabilidad**: postmortems (juego, experimento, incidente) y extracción de conocimiento a la KB con **contexto de validez**.
- **DoD**: cada finding tiene `scope` (global/género/juego), evidencia, n, fecha de caducidad de revisión.

### S18 `roblox-incident-response` (auto-invocable; las acciones destructivas siguen gated por el MCP)
- **Responsabilidad**: detección→clasificación→mitigación (flags/rollback)→RCA; ejecuta runbooks.
- **DoD**: timeline, impacto, acción, RCA, acciones preventivas en backlog.

### S19 `roblox-asset-pipeline` (opcional, A1–A2)
- **Responsabilidad**: especificar assets (brief de arte), procesar/validar (poly budget, texturas, naming), subir vía Open Cloud tras policy scan; world/level blockouts procedurales.
- **DoD**: presupuesto de triángulos/memoria por asset; licencia y origen registrados en `assets/LEDGER.yaml`.

## 4. Organización física

```text
.claude/
  skills/
    roblox-market-intel/SKILL.md (+ reference/)
    ...
  agents/            # subagentes (ver 06_AGENT_ARCHITECTURE.md)
  settings.json      # permisos: deny de Skill(roblox-release) a subagentes; hooks
plugins/roblox-factory/   # (Fase 3+) empaquetar skills+agents+hooks como plugin versionado
```

Hooks recomendados [DEC]: `PreToolUse` que bloquea `Bash(rbxcloud *)`/`curl apis.roblox.com` directos (forzar paso por `roblox-cloud-mcp`);
`PostToolUse` en ediciones `.luau` → `stylua` + `selene` del fichero; `Stop` hook que exige actualizar el `status` del work package.
