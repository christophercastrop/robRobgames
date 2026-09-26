# 04 — MCP Architecture

## 1. Estado del arte: MCP para Roblox (2026-09-26)

| Implementación | Arquitectura | Capacidades | Mantenimiento | Seguridad | Veredicto |
|---|---|---|---|---|---|
| **Roblox Studio MCP integrado** (oficial) | Servidor dentro de Studio; cliente AI conecta por **stdio**; "Quick connect" para Claude, Cursor, VS Code, etc. Multi-instancia por `studio_id` | Scripts: `script_read`, `multi_edit`, `script_search`, `script_grep`. Data model: `search_game_tree`, `inspect_instance`, `execute_luau`. Playtest: `get_studio_state`, `start_stop_play`, `get_console_output`, `screen_capture`, `character_navigation`, `user_keyboard_input`, `user_mouse_input`. Assets/IA: `generate_mesh`, `generate_material`, `generate_procedural_model`, `wait_job_finished`, `search_asset`, `insert_asset`, `upload_image`, `store_image`. Otros: `http_get`, `skill`, `subagent`, `list_roblox_studios`, `set_active_studio` | Oficial, activo (anuncios 2026-02-21 y 2026-03-05; doc `create.roblox.com/docs/studio/mcp`) | "MCP clients can read and modify content in your open Roblox places" — sin permisos granulares por herramienta [HV]. Aprobación de scripts por sesión/prompt en Assistant [HV] | **USAR** (Studio plane) |
| `Roblox/studio-rust-mcp-server` | Binario Rust (axum long-poll) + plugin Studio; stdio | `run_code`, `insert_model`, `get_console_output`, `start_stop_play`, `run_script_in_play_mode`, `get_studio_mode` | **Archivado 2026-04-03**; último tag v0.2.365 (2026-02-24) | MIT | **DESCARTAR** |
| `boshyxd/robloxstudio-mcp` | Plugin + servidor HTTP local (Node); 43 tools (31 en edición read-only "Inspector") | Inspección, edición masiva | **Archivado (jun-2026)**; fork recomendado `Chrrxs/robloxstudio-mcp` | MIT; requiere "Allow HTTP Requests" | **DESCARTAR** (el oficial lo cubre) |
| `hope1026/weppy-roblox-mcp` | Plugin + servidor Node en `127.0.0.1:3002` | Scripts, instancias, terreno, lighting, assets vía Open Cloud, sync, playtest (Pro), UI Studio (Pro) | Muy activo (2026-09-26, v2.17.10) | **AGPL-3.0** + licencia comercial; tier de pago; rate limit 450/min | **DESCARTAR** (licencia AGPL + supply chain + solapamiento con oficial) |
| `michaeldougal/Roblox-MCP-Analytics` | MCP que envuelve Analytics Query API | "168 métricas", validación, pacing | 2026-08-19 | Recibe API key con `universe.analytics:read` | **REFERENCIA** (inspirar catálogo de métricas); no instalar en producción sin auditoría |
| `frrazer/roblox-devproducts-mcp` | MCP local para dev products (Open Cloud) | list/create/update | 2026-09-20 | Maneja scope `developer-product:write` → cambios económicos sin gates | **DESCARTAR** (escritura económica sin control) |
| Open Cloud MCP **oficial** | — | — | "Native MCP support" anunciado como **futuro** en el anuncio del 2026-08-24 | — | **NO EXISTE HOY** → construir capa propia fina |

### Respuesta: ¿usar un MCP existente o construir uno propio?

**[DECISIÓN PROPUESTA — DEC-002/003]**

1. **Studio plane → usar el MCP integrado oficial. NO construir `studio.*` propio.** Cubre el 90% de las herramientas pedidas en el brief (ver §3),
   es oficial y mantenido. Lo que falta (tests estructurados, perfiles) se cubre con `execute_luau` + módulos del SDK.
