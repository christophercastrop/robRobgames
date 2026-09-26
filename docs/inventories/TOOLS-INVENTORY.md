# TOOLS-INVENTORY

Actividad verificada el 2026-09-26 (último commit en rama por defecto / último tag). Coste = coste directo de licencia/uso.
Build/Buy: **BUY** (servicio de terceros, incl. gratuito oficial) · **OSS** (usar open source) · **WRAP** (envolver) · **BUILD** · **NO** (no usar/no construir).

| Tool | Tipo | Función | Fuente | Estado (2026-09-26) | Coste | Riesgo | Build/Buy |
|---|---|---|---|---|---|---|---|
| Roblox Studio | IDE/engine | Edición, playtest | create.roblox.com | Oficial, Win/macOS | 0 | Sin Linux | BUY |
| Studio MCP integrado | MCP | Agente ↔ Studio | create.roblox.com/docs/studio/mcp | Oficial (feb–mar 2026) | 0 | Sin permisos granulares | BUY |
| Roblox Assistant (+ skills, LLM externo) | IA en Studio | Asistente | docs/assistant | Oficial | 0 / API key propia | Solapamiento | NO (usar Claude Code) |
| Open Cloud APIs | API | Automatización cloud | create.roblox.com/docs/cloud | 83% BETA/EXPERIMENTAL | 0 | Cambios de API | BUY + WRAP |
| Luau Execution API | API | Tests/scripts headless | idem | STABLE, 5/min | 0 | Rate limit bajo | BUY |
| Configs / ConfigService | Servicio | Remote config | docs/production/configs | GA | 0 | Límites 1,000 keys | BUY + WRAP |
| Experiments | Servicio | A/B tests | docs/production/experiments | GA (API EXPERIMENTAL) | 0 | Pocas variantes | BUY + WRAP |
| Analytics / AnalyticsService / Query API | Servicio | Métricas | docs/production/analytics | GA / API BETA | 0 | Latencia 5–13 h | BUY |
| Ads Manager (+API) | Servicio | UA | docs/production/promotion | GA / API EXPERIMENTAL | Gasto | Gasto | BUY (humano) |
| Extended Services | Servicio | Cuotas extra | docs/cloud-services | GA | Pago por uso | Coste | BUY (si hace falta) |
| GenerationService / Cube | IA 3D | Generación | anuncios Roblox | Beta | 0 | Calidad | BUY (opcional) |
| Rojo | CLI/plugin | Sync/build | github.com/rojo-rbx/rojo | v7.7.0 (2026-07-01) | 0 (MPL-2.0) | Bajo | OSS |
| Roblox Script Sync | Studio beta | Sync de scripts | docs/scripting/sync | Beta | 0 | No es fuente de verdad | NO (núcleo) |
| Argon | Sync | Alternativa Rojo | dervexdev/argon | 2024-06 | 0 | Parado | NO |
| Azul | Sync | Alternativa Rojo | ransomwave/azul | Activo (v2.2.0) | 0 | Joven | NO (vigilar) |
| Rokit | Toolchain mgr | Versiones de CLIs | rojo-rbx/rokit | v1.2.0 | 0 | Bajo | OSS |
| Aftman | Toolchain mgr | idem | LPGhatguy/aftman | 2025-07, pre-release | 0 | Futuro incierto | NO |
| Foreman | Toolchain mgr | idem | Roblox/foreman | v1.7.0 | 0 | Interno Roblox | NO |
| Wally | Package mgr | Deps | UpliftGames/wally | Commits 2026-09; release v0.3.2 (2023) | 0 | Releases lentas | OSS |
| pesde | Package mgr | Deps multi-runtime | pesde-pkg/pesde | v0.7.4 (2026-08) | 0 | Ecosistema menor | NO (vigilar) |
| StyLua | Formatter | Formato | JohnnyMorganz/StyLua | v2.5.2 | 0 | Bajo | OSS |
| Selene | Linter | Lint | Kampfkarren/selene | 0.31.0 | 0 | Bajo | OSS |
| luau-lsp | LSP/typecheck | Tipos/CI | JohnnyMorganz/luau-lsp | 1.70.0 (2026-09-20) | 0 | Bajo | OSS |
| Roblox LSP (Nightrains) | LSP | — | — | Superado | 0 | — | NO |
| Luau | Lenguaje | — | luau-lang/luau | Activo | 0 | — | OSS |
| darklua | Transformador | Bundling | seaofvoices/darklua | v0.19.0 | 0 | Bajo | OSS (opcional) |
| Moonwave | Docs | Docs del SDK | evaera/moonwave | v1.4.2 | 0 | Bajo | OSS (opcional) |
| Jest-Lua | Test framework | Tests en engine | jsdotlua/jest-lua | v3.10.0 (2024-12) | 0 (MIT) | Baja actividad | OSS (pin) |
| TestEZ | Test framework | — | Roblox/testez | 2023 | 0 | Parado | NO |
| Lune | Runtime Luau | Unit tests, tooling, .rbxl | lune-org/lune | v0.10.5 | 0 | Bajo | OSS |
| Remodel | Tooling | .rbxl | rojo-rbx/remodel | 2023 (→ Lune) | 0 | Deprecado | NO |
| run-in-roblox | Runner | Tests en Studio | rojo-rbx/run-in-roblox | 2020 | 0 | Abandonado | NO |
| roblox-ts | Compilador TS→Luau | Lenguaje | roblox-ts/roblox-ts | Activo (v3.0.0) | 0 | Capa extra | NO |
| Knit | Framework | Services | Sleitnick/Knit | 2024-07 | 0 | Parado | NO |
| Nevermore | Librería | Modular | Quenty/NevermoreEngine | Activo | 0 | Pesado | NO (referencia) |
| Matter | ECS | — | evaera/matter | 2024-07 | 0 | Parado | NO |
| jecs | ECS | ECS | Ukendio/jecs | v0.11.0 | 0 | Bajo | OSS (opcional) |
| Reflex | State | Redux-like | littensy/reflex | v4.3.1 | 0 | Menos activo | NO (alternativa) |
| Charm | State | Átomos + sync | littensy/charm | v0.7.6 | 0 | Bajo | OSS |
| Fusion | UI | Reactiva | dphfox/Fusion | v0.3-beta | 0 | Beta | NO (alternativa) |
| React Lua | UI | React | jsdotlua/react-lua | v17.2.1 (2024) | 0 | Parado | NO (alternativa) |
| Vide | UI | Reactiva | centau/vide | 0.4.1 activo | 0 | Pre-1.0 | OSS |
| Promise (evaera) | Async | Promesas | evaera/roblox-lua-promise | 2023 | 0 | Parado | NO (nuevo código) |
| Janitor | Cleanup | — | howmanysmall/Janitor | v1.17.0 | 0 | Bajo | NO (alternativa) |
| Trove (RbxUtil) | Cleanup | — | Sleitnick/RbxUtil | 2026-07 | 0 | Bajo | OSS |
| Zap | Networking IDL | Remotes tipados | red-blox/zap | v0.6.29 | 0 | Bajo | OSS (DEC-007) |
| Blink | Networking IDL | Remotes tipados | 1Axen/blink | v1.0.0-pre.10 | 0 | Pre-release | OSS (alternativa) |
| ByteNet | Networking | — | ffrostflame/ByteNet | 2025-08 | 0 | Menos activo | NO |
| ProfileStore | Datos | Session-locked data | MadStudioRoblox/ProfileStore | 2025-07 | 0 | Bus factor | OSS + WRAP |
| ProfileService | Datos | Predecesor | MadStudioRoblox/ProfileService | 2024-10 | 0 | Sustituido | NO |
| rbxcloud | CLI Open Cloud | Scripts | Sleitnick/rbxcloud | v0.17.0 (2025-03) | 0 | No cubre APIs 2026 | NO (cliente propio) |
| Claude Code | Agente | Desarrollo/agentes | code.claude.com | Activo | Plan/API | Coste | BUY |
| Claude Agent SDK | Librería | Orquestación | code.claude.com/docs/en/agent-sdk | Activo | API | — | BUY |
| Claude API (Opus 5.5 / Sonnet 5 / Haiku 4.5) | LLM | Razonamiento/batch | Anthropic | Activo | $1–$20/M tokens | Coste | BUY |
| MCP Python SDK | Librería | Construir MCP | modelcontextprotocol/python-sdk | Activo | 0 | Bajo | OSS |
| GitHub + Actions | SCM/CI | Repo, CI, approvals | github.com | Activo | $0–$ | Bajo | BUY |
| GitHub MCP server | MCP | Issues/PRs | github/github-mcp-server | Activo | 0 | Scopes del token | OSS |
| Postgres (+pgvector) | DB | Factory DB/warehouse | — | Activo | $0–$ | Bajo | OSS |
| postgres-mcp (crystaldba) | MCP | DB | crystaldba/postgres-mcp | 2026-08 | 0 | Escritura si mal configurado | OSS (opcional, read-only) |
| Metabase / Grafana | BI | Dashboards | — | Activo | 0 (OSS) | Bajo | OSS |
| Playwright MCP | MCP | Navegador | microsoft/playwright-mcp | Activo | 0 | Prompt injection | OSS (limitado) |
| Blender | DCC | 3D | blender.org | Activo | 0 | — | OSS |
| Blender MCP | MCP | Claude→Blender | ahujasid/blender-mcp | Activo (2026-09-25) | 0 | Código arbitrario | OSS (experimental, aislado) |
| Generación de imágenes (proveedor con licencia comercial) | IA 2D | Iconos/UI | — | — | Por uso | Licencias/IP | BUY (con LEDGER) |
| YouTube Data API v3 | API | Señal social | developers.google.com/youtube | Activo | Gratis (cuota) | Cuota | BUY |
| Twitch Helix | API | Señal social | dev.twitch.tv | Activo | Gratis | Bajo valor | BUY (opcional) |
| Reddit Data API | API | Señal social | reddit.com/dev | Activo | Gratis/comercial | Términos | BUY (opcional) |
| RoMonitor Stats | Web | Históricos (manual) | romonitorstats.com | Activo | 0 | Sin API pública | NO (manual) |
| Rolimon's | Web | Limiteds | rolimons.com | Activo | 0 | Irrelevante para juegos | NO |
| Google Trends | Web | Búsquedas | trends.google.com | Activo | 0 | Sin API GA | NO (manual) |
| TikTok Research API | API | Tendencias | — | Sólo académica | — | No accesible | NO |
| X API | API | Menciones | — | De pago | $$ | Coste/valor | NO |
| weppy-roblox-mcp | MCP | Studio | hope1026/weppy-roblox-mcp | Activo | Freemium (AGPL) | Licencia/supply chain | NO |
| robloxstudio-mcp (boshyxd) | MCP | Studio | boshyxd/robloxstudio-mcp | Archivado 2026-06 | 0 | Sin mantenimiento | NO |
| studio-rust-mcp-server | MCP | Studio | Roblox/studio-rust-mcp-server | Archivado 2026-04-03 | 0 | — | NO |
| Roblox-MCP-Analytics | MCP | Analytics | michaeldougal/Roblox-MCP-Analytics | 2026-08 | 0 | Terceros con API key | NO (referencia) |
| roblox-devproducts-mcp | MCP | Dev products | frrazer/roblox-devproducts-mcp | 2026-09 | 0 | Escritura económica sin gates | NO |
| `roblox-cloud-mcp` (propio) | MCP | Open Cloud con permisos | este repo | Por construir | 0 | Mantenimiento | BUILD |
| Factory SDK (`packages/sdk`) | Librería Luau | Núcleo de juegos | este repo | Por construir | 0 | — | BUILD |
| Trend/Opportunity Engine | Servicio | Mercado | este repo | Por construir | infra | ToS (STOP-01) | BUILD |
| econsim | Herramienta | Simulación económica | este repo | Por construir | 0 | Supuestos | BUILD |
| Policy engine | Herramienta | Compliance | este repo | Por construir | 0 | Falsa seguridad | BUILD |
| Security scanner | Herramienta | Anti-exploit/backdoor | este repo | Por construir | 0 | Falsos negativos | BUILD |
| Orchestrator | Servicio | State machine | este repo | Por construir | 0 | Complejidad | BUILD (mínimo) |
