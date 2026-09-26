# 13 — Analytics, Event Taxonomy, Métricas, Observabilidad e Incidentes

## 1. Capacidades analíticas disponibles (§27)

| Vía | Qué da | Acceso programático | Estado |
|---|---|---|---|
| **Creator Dashboard – Analytics** | Engagement, retención, monetización, adquisición (incluye **Home Recommendations dashboard**: impresiones, plays, señales D1/D2–7/D8–28 y benchmarks de similares), demografía, performance (FPS, memoria, OOM, crashes, heartbeat, memoria servidor), economía, funnels, custom events, error report, alerts, custom dashboards | Parcial: **Analytics Query API** | HV (`production/analytics/*`, `discovery.md`) |
| **Analytics Query API** (Open Cloud) | Series temporales y dimensiones; asíncrono; 30 req/min; 4 años de historia (28 días performance); latencia observada 5–13 h | Sí | HV (BETA) |
| **AnalyticsService** (in-game) | Custom events (≤100), economy events (≤5 currencies en dashboard), funnel events (≤10 funnels, onboarding + recurrentes), 3 custom fields; cardinalidad agrupada en "Other" | Se consulta vía dashboard/API | HV |
| **Experiments** nativo | D1, D7, playtime, ARPU, ARPPU, payer conversion, session time por variante; stats por API | Sí (EXPERIMENTAL) | HV |
| **Server logs** | Logs por servidor/versión con filtro CEL | Sí (BETA) | HV |
| **Eventos propios → warehouse externo** | Event-level data, joins arbitrarios, cohortes a medida | Sí (HttpService, 500 req/min/servidor; batching) | Diseño propio |
| **Alerts** nativas | Alertas en tiempo real de performance/errores; alertas tempranas de daño en experimentos (anunciado ago-2026) | Dashboard | HV (newsroom 2026-08) |

**[DEC-018]** Estrategia en dos niveles: (1) **Roblox-native first** (AnalyticsService + Query API + Experiments) — gratis, alineado con las métricas que usa
discovery, sin riesgos de privacidad; (2) **warehouse propio sólo para lo que Roblox no da** (event-level, ledger económico muestreado, señales de exploit,
métricas de fábrica), activado desde Fase 7 y con datos pseudonimizados.

## 2. Event taxonomy común (§28)

Convenciones: `snake_case`; **nombres de evento de baja cardinalidad**, detalle en custom fields (Roblox recomienda campos sobre nombres por el límite
de cardinalidad [HV]); los 3 custom fields tienen significado fijo en toda la fábrica:

- `CustomField01` = **contexto de contenido** (p. ej. `zone:forest`, `quest:q12`, `item:sword_2`)
- `CustomField02` = **variante/segmento** (`exp:<id>:<variant>` o `seg:new|returning|payer`)
- `CustomField03` = **versión** (`v<build>`) — permite comparar releases

| Categoría | Evento | Tipo Roblox | Notas |
|---|---|---|---|
| Sesión | `session_start`, `session_end` (valor = duración s) | custom | Roblox ya mide sesiones; se usa para cruzar con custom fields |
| Onboarding | `tutorial_step` (step n, nombre) | **Onboarding funnel** (`LogOnboardingFunnelStepEvent`) | Pasos ≤ 10, numerados; `tutorial_complete` = último paso |
| Core | `core_action` (valor = cantidad agregada por minuto) | custom | Agregar en lotes para respetar límites |
| Progreso | `level_start`, `level_complete`, `level_fail` | custom / progression funnel | |
| Economía | `currency_earned`, `currency_spent` | **Economy events** (`LogEconomyEvent` con `flowType` source/sink, `transactionType`, `itemSku`) | ≤5 monedas visibles; XP como moneda con clase en CF01 |
| Tienda | `shop_open`, `purchase_view`, `purchase_prompt`, `purchase_success`, `purchase_fail` | **Recurring funnel** "shop" | `purchase_success` también llega vía ProcessReceipt (fuente de verdad) |
| Ads | `ad_opportunity` (RegisterAdOpportunityAsync), `ad_reward_granted` | custom + nativo de AdService | |
| Muerte | `death` (CF01 = causa), `respawn` | custom | |
| Social | `party_created`, `friend_joined`, `invite_sent`, `share_link_opened` | custom | Co-play es señal de discovery |
| LiveOps | `quest_start`, `quest_complete`, `daily_reward_claim`, `event_participate` | custom / recurring funnel | |
| Retención | `retention_trigger` (CF01 = tipo: notification, streak, event) | custom | |
| Experimentos | `experiment_exposure` (CF02 = exp:variant) | custom | Además del tracking nativo |
| Técnica | `client_error` (agregado), `perf_sample` | **No** en AnalyticsService → logs/warehouse | Evitar ensuciar el dashboard |
| Seguridad | `exploit_signal` | logs/warehouse | Nunca visible en dashboard público del equipo ampliado |