2. **Cloud plane → construir `roblox-cloud-mcp`**, un MCP **fino** sobre Open Cloud cuyo valor no es "llamar APIs" sino
   **imponer el modelo de permisos, dry-runs, aprobaciones y auditoría** (§4). Reemplazable por el MCP oficial cuando exista: entonces
   `roblox-cloud-mcp` queda como *policy proxy*.

## 2. Topología

```text
┌──────────────────────────── Cloud plane (Linux) ────────────────────────────┐
│ Claude Code (CI/headless, sesiones cloud)                                   │
│   ├─ GitHub MCP (oficial)            → issues, PRs, checks                   │
│   ├─ roblox-cloud-mcp (PROPIO)       → Open Cloud con niveles de permiso     │
│   │     └─ Approval service (DB + GitHub Environments / firma humana)       │
│   ├─ Postgres MCP (read-only) o psql → factory DB / warehouse               │
│   └─ herramientas nativas (Read/Write/Bash/WebSearch/WebFetch)              │
└─────────────────────────────────────────────────────────────────────────────┘
┌──────────────────── Studio plane (Windows/macOS workstation) ───────────────┐
│ Claude Code local ──stdio── Roblox Studio (MCP integrado) ◄── rojo serve     │
│   (+ opcional) Blender MCP en VM/usuario aislado                            │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 3. Viabilidad de las herramientas `studio.*` del brief (con el MCP oficial)

| Tool del brief | Estado | Mapeo en MCP oficial / alternativa |
|---|---|---|
| `studio.get_tree` | **VIABLE** | `search_game_tree` |
| `studio.get_instance` / `get_properties` | **VIABLE** | `inspect_instance` |
| `studio.search_instances` | **VIABLE** | `search_game_tree` (+ `execute_luau` para queries complejas) |
| `studio.read_script` | **VIABLE** | `script_read` |
| `studio.write_script` | **VIABLE pero NO RECOMENDADO** | `multi_edit`. **Regla**: el código vive en Git; escribir vía Rojo (editar archivos) salvo prototipado exploratorio |
| `studio.create_instance` / `delete_instance` / `set_property` | **VIABLE** | `execute_luau` (no hay tools dedicadas) |
| `studio.run_command` | **VIABLE** | `execute_luau` |
| `studio.run_tests` | **VIABLE indirecto** | `execute_luau` invocando el runner Jest-Lua del SDK; en CI se usa Open Cloud Luau Execution |
| `studio.start_playtest` / `stop_playtest` | **VIABLE** | `start_stop_play` |
| `studio.get_output` / `get_errors` | **VIABLE** | `get_console_output` (filtrar por severidad en el cliente) |
| `studio.capture_screenshot` | **VIABLE** | `screen_capture` (viewport) |
| `studio.inspect_ui` | **PARCIAL** | `search_game_tree` sobre `PlayerGui` durante playtest + `screen_capture`; no hay árbol de layout calculado → `execute_luau` leyendo `AbsolutePosition/AbsoluteSize` |
| `studio.inspect_workspace` | **VIABLE** | `search_game_tree` |
| `studio.profile` | **PARCIAL** | No hay tool de MicroProfiler; `execute_luau` con `Stats` service y contadores propios del SDK. Profiling detallado = humano |
| `studio.save_place` | **NO DISPONIBLE como tool** | En flujo Git-first no se necesita (build con Rojo). Para places de arte: humano o `SavePlaceAsync` en Luau Execution |
| Simulación de input | **VIABLE (experimental)** | `user_keyboard_input`, `user_mouse_input`, `character_navigation` (este último mueve el personaje directamente, **no** simula controles reales [HV]) |

## 4. Diseño de `roblox-cloud-mcp` (propio)

### 4.1 Principios

- **Una herramienta por intención**, no por endpoint (menos superficie para el modelo).
- Toda herramienta de escritura tiene **`dry_run: true` por defecto** y devuelve un *plan* (diff) con `plan_id`.
- La ejecución real (`apply(plan_id)`) comprueba el **nivel de permiso** y, si procede, una **aprobación humana** vigente ligada al hash del plan.
- Credenciales: el MCP obtiene la API key del entorno/secret manager **según el nivel**; el modelo nunca ve la clave.
- **Auditoría append-only** (tabla `audit_log`: quién/qué agente, tool, plan, aprobación, respuesta HTTP).
- Transporte: **stdio** para uso local/CI [DEC]; no se expone por red.
- Implementación: Python + SDK oficial MCP (`modelcontextprotocol/python-sdk`, activo 2026-09-23) + cliente HTTP generado desde el OpenAPI oficial.

### 4.2 Herramientas

| Tool | Nivel | Endpoint(s) |
|---|---|---|
| `cloud.get_universe`, `cloud.list_places`, `cloud.get_place` | READ | `GET /cloud/v2/universes/{u}`, `develop.roblox.com/v1/universes/{u}/places`, `GET .../places/{p}` |
| `cloud.place_history` | READ | `place-version-history-api` |
| `cloud.list_servers`, `cloud.server_logs(filter)` | READ | `server-management/v1` |
| `cloud.query_metrics(metric, range, granularity, breakdown)` | READ | `analytics-query-api/v1` (async + polling interno) |
| `cloud.read_datastore_entry`, `cloud.list_datastore_entries`, `cloud.entry_revisions` | READ (prod: sólo agentes con rol soporte) | data stores v2 |
| `cloud.get_configs`, `cloud.list_experiments`, `cloud.experiment_stats` | READ | creator-configs |
| `cloud.run_luau_task(place, version, script_ref)` | RUN_TESTS (sólo universe CI) | Luau Execution |
| `cloud.publish_place(env=ci)` | WRITE_CLOUD | place publishing `Saved` |
| `cloud.publish_place(env=staging)` | PUBLISH_STAGING | place publishing `Published` al universe staging |
| `cloud.publish_place(env=prod)` | PUBLISH_PRODUCTION (**humano**) | idem, universe prod |
| `cloud.snapshot_datastores` | WRITE_CLOUD | `data-stores:snapshot` |
| `cloud.write_datastore_entry` (staging/ci) | WRITE_CLOUD | data stores v2 |
| `cloud.write_datastore_entry` (prod) | WRITE_CLOUD + aprobación (soporte) | idem |
| `cloud.config_draft(patch)` / `cloud.config_publish` | WRITE_CLOUD (flags técnicos) / **ECONOMY_CHANGE** si la key está etiquetada `econ.*` o `price.*` | creator-configs |
| `cloud.experiment_create/start/complete` | WRITE_CLOUD + diseño aprobado; ECONOMY_CHANGE si toca precios | experimentation |
| `cloud.product_upsert` (passes/dev products/precio) | **ECONOMY_CHANGE** (humano) | game-passes/v1, developer-products/v2 |
| `cloud.upload_asset` | WRITE_CLOUD + policy scan (imágenes/audio) | assets/v1 |
| `cloud.thumbnail_personalization` | WRITE_CLOUD + policy scan | thumbnail-personalization-api |
| `cloud.notify_users(template_id)` / `cloud.event_upsert` | WRITE_CLOUD (plantillas pre-aprobadas) | notifications, virtual-events |
| `cloud.restrict_user` | WRITE_CLOUD (temporal) / humano (permanente) | user-restrictions |
| `cloud.restart_servers` | PUBLISH_PRODUCTION (humano) salvo incidente con runbook | `:restartServers` / server-management restarts |
| `cloud.ads_campaign_*` | **SPEND_AD_BUDGET** (humano siempre) | ads-management/v1 |
| `cloud.delete_datastore`, `cloud.delete_entry(prod)`, `cloud.flush_memory_store` | **DELETE_PRODUCTION_DATA** (humano + 2º aprobador) | data stores, memory store |
| `cloud.instance_patch` (editar Script.Source en place publicado) | **Deshabilitado** por defecto; sólo *break-glass* en incidente | instances API |

## 5. Modelo de permisos (§10 del brief)

| Nivel | Qué permite | Quién lo tiene por defecto | Aprobación |
|---|---|---|---|
| `READ` | Leer universes, métricas, logs, configs, datos de CI/staging | Todos los agentes | — |
| `WRITE_LOCAL` | Editar archivos del repo, Studio local (MCP oficial) | Engineer, Designer, QA | Revisión por PR |
| `RUN_TESTS` | Luau Execution en universe CI; playtests Studio | Engineer, QA | — |
| `WRITE_CLOUD` | Escrituras no destructivas en CI/staging; flags técnicos; assets tras policy scan | Release Manager, Live Analyst (acotado) | Automática dentro de límites (A3) |
| `PUBLISH_STAGING` | Publicar al universe staging | Release Manager | Automática si CI verde + policy PASS |
| `PUBLISH_PRODUCTION` | Publicar a producción, restart | Nadie de forma permanente | **Humana**, por release (hash de build) |
| `ECONOMY_CHANGE` | Precios, productos, configs económicas, experimentos de pricing | Nadie de forma permanente | **Humana** (+ simulación de economía adjunta) |
| `SPEND_AD_BUDGET` | Campañas | Nadie | **Humana** + presupuesto máximo |
| `DELETE_PRODUCTION_DATA` | Borrado irreversible | Nadie | **Humana doble** + snapshot previo verificado |

**Mecánica de aprobación** [DEC-011]: GitHub Environments con *required reviewers* para `production`, `economy`, `ads`, `destructive`.
El job que ejecuta `apply(plan_id)` sólo recibe el secret del nivel si el reviewer aprobó el deployment. El MCP, además, valida que el
`plan_hash` aprobado coincide con el que se ejecuta. Claude **nunca** recibe permisos destructivos de forma persistente.

Aprobación humana obligatoria para: publicación a producción · gasto publicitario · cambios de monetización/precios · eliminación de datos ·
cambios irreversibles (desactivar universe, genre change, suscripciones) · publicación de assets con hallazgos WARN del policy engine ·
bans permanentes · uso de IP de terceros.

## 6. Riesgos de seguridad del MCP de Studio (y mitigaciones)

| Riesgo | Mitigación |
|---|---|
| `insert_asset` / `search_asset` desde Creator Store → **modelos con scripts backdoor** (patrón conocido: `require(assetId)`, `getfenv`, `loadstring`) | Política: prohibido `insert_asset` salvo de la **allowlist** de assets propios/auditados; scanner de backdoors en CI (`12_SECURITY.md` §7) |
| `execute_luau` puede alterar cualquier cosa del place abierto | Trabajar sólo en places de desarrollo sincronizados con Rojo; nunca abrir el place de producción en la estación del agente |
| `http_get` → exfiltración / prompt injection desde webs | Tratar su salida como no confiable; no usar para decisiones de permisos |
| Prompt injection vía contenido del place (nombres/strings de assets de terceros) | No insertar assets de terceros; el agente trata textos del DataModel como datos |
| Múltiples Studios abiertos → acción en el place equivocado | Una sola instancia por workstation de agente; verificar `get_studio_state` + nombre de place antes de escribir |
| `generate_mesh` consume cuota/moderación | Presupuesto por juego; registrar en el asset log |

## 7. MCP globales de la factory (reutilizar antes que construir)

Ver `inventories/MCP-INVENTORY.md`. Resumen: **GitHub MCP oficial** (sí) · **Studio MCP oficial** (sí) · **roblox-cloud-mcp** (construir, fino) ·
**Postgres**: preferir `psql` con rol read-only; `crystaldba/postgres-mcp` como opción (el servidor Postgres de referencia está archivado desde 2025) ·
**Filesystem/Browser**: herramientas nativas de Claude Code; **Playwright MCP** (Microsoft, activo) sólo para verificar páginas públicas propias ·
**Blender MCP** (`ahujasid/blender-mcp`, activo 2026-09-25) experimental y aislado · **Image generation**: sin MCP, llamadas desde `factory/` ·
**Project management**: GitHub Issues/Projects (sin Jira/Linear) · **Analytics MCP**: incluido en `roblox-cloud-mcp`.
