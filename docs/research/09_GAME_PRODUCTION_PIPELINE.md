# 09 — Game Production Pipeline (E2E)

## 1. Vista general

```text
Opportunity (G0) → Concept x3–5 (G1) → GDD + economy.yaml → TECH plan + work packages
  → Greybox prototype (G2) → MVP build (G3) → Staging → Human playtest → Soft launch 16+ (G4/G5)
  → All-ages (evaluación Roblox) → LIVE → LiveOps/Experiments → Postmortem/KB
```

## 2. Concept Generator (§21)

Pipeline [DEC]:

1. **Entrada**: `opportunities/<id>.yaml` + `knowledge/player-needs.md` (catálogo de necesidades: maestría, colección, expresión, pertenencia,
   competición, descubrimiento, relajación, creación) + patrones validados de la KB (con scope).
2. **Abstracción** (no-clone, ver `18_COMPLIANCE.md` §3): de los top-N competidores se extraen *mecánicas* y *necesidades*, nunca nombres/arte/mapas.
3. **Recombinación**: el Designer genera ≥8 combinaciones (necesidad × mecánica × tema × meta-loop × social hook) y descarta las que coinciden en
   ≥3 ejes con un competidor existente.
4. **Evaluación**: matriz de complejidad/contenido/diferenciación; top 3–5 → plantilla completa.
5. **Revisión**: Reviewer (fork) intenta demostrar que cada concepto es un clon o no es divertido; humano elige.

Plantilla por concepto (`design/concepts.md`):

```yaml
id: C-2026-014-a
fantasy: "..."                  # promesa emocional en 1 frase
target_audience: {age_band: "9-15|16+|all", platform_focus: [phone, pc], social: "coop 2-4"}
core_loop: ["verb", "verb", "reward"]      # < 60 s por ciclo
secondary_loops: [...]
session_length_target_min: 12
progression: {axes: [...], prestige: bool, horizon_days: 30}
social_mechanics: [...]
retention_hooks: [daily, collection, co-op goals, events]
economy: {soft: [..], hard: none|gems, sinks: [...]}
monetization: {passes: [...], dev_products: [...], subscription: bool, rewarded_ads: bool, paid_random: false}
content_burden: {launch_hours: X, per_week_liveops_hours: Y}
technical_complexity: S|M|L|XL
differentiation: {vs: [universe_ids], axes_different: [mechanic, theme, meta_loop, social]}
mvp_scope: [...]
risks: [{risk, likelihood, mitigation}]
maturity_target: Minimal|Mild|Moderate
status: hypothesis
```

## 3. Game Design Document ejecutable (§22)

Reglas: **≤ 15 páginas**; cada afirmación lleva estado; cada feature se traduce en work packages con criterios de aceptación y eventos de analytics.

```markdown
# GDD — <Game> (vN)                         status legend: [V]alidated [H]ypothesis [E]xperiment [P]ending
## 0. One-pager: fantasy, audience, core loop diagram, differentiation, KPIs objetivo (G4) [H]
## 1. Core loop (verbo → feedback → recompensa), tiempos objetivo por ciclo [H]
## 2. FTUE / onboarding: pasos (≤ 60 s a la primera recompensa), funnel steps instrumentados [H]
## 3. Progression: ejes, curvas (referencia a economy.yaml), prestige/rebirth [H]
## 4. Economy & monetization: resumen + link a economy.yaml + informe de simulación [H]
## 5. Social: co-play, parties, invitaciones, share links, sin depender de chat de texto [H]
## 6. Content: lista cerrada para MVP; content burden semanal para LiveOps [P]
## 7. World/level: blockout, zonas, flujo; presupuesto de instancias/tris [P]
## 8. UI: pantallas (del design system), flujos de compra, accesibilidad [P]
## 9. Tech: arquitectura (pattern elegido), módulos del SDK usados, remotes (Zap IDL), datos (schema v1) [P]
## 10. Analytics: eventos (taxonomía común + específicos), funnels, experimentos planeados [E]
## 11. Compliance: maturity target, paid random items (no/sí + PolicyService), UGC, social links [V/P]
## 12. Risks & open questions
## 13. Work packages (tabla: id, título, dependencias, estimación, tests, eventos, DoD)
```

## 4. Estructura de un juego en el monorepo

```text
games/<slug>/
  default.project.json          # Rojo: mapea src/ + ../../packages/sdk + Packages/ (Wally)
  wally.toml / wally.lock
  src/
    server/  (Services)         client/ (Controllers)      shared/ (tipos, constantes)
    net/game.zap                # IDL de red → código generado en src/shared/net
  config/
    economy.yaml                # fuente de verdad económica (→ genera configs y catálogo)
    liveops/*.yaml              # eventos, rotaciones
    remote-config.yaml          # keys ConfigService (tipadas, con owner y nivel de permiso)
  design/  (concepts.md, GDD.md, TECH.md, work-packages/, playtests/)
  tests/   unit/ (Lune)  engine/ (Jest-Lua)  sim/ (bots server-side)  e2e/ (guiones Studio MCP)
  assets/LEDGER.yaml            # origen/licencia/IDs de cada asset
  STATE.yaml                    # estado en la state machine
  .env.example                  # IDs de universes/places por entorno (no secretos)
```

