# 01 — Roblox Ecosystem (estado a 2026-09-26)

> Objetivo: mapa del ecosistema Roblox relevante para una fábrica de juegos. Qué existe, qué cambió en 2025–2026,
> qué sustituyó a qué, y qué implica para la automatización.

## 1. Cambios estructurales 2025–2026 que condicionan la fábrica

| Fecha | Cambio | Estado | Implicación para la fábrica |
|---|---|---|---|
| 2025-07-24 | Engagement-Based Payouts (Premium playtime) **deprecado**, sustituido por **Creator Rewards** (Daily Engagement + Audience Expansion) | HV (`production/monetization/engagement-based-payouts.md`, `creator-rewards.md`) | Los ingresos "pasivos" dependen de ser uno de los **3 primeros juegos del día** de un *Active Spender* con ≥10 min de juego. Premia retención/hábito diario, no volumen de visitas. |
| 2025-09-05 | DevEx estándar sube a **$0.0038/Robux** (antes $0.0035) | HV (`developer-exchange.md`) | Base del modelo Robux→USD. |
| 2025 (Q3) | Experiencias sin clasificar (N/A) dejan de ser jugables | HT (Roblox Wiki/Fandom, anuncios) | El **Maturity & Compliance Questionnaire** es obligatorio en el pipeline de publicación. |
| 2026-01 | **Age check obligatorio para chat**, rollout global | HV ([Roblox IR](https://ir.roblox.com/news/news-details/2026/Roblox-Requires-Users-Worldwide-to-Age-Check-to-Access-Chat/default.aspx)) | Mecánicas sociales basadas en chat de texto pierden alcance en menores; diseñar social co-play **sin depender del chat** (emotes, pings, parties). |
| 2026-02 | Studio **MCP Server** oficial + Assistant con LLMs externos (Anthropic/OpenAI/Google) | HV ([DevForum 2026-02-21](https://devforum.roblox.com/t/studio-mcp-server-updates-and-external-llm-support-for-assistant/4415631)) | No hace falta construir un MCP de Studio propio. |
| 2026-02 | **Rewarded Video Ads** abiertos a todos los creadores elegibles | HT ([gamebizconsulting](https://www.gamebizconsulting.com/blog/roblox-ad-monetization-guide-2026)); doc oficial `promotion/rewarded-video-ads.md` HV sobre requisitos | Nueva línea de ingresos para no-pagadores; recompensa debe ser Developer Product, nunca aleatoria. |
| 2026-02 | **4D Generation** (GenerationService / Cube) en beta abierta | HT ([DevForum](https://devforum.roblox.com/t/beta-4d-generation-unlock-new-types-of-gameplay/4331818)) | Generación 3D en runtime/Studio; aún limitado a esquemas (Car-5, Body-1). |
| 2026-03-05 | **MCP integrado en Studio** + automatización de playtest (input simulado, navegación, consola) | HV ([DevForum](https://devforum.roblox.com/t/assistant-updates-studio-built-in-mcp-server-and-playtest-automation/4474643)) | E2E asistido por agente dentro de Studio pasa a ser posible (experimental). |
| 2026-04-03 | `Roblox/studio-rust-mcp-server` **archivado**; se recomienda el MCP integrado | HV (README del repo) | Descartar el standalone. |
| 2026-04-30 | **Roblox Premium retirado → Roblox Plus** ($4.99/mes) | HV (`production/monetization/roblox-plus.md`) + HT ([piunikaweb](https://piunikaweb.com/2026/05/01/roblox-raises-devex-by-42-us-18-above-players/)) | Descuentos del 10–20% a suscriptores **subvencionados por Roblox** (share efectivo 78–88%); 250 Robux/mes × 3 por alta de Plus desde tu juego. |
| 2026-05-19 | **Nuevos requisitos de publicación en 3 niveles** + evaluación por juego | HV ([DevForum](https://devforum.roblox.com/t/new-publishing-requirements-evaluation-process-for-games/4573166)) | Ver §4. Cambia el soft launch: primero 16+, luego evaluación, luego todas las edades. |
| 2026-05-30 | Ventas **cross-game** de passes/dev products deshabilitadas → usar Robux transfers | HV (`passes.md`, `developer-products.md`) | Un portfolio **no** puede vender productos de un juego dentro de otro. Cross-promo sólo vía teleport/ads/share links. |
| 2026-06 (inicio) | Cuentas **Roblox Kids (5–8)** y **Roblox Select (9–15)** con catálogo filtrado | HV ([Roblox newsroom](https://about.roblox.com/newsroom/2026/04/introducing-roblox-kids-and-select-accounts)) | Para acceder a <16 hace falta rating Minimal/Mild (Kids) o hasta Moderate (Select), sin social hangouts ni dibujo libre, y ID + 2FA + Plus. |
| 2026-06-08 | **DevEx US 18+: $0.0054/Robux** (+42%) para compras de adultos verificados en EE. UU. en juegos elegibles (avatares R15, "high-quality character articulation") | HV (`18-plus-devex-rate.md`) | Palanca económica relevante: juegos R15-only con audiencia adulta monetizan mejor. |
| 2026-07-01 | **Rojo 7.7.0** (syncback, websockets/MessagePack) | HV (tag git `v7.7.0`, commit 2026-07-01) | Rojo sigue siendo la base del flujo Git-first. |
| 2026-08-24 | Nuevas Open Cloud APIs: **Analytics Query**, **Events**, **Experiments**, **Thumbnail Personalization** | HV ([DevForum](https://devforum.roblox.com/t/new-opencloud-apis-for-analytics-events-experiments-and-thumbnail-personalization/4828676); OpenAPI) | Analytics y experimentación por API: el bucle de datos puede automatizarse sin scraping del dashboard. |
| 2026-09-25 | Doc de **Discovery** actualizada: señales principales = Play Through Rate, First Play Bounce, Play Days/User, Playtime/User; ventanas D1, D2–7, D8–28 | HV (`discovery.md`, "Last updated September 25, 2026") | Las métricas de gate deben alinearse con estas señales. |

## 2. Mapa de servicios del engine relevantes (y su papel en la fábrica)

| Servicio / API | Uso en la fábrica | Notas verificadas |
|---|---|---|
| **DataStoreService** (standard/ordered) | Persistencia de jugador, economía, LiveOps state | Límites de throughput por experiencia; errores `*ExperienceThrottled` (HV `error-codes-and-limits.md`). Almacenamiento incluido: **100 MB + 1 MB × lifetime players**; exceso vía Extended Services a $0.12/GB-mes (HV `extended-services.md`). Versionado y snapshot (`data-stores:snapshot`) accesibles por Open Cloud. |
| **MemoryStoreService** (queues, sorted maps, hash maps) | Matchmaking, leaderboards en vivo, locks de sesión, colas de eventos | Cuota de memoria **64 KB + 1.2 KB × usuarios**; request units **1000 + 120 × CCU / min** (HV `memory-stores/index.md`). |
| **MessagingService** | Broadcast cross-server (anuncios LiveOps, kill-switch) | Publicable desde fuera vía Open Cloud `:publishMessage` (5000/min) (HV). |
| **ConfigService** (Experience Configs) | Remote config / feature flags nativos | Hasta **1,000 configs activos**, tipos string/number/bool/JSON (JSON ≤100,000 chars), propagación ~15 s–1 min o gradual 15 min, **condicionales por atributos** (país, tenure, idioma, payer…), 100 condiciones/juego, 20 por key; **solo servidor**; staging en Studio; "publish to another experience" (staging→prod) (HV `production/configs.md`). |
| **Experiments** (nativo) | A/B tests in-game y de matchmaking | 14–60 días; hasta 2 variantes + control (in-game), 3 (matchmaking); métricas D1, D7, playtime, ARPU, ARPPU, payer conversion, session time; MDE calculable; targeting por atributos (HV `production/experiments.md`). |
| **AnalyticsService** | Custom events, economy events, funnel events, custom fields | 100 custom events, 10 funnels, 5 currencies (economy dashboard), 3 custom fields; cardinalidad agrupada en "Other" más allá de umbrales; retención 90 días desde último dato (HV `analytics/*.md`). |
| **MarketplaceService** | Passes, Dev Products, suscripciones, `ProcessReceipt`, `GetUsersPriceLevelsAsync`, `PromptRobloxSubscriptionPurchase`, `RankProductsAsync`/`RecommendTopProductsAsync` | `ProcessReceipt` obligatorio (no `PromptProductPurchaseFinished`) (HV `developer-products.md`). |
| **PolicyService** | Elegibilidad por región/edad: paid random items, trading de ítems pagados, suscripciones, commerce, links sociales | **Obligatorio** integrarlo (HV `monetization/index.md`, `paid-random-items.md`). |
| **AdService** | Rewarded video ads (`GetAdAvailabilityNowAsync`, `RegisterAdOpportunityAsync`) | Recompensa = Developer Product, no aleatoria, no Robux (HV). |
| **TextChatService** | Chat | Chat de texto condicionado a age check (HV IR). LegacyChatService retirado (HT). |
| **TeleportService** | Multi-place (lobby→match), reserved servers | — |
| **HttpService** | Salida a servicios externos (telemetría propia) y Open Cloud in-game | Límite **500 req/min/servidor** para HTTP general; Open Cloud desde juego tiene cuota separada de **2500/min/servidor** (HV `http-service.md`). |
| **LocalizationService** + tablas + traducción automática | Localización | Open Cloud `:translateText` (BETA) y APIs legacy de tablas (EXPERIMENTAL) (HV OpenAPI). |
| **GenerationService** | 3D/4D generativo en runtime | Beta; esquemas limitados (HT). |
| **Secrets store** | API keys para llamadas externas desde servidores | Open Cloud `universes/{id}/secrets` (BETA) (HV). |
| **Matchmaking personalizado** | Scoring configurable de servidores | Open Cloud `matchmaking-api/v1` (BETA, 29 ops) (HV). |
| **BadgeService**, **Notifications** (`users/{id}/notifications`, STABLE), **Experience Events** (`virtual-events/v3`, EXPERIMENTAL) | Retención y re-engagement | HV (OpenAPI). |

**Universes y places.** Una experiencia = un *universe* con uno o varios *places*. DataStores, Configs, Experiments y
analytics son **por universe** [HV]. Consecuencia [DEC]: cada juego tiene **al menos 2 universes** (staging y production) y la fábrica
comparte **1 universe de CI** con places de test (para Luau Execution), para que tests y staging nunca toquen datos de producción.

**Packages** (Roblox Packages) permiten reutilizar assets entre places con auto-update [HT]; la fábrica prefiere **código en Git vía Rojo**
y reserva Packages para assets de arte compartidos (ver `17_ASSET_PIPELINE.md`).

## 3. Studio: qué requiere Studio y qué no

| Actividad | ¿Requiere Studio? | Alternativa headless |
|---|---|---|
| Escribir/editar código Luau | No | Editor + Rojo (fuente en Git) |
| Construir `.rbxl` desde Git | No | `rojo build` (Linux OK) |
| Publicar place | No | Open Cloud `POST /universes/v1/{u}/places/{p}/versions` (BETA, 30/min) |
| Ejecutar tests dentro del engine | No (con límites) | Open Cloud **Luau Execution** (STABLE; script ≤4 MB, ≤5 min, logs ≤450 KB, 5 tareas/min por owner) |
| Playtest con cliente real, cámara, input, UI | **Sí** | Studio + MCP integrado (`start_stop_play`, `user_keyboard_input`, `user_mouse_input`, `character_navigation`, `screen_capture`) |
| Test multi-cliente (N jugadores) | **Sí** (Team Test / Local Server) | No hay API oficial headless multi-cliente → **NO DISPONIBLE** headless |
| Edición de terreno, iluminación, construcción visual | **Sí** (o vía `execute_luau` en MCP) | Parcial: scripts de construcción procedurales ejecutados por MCP/Luau Execution |
| Rellenar el Maturity & Compliance Questionnaire | Creator Hub (web) | **NO DISPONIBLE** vía API (no aparece en el OpenAPI) → humano |
| Configurar suscripciones | Creator Hub | No hay endpoint de creación de suscripciones en el OpenAPI (sólo `GET` de una suscripción) → humano |
| Crear/editar passes y dev products | No | Open Cloud `game-passes/v1`, `developer-products/v2` (BETA) |

Roblox Studio corre en **Windows y macOS**, no en Linux [HV, requisitos de Studio]. ⇒ La fábrica tiene **dos planos de ejecución**:
**Cloud plane** (Linux: Git, CI, Rojo, Lune, Open Cloud) y **Studio plane** (estación Windows/macOS con Studio + Claude Code local + MCP integrado).

## 4. Publicación (desde 2026-05-19) — impacto directo en el pipeline

[HV — [DevForum](https://devforum.roblox.com/t/new-publishing-requirements-evaluation-process-for-games/4573166)]

| Nivel | Requisitos | Uso en la fábrica |
|---|---|---|
| Personal use | Ninguno | Places de CI y staging (no descubribles) |
| 16+ y "trusted friends" | Age check, cuenta en buen estado, cuenta ≥2 días | **Soft launch inicial** con audiencia 16+ |
| Todas las edades | Lo anterior + ID verificado + 2FA + **Roblox Plus/Premium activo o fee de 1,000 Robux por juego (reembolsable a 90 días)** + **evaluación del juego** (se prueba con usuarios 16+ age-checked; Roblox analiza señales de engagement genuino: edad de cuenta, historial, gasto) | Gate de escalado a audiencia completa |

[INFERENCIA] La evaluación convierte el soft launch 16+ en **obligatorio de facto** para llegar a <16. Esto encaja con el modelo de stage gates
(Gate 4) y **desincentiva fábricas de volumen**: cada juego necesita engagement orgánico real de adultos jóvenes antes de abrirse.

## 5. Plataforma (contexto de mercado)

| Métrica | Valor | Fuente |
|---|---|---|
| DAU Q2 2026 | ~123 M (+10% a/a) | HT (resumen de [8-K Q2 2026, SEC](https://www.sec.gov/Archives/edgar/data/0001315098/000162828026051059/ex991-robloxq22026earnin.htm)) |
| Pagadores únicos mensuales Q2 2026 | ~27 M; ~$19.25 bookings/pagador/mes | HT (mismo) |
| DevEx fees Q2 2026 | ~$363 M (+15% a/a) | HT (mismo) |
| Composición de edad | Más usuarios ≥13 que <13 | HV (`production/roblox-user-base.md`) |
| Consolas | "200M+ Xbox and PlayStation players" como audiencia potencial | HV (`console-guidelines.md`) |
| Distribución por dispositivo | No publicada oficialmente de forma actualizada | **Dato no observable públicamente**; en tu juego: Analytics breakdown por `Platform` (HV) |

## 6. Assistant de Roblox (competidor/aliado del agente propio)

Roblox Studio **Assistant** soporta **Skills** propias (Markdown con frontmatter `name`, `description`, `enabled`) y LLMs externos vía API key
[HV `assistant/skills.md`, DevForum 2026-02-21]. [DECISIÓN PROPUESTA] La fábrica usa **Claude Code como agente principal** (Git-first, CI, multi-repo)
y el MCP integrado de Studio como puente; las *Assistant Skills* se generan desde las mismas fuentes que las Claude Skills para no duplicar conocimiento
(ver `05_CLAUDE_SKILLS.md` §Portabilidad).
