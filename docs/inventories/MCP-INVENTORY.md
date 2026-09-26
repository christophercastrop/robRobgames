# MCP-INVENTORY

Verificado el 2026-09-26. "Activity" = último commit en rama por defecto (o anuncio oficial).

### 1. Roblox Studio MCP (integrado)
- **Repository**: n/a (incluido en Roblox Studio) · doc `create.roblox.com/docs/studio/mcp`
- **Maintainer**: Roblox
- **Purpose**: que clientes AI lean/modifiquen el place abierto, ejecuten Luau, controlen playtests y simulen input
- **Tools exposed**: `script_read`, `multi_edit`, `script_search`, `script_grep`, `search_game_tree`, `inspect_instance`, `execute_luau`, `subagent`, `get_studio_state`, `start_stop_play`, `get_console_output`, `screen_capture`, `character_navigation`, `user_keyboard_input`, `user_mouse_input`, `generate_mesh`, `generate_material`, `generate_procedural_model`, `wait_job_finished`, `search_asset`, `insert_asset`, `upload_image`, `store_image`, `http_get`, `skill`, `list_roblox_studios`, `set_active_studio`
- **Transport**: stdio
- **Auth**: sesión local de Studio (usuario logueado)
- **Security**: sin permisos por herramienta; "only connect clients you trust"; riesgos: `insert_asset` (backdoors), `execute_luau` (todo el DataModel), `http_get` (injection)
- **Activity**: anuncios 2026-02-21 y 2026-03-05; documentación 2026
- **License**: propietario (Roblox)
- **Maturity**: nuevo; playtest automation "experimental"
- **Recommendation**: **ADOPTAR** en Studio plane con políticas (sin `insert_asset` fuera de allowlist; nunca abrir places de producción)

### 2. `roblox-cloud-mcp` (propio)
- **Repository**: este monorepo `mcp/roblox-cloud-mcp/` (por construir)
- **Maintainer**: la fábrica
- **Purpose**: Open Cloud con niveles de permiso, dry-run/plan, aprobaciones y auditoría
- **Tools exposed**: ver `04_MCP_ARCHITECTURE.md` §4.2 (`cloud.*`)
- **Transport**: stdio
- **Auth**: API keys por entorno/nivel inyectadas por el runtime (GitHub Environments); el modelo no las ve
- **Security**: niveles READ…DELETE_PRODUCTION_DATA; plan_hash aprobado; audit_log append-only
- **Activity**: n/a · **License**: privada · **Maturity**: por construir
- **Recommendation**: **BUILD (fino)**; migrar a capa de políticas sobre el MCP oficial de Open Cloud cuando Roblox lo publique

### 3. GitHub MCP Server
- **Repository**: `github/github-mcp-server` · **Maintainer**: GitHub
- **Purpose**: issues, PRs, reviews, Actions, checks
- **Tools exposed**: issues/PRs/reviews/actions/search (≈50)
- **Transport**: stdio / remoto HTTP
- **Auth**: token/OAuth con scopes
- **Security**: limitar a repos de la fábrica; tokens de mínimo privilegio
- **Activity**: 2026-09-16 · **License**: MIT · **Maturity**: alta
- **Recommendation**: **ADOPTAR**

### 4. Postgres MCP
- **Repository**: `crystaldba/postgres-mcp` (el servidor de referencia de `modelcontextprotocol/servers` fue archivado en 2025 — el repo actual sólo incluye everything, fetch, filesystem, git, memory, sequentialthinking, time)
- **Maintainer**: Crystal DBA
- **Purpose**: consultas y salud de DB
- **Transport**: stdio/SSE · **Auth**: connection string
- **Security**: usar rol **read-only**; riesgo de escrituras si se configura mal
- **Activity**: 2026-08-15 · **License**: MIT (verificar) · **Maturity**: media
- **Recommendation**: **OPCIONAL**; por defecto usar `psql`/CLI `factory` con rol read-only (YAGNI)