## 5. Entornos Roblox por juego

| Entorno | Universe | Acceso | Datos | Quién publica |
|---|---|---|---|---|
| dev | (local Studio / place personal) | Personal | Mock | Engineer |
| ci | Universe CI compartido de la fábrica (1 place por juego) | Personal use | DataStores de CI (se purgan) | CI (WRITE_CLOUD) |
| staging | `<Game> [STAGING]` | Privado / trusted friends | DataStores staging | Release Mgr (PUBLISH_STAGING) |
| production | `<Game>` | 16+ → all ages | Producción | Release Mgr **+ aprobación humana** |

Configs: se editan en staging y se promueven con "publish to another experience" (Studio) o por API (draft/publish en el universe prod) [HV configs].

## 6. CI/CD (§38) — qué etapas son realmente posibles

| Etapa | Posible | Herramienta | Dónde |
|---|---|---|---|
| format | **Sí** | `stylua --check` | GitHub Actions (Linux) |
| lint | **Sí** | `selene` | idem |
| typecheck | **Sí** | `rojo sourcemap` + `luau-lsp analyze --definitions=globalTypes.d.luau` | idem |
| unit tests | **Sí** (lógica pura) | Lune | idem |
| build | **Sí** | `rojo build -o game.rbxl` | idem |
| codegen check | **Sí** | Zap/Blink regenerado y diff limpio; `economy.yaml` → configs | idem |
| integration/engine tests | **Sí** | publicar a place CI (`versionType=Saved`) + **Luau Execution** con Jest-Lua; parsear JSON de resultados | idem + Open Cloud |
| security checks | **Sí** (estático) | script de auditoría de remotes/backdoors + Reviewer agent | idem |
| policy scan | **Sí** (parcial) | Factory Policy Engine | idem |
| package | **Sí** | artefacto `.rbxl` + manifest (hash, commit, versión SDK) | idem |
| staging deploy | **Sí** | place publishing a staging (`Published`) | GitHub Environment `staging` |
| playtest automatizado | **Parcial / experimental** | Studio MCP en runner Windows/macOS self-hosted | Studio plane |
| E2E multi-cliente | **NO automatizable oficialmente** | Team Test manual | Humanos |
| approval | **Sí** | GitHub Environment `production` con required reviewers | — |
| production | **Sí** | place publishing (`Published`) + smoke (server logs) | — |
| post-deploy verify | **Sí** | server logs API (errores por versión), Analytics Query (crash rate), en ventana de 30–60 min | Live Analyst |
| rollback | **Sí** | republicar versión anterior (artefacto guardado) + restaurar config revision | Release Mgr (aprobación) |

Workflow de referencia (`.github/workflows/game-ci.yml`, esquema):

```yaml
on: [pull_request, push]
jobs:
  static:   { steps: [checkout, rokit install, stylua --check, selene, rojo sourcemap, luau-lsp analyze, lune run tests/unit] }
  build:    { needs: static, steps: [rojo build -o out/game.rbxl, upload-artifact] }
  engine:   { needs: build, environment: ci, steps: [publish CI place (Saved), luau-execution run tests/engine/runner.luau, parse results] }
  audit:    { needs: build, steps: [factory security scan, factory policy scan] }
  staging:  { if: branch == main, needs: [engine, audit], environment: staging, steps: [snapshot staging datastores, publish staging] }
  release:  { if: tag v*, needs: staging, environment: production (required reviewers), steps: [snapshot prod, publish prod, smoke] }
```

Presupuesto de CI: Luau Execution = 5 tareas/min por owner ⇒ **una tarea por pipeline** que ejecute toda la suite; con N juegos en paralelo
usar una cola (el orquestador serializa) [INFERENCIA].

## 7. Release process

1. Release Manager genera `release/<version>.md`: changelog, migraciones de datos, configs a cambiar, riesgos, rollback plan, hash de build.
2. Checks automáticos: CI verde en el commit, policy PASS (o WARN justificado), security 0 críticos/altos abiertos, perf gates.
3. **Aprobación humana** del plan (GitHub Environment).
4. Snapshot de DataStores prod → publish → verificación de arranque (logs de servidores de la nueva versión) → monitorización 60 min.
5. Si error rate > umbral: flag kill-switch (config) o rollback de versión.
6. Post-release note en KB (S17) si hubo incidencias.

Nota: Roblox no hace "rolling update" automático de servidores existentes al publicar; los servidores viejos siguen hasta vaciarse salvo
restart/migración [HT, comportamiento conocido de la plataforma]. Existen endpoints de matchmaking `launch-update`/`forecast-update` (BETA) cuya
semántica debe verificarse en un spike antes de depender de ellos [INFERENCIA].
