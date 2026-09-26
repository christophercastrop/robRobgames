# DATA-SOURCES

Estado de verificación a 2026-09-26. "ToS" resume el estado de legitimidad; ⛔ = requiere decisión humana/legal (STOP-01).

| Source | Data | API | Cost | Limits | ToS | Refresh | Use |
|---|---|---|---|---|---|---|---|
| **Roblox Open Cloud** (universes propios) | Métricas, logs, datastores, configs, experiments, assets | Sí, oficial | 0 | Por endpoint (p. ej. Analytics 30/min, Luau Exec 5/min) | Oficial | Horario/diario | Operación de nuestros juegos |
| **Roblox Analytics (dashboard)** | Todo lo del dashboard, benchmarks de similares, Home Recommendations signals | Parcial (Query API) | 0 | — | Oficial | Diario | Gates, discovery |
| **games.roblox.com `/v1/games`** | CCU, visitas, favs, fechas, genre_l1/l2, creador, precio | Documentado en referencia oficial; anónimo; EXPERIMENTAL | 0 | No documentados → ≤1 req/s, lotes | Documentado; uso comercial automatizado no explícitamente autorizado → bajo volumen (⛔ STOP-01a) | Horario (T1) | Trend Engine |
| `games.roblox.com /v1/games/votes` | Up/down votes | Documentado | 0 | idem | idem | Diario | Rating |
| `games.roblox.com /v1/games/recommendations/game/{id}` | Juegos similares | Documentado | 0 | idem | idem | Semanal | Grafo/competidores |
| `thumbnails.roblox.com` | Iconos/thumbnails | Documentado, STABLE | 0 | idem | idem | Diario/on-change | Creative analysis |
| Explore/Charts/Search endpoints web | Rankings | **No documentados** | 0 | — | ⛔ STOP-01b (propuesta: no usar) | — | — |
| Roblox Charts (web, humano) | Top/Trending por género | No (manual) | Tiempo humano | — | Uso normal | Semanal | Seeds de IDs |
| Roblox DevForum / Creator Hub / `Roblox/creator-docs` (GitHub) | Cambios de APIs y políticas | Git | 0 | — | Público | Semanal (diff) | Compliance, KB |
| RoMonitor Stats | Históricos CCU/visitas, estimaciones | Sin API pública documentada | 0 | — | Uso manual; acuerdo si se quiere integrar | Manual | Contexto histórico |
| Rolimon's | Limiteds/trading | No para juegos | 0 | — | — | — | No usar |
| GameAnalytics "Roblox Benchmark Report 2026" | Benchmarks agregados | No (PDF/web) | 0 | — | Público | Anual | Priors de gates |
| YouTube Data API v3 | Vídeos, vistas, títulos, canales | Sí | Gratis (cuota por defecto 10k u/día [HT]) | `search.list` 100 u | ToS YouTube API (sin almacenamiento prolongado de ciertos datos; revisar) | Diario | Demanda social |
| Twitch Helix | Streams/viewers/títulos | Sí | Gratis | Rate limits por token | ToS Twitch | Horario | Señal débil |
| Reddit Data API | Posts/comentarios | Sí | Gratis limitado; comercial de pago [HT] | QPM por cliente | Términos Reddit (comercial) | Diario | Señales de comunidad |
| TikTok | Tendencias | Research API sólo académica [HT] | — | — | No disponible comercialmente | Manual (Creative Center) | Inspiración manual |
| X (Twitter) API | Menciones | Sí | De pago [HT] | — | ToS X | — | No usar (coste/valor) |
| Discord | Comunidad | Sólo bots en servidores propios | 0 | — | Prohibido scraping de terceros | Continuo | Comunidad propia/feedback |
| Google Trends | Interés relativo de búsqueda | Sin API GA (alpha anunciada 2025 [HT]) | 0 | — | Uso manual | Semanal | Contexto |
| Google Search | Resultados | No (APIs de pago) | $ | — | — | — | No |
| App analytics (stores) | Descargas de la app Roblox | No relevante por juego | — | — | — | — | No |
| Playtests humanos propios | Diversión, claridad, fricción | Formularios | Incentivos | — | Consentimiento; no menores sin consentimiento parental | Por gate | G2, G4 cualitativo |
| Juegos propios: eventos → warehouse | Event-level | HttpService (500 req/min/servidor) | Infra | Batching | Privacidad: pseudonimización, sin PII (⛔ STOP-04 para datos fuera de Roblox) | Continuo | Análisis profundo |