### 5. Playwright MCP
- **Repository**: `microsoft/playwright-mcp` · **Maintainer**: Microsoft
- **Purpose**: navegador controlado por el agente
- **Transport**: stdio · **Auth**: n/a
- **Security**: prompt injection desde webs; no usar con sesiones logueadas en Roblox/Creator Hub
- **Activity**: 2026-09-25 · **License**: Apache-2.0 · **Maturity**: alta
- **Recommendation**: **LIMITADO** (verificar páginas públicas propias, p. ej. página del juego tras publicar)

### 6. Filesystem / Git / Fetch (referencia MCP)
- **Repository**: `modelcontextprotocol/servers` (activo 2026-09-22)
- **Recommendation**: **NO NECESARIO** — Claude Code ya trae Read/Write/Edit/Bash/WebFetch nativos

### 7. Blender MCP
- **Repository**: `ahujasid/blender-mcp` · **Maintainer**: comunidad (ahujasid)
- **Purpose**: controlar Blender (Python arbitrario), materiales, importación de assets
- **Transport**: stdio (servidor) + socket local con add-on de Blender
- **Auth**: ninguna (local)
- **Security**: ejecución de código arbitrario; integraciones de assets de terceros con licencias variables
- **Activity**: 2026-09-25 · **License**: MIT (verificar) · **Maturity**: media/experimental
- **Recommendation**: **EXPERIMENTAL (Fase 8)**, en VM/usuario aislado, sólo props/kits

### 8. weppy-roblox-mcp
- **Repository**: `hope1026/weppy-roblox-mcp` · **Maintainer**: hope1026
- **Purpose**: Studio + Open Cloud + sync + playtest (Pro)
- **Transport**: HTTP local `127.0.0.1:3002` + plugin · **Auth**: local
- **Security**: plugin de terceros con red; rate limit 450/min; rutas prohibidas CoreGui
- **Activity**: 2026-09-26 (v2.17.10) · **License**: **AGPL-3.0** + comercial · **Maturity**: media
- **Recommendation**: **NO** (licencia, supply chain, solapa con oficial)

### 9. robloxstudio-mcp (boshyxd)
- **Repository**: `boshyxd/robloxstudio-mcp` (archivado jun-2026; fork `Chrrxs/robloxstudio-mcp`)
- **Transport**: HTTP local + plugin · **License**: MIT · **Tools**: 43 (31 read-only en Inspector Edition)
- **Recommendation**: **NO**

### 10. Roblox/studio-rust-mcp-server
- **Repository**: `Roblox/studio-rust-mcp-server` — **archivado 2026-04-03**; tools `run_code`, `insert_model`, `get_console_output`, `start_stop_play`, `run_script_in_play_mode`, `get_studio_mode`; stdio; MIT
- **Recommendation**: **NO** (sustituido por el integrado)

### 11. Roblox-MCP-Analytics
- **Repository**: `michaeldougal/Roblox-MCP-Analytics` · Analytics Query API ("168 métricas, 16 categorías"), pacing de rate limit
- **Activity**: 2026-08-19 · **Security**: requiere API key con `universe.analytics:read`
- **Recommendation**: **REFERENCIA** para el catálogo de métricas; implementar el equivalente dentro de `roblox-cloud-mcp`

### 12. roblox-devproducts-mcp
- **Repository**: `frrazer/roblox-devproducts-mcp` · list/create/update de developer products
- **Activity**: 2026-09-20 · **Security**: escritura económica sin gates
- **Recommendation**: **NO**

### 13. Claude Docs / Image generation / Project management MCPs
- **Image generation**: sin MCP; llamadas desde `factory/` con registro en LEDGER.
- **Project management**: GitHub Issues/Projects vía GitHub MCP (sin Jira/Linear).
- **Analytics MCP**: dentro de `roblox-cloud-mcp`.
- **Open Cloud MCP oficial**: **NO EXISTE** a 2026-09-26 (anunciado como plan futuro, 2026-08-24).