## 3. Métricas (§29): accesibles vs deseables

| Métrica | Accesible | Dónde | Comentario |
|---|---|---|---|
| CCU | Sí | Dashboard/API; `/v1/games` (público) | |
| DAU / MAU | Sí | Dashboard/API | |
| Session length, sessions/player | Sí | Dashboard/API | |
| D1 / D7 / D30 | Sí (D1, D7, D30 en dashboard; D1/D7 en Experiments) | Dashboard/API | |
| Play days per user D1, D2–7, D8–28; playtime/user; PTR; first-play bounce | Sí | Home Recommendations dashboard (Acquisition) | **Señales de discovery** → métricas norte |
| Tutorial completion | Sí | Onboarding funnel | |
| Payer conversion, ARPDAU, ARPPU | Sí | Monetización/Experiments | |
| LTV | **Parcial** | Derivable de cohortes (API) — Roblox no da LTV directo [INF] | Modelo propio (§5) |
| Ingresos por Creator Rewards / ads | Sí (monetización / ads dashboard) | Dashboard | API: verificar cobertura en Query API |
| Virality (K-factor) | **Parcial** | invites/share links (propios) + Audience Expansion | Estimación propia |
| Friend joins / co-play | Parcial | Intentional co-play days (dashboard) + eventos propios | |
| Crash/error rate | Sí | Performance dashboard, error report, server logs API | |
| Server performance | Sí | Performance dashboard (heartbeat, memoria) | |
| Acquisition source (home, search, sponsored, friends) | Sí (dashboard) | Acquisition | |
| **CAC** | Sí para ads propios (Ads Manager reporting) | Ads dashboard / Ads API (E) | |
| Métricas de competidores | **No** (salvo CCU/visitas/favs/votos públicos) | Trend Engine | |

**North-star por fase** [DEC]: soft launch → `play_days_per_user_D2-7` y `first_play_bounce`; LIVE → `D8-28 play days` × `ARPDAU`; fábrica → EV/€.

## 4. Game Operations Dashboard (§62)

Implementación [DEC-019]: **no construir UI propia al inicio**. Fase 7: Metabase/Grafana (open source) sobre Postgres, alimentado por:
Analytics Query API (diario/horario), server logs API (cada 5–15 min, sólo severidad ≥ warning), eventos propios, estado de la fábrica.

Paneles por juego: salud (CCU, error rate por versión, heartbeat, memoria servidor, OOM), retención (cohortes, señales de discovery vs benchmarks),
economía (sources/sinks, balance medio, inflación = crecimiento de balance medio por cohorte-día), monetización (conversion, ARPDAU, mix de ingresos),
exploit signals, experimentos activos, LiveOps (calendario, participación), releases (versión actual, fecha, incidentes).

Panel de fábrica: juegos por estado, WIP, coste acumulado por juego/etapa (tokens + horas), tasa de kill por etapa, tiempo por transición.

## 5. Modelo de LTV (propio)

`LTV_h = Σ_{t=0..h} ARPDAU_cohorte(t) × Retención_cohorte(t)` con retención extrapolada por ajuste de potencia `R(t) = a·t^(−b)` sobre D1–D28
(bueno para F2P [HT, práctica común de la industria]); intervalo por bootstrap de cohortes. Convertir a USD con §56 del cost model (share, DevEx).

## 6. Incident management (§63)

```text
Detection → Classification → Mitigation (flag/rollback) → Root cause → Postmortem → KB update
```

| Fase | Automatización | Detalle |
|---|---|---|
| Detection | A4 | Reglas: error rate por versión > 3× baseline; heartbeat p50 < 45; spike de `DataStore` throttling; caída de CCU > 40% vs misma hora de la semana anterior (sin release/evento que lo explique); anomalía económica (z > 6 en ingreso/hora); pico de `exploit_signal`; fallos de ProcessReceipt |
| Classification | A3 | SEV1 (pérdida de datos/dinero, juego caído), SEV2 (feature crítica rota, exploit activo), SEV3 (degradación) |
| Mitigation | A3 para flags/kill-switches **pre-aprobados**; A2 para rollback de versión y restarts | Runbooks en `knowledge/runbooks/` |
| Root cause | A3 (análisis) | Logs + diff de release + datos |
| Postmortem | A3 borrador / humano aprueba | Plantilla blameless |
| KB update | A3 | Regla nueva en SDK/linters si es prevenible |

Notificación: GitHub Issue con label `incident/SEVx` + push/email al responsable humano; SEV1 despierta a humano siempre.
