# 03 — Roblox Open Cloud (APIs verificadas)

> **Fuente primaria**: `content/en-us/reference/cloud/openapi.json` del repo oficial `Roblox/creator-docs` (commit del 2026-09-26),
> que alimenta la referencia del Creator Hub. Contiene **720 operaciones** (Open Cloud + APIs web "legacy" documentadas).
> Extracción de las 230 operaciones relevantes: [`docs/data/open-cloud-endpoints.txt`](../data/open-cloud-endpoints.txt).
> Estabilidad (`x-roblox-stability`), scopes (`x-roblox-scopes`) y rate limits (`x-roblox-rate-limits`) son los declarados en el OpenAPI → **[HECHO VERIFICADO]**.

## 1. Autenticación

- **API keys** (Creator Dashboard → Open Cloud → API Keys): scopes por "API system" y por universe; restricción por IP y expiración configurables [HV `cloud/auth`].
  Los rate limits de API key se aplican **por propietario** (usuario o grupo), sumando todas sus claves [HV `rate-limits.md`].
- **OAuth 2.0** (recomendado para apps multi-usuario; límites por token) [HV].
- Muchas operaciones son invocables **desde el juego** con `HttpService` + secret (`x-roblox-engine-usability.apiKeyWithHttpService`) — marcadas "HS".
- Manejo de 429: respetar `retry-after`, headers `x-ratelimit-*`; pueden existir límites no documentados [HV].

[DEC] **Una API key por (entorno × nivel de permiso)**, propiedad de un **grupo** Roblox de la fábrica (no de una cuenta personal), con IP allowlist
del runner de CI y expiración ≤90 días. Ver matriz en `04_MCP_ARCHITECTURE.md`.

## 2. Catálogo por familia

Leyenda estabilidad: **S** = STABLE, **B** = BETA, **E** = EXPERIMENTAL. Rate limit = por propietario de API key (`/MIN` o `/SEC`).

### 2.1 Universes, places, publicación, servidores

| Operación | Endpoint | Scope | Est. | Rate | Automatizable | Riesgo operativo |
|---|---|---|---|---|---|---|
| Get/Update universe (nombre, descripción, visibilidad, precios de private server, voice, etc.) | `GET/PATCH /cloud/v2/universes/{universe_id}` | `universe:write` (PATCH) | S | 100/min | Sí | Medio (metadata pública) |
| Get/Update place | `GET/PATCH /cloud/v2/universes/{u}/places/{p}` | `universe.place:write` | S | 100/min | Sí | Bajo-medio |
| **Publicar place** (.rbxl/.rbxlx; `versionType=Saved|Published`) | `POST /universes/v1/{universeId}/places/{placeId}/versions` | `universe-places:write` | B | 30/min | **Sí** | **Alto en prod** → gate humano |
| Historial de versiones de place / notas | `GET /place-version-history-api/v1/{placeId}/history`, `POST .../version/{v}/notes` | `universe.place:read/write` | E | 120/min | Sí | Bajo |
| **Leer/editar instancias de un place publicado** (incl. `Script.Source` ≤200,000 bytes) | `GET/PATCH /cloud/v2/universes/{u}/places/{p}/instances/{id}`, `:listChildren` | `universe.place.instance:read/write` | B | 45/min | Sí | **Muy alto** (hotfix fuera de Git) → prohibido en prod salvo incidente aprobado |
| **Restart servers** (todos) | `POST /cloud/v2/universes/{u}:restartServers` | `universe:write` | S | 30/min | Sí | Alto (expulsa jugadores) |
| Restarts con estado y **forecast** de impacto | `POST/GET /server-management/v1/universes/{u}/restarts`, `GET .../restarts:forecast` | `universe:read/write` | B | 100/min | Sí | Alto |
| **Listar servidores por versión** | `GET /server-management/v1/universes/{u}/places/{p}/versions/{v}/game-servers` | `universe:read` | B | 100/min | Sí | Bajo |
| **Logs de un servidor de producción** (filtro CEL por severidad/tiempo/texto, 100/página) | `GET .../game-servers/{jobId}/logs` | `universe:read` | B | 100/min | **Sí** — observabilidad sin infraestructura propia | Bajo |
| Rollout de updates (launch/forecast/status), shutdown de instancias | `POST /matchmaking-api/v1/game-instances/{launch-update|forecast-update|shutdown|shutdown-all}`, `GET .../get-update-status` | (no declarado) | B | (no declarado) | Probable | **Semántica exacta por verificar** [INF] → spike antes de usar |
| Matchmaking scoring configs, atributos de jugador/servidor | `/matchmaking-api/v1/matchmaking/*` (29 ops) | (no declarado) | B | — | Sí | Medio |
| Activar/desactivar universe, Team Create | `/legacy-develop/v1/universes/{id}/activate|deactivate`, `.../teamcreate` | `legacy-universe:manage` | E | 100/min | Sí | Alto (desactivar = sacar juego) |

### 2.2 Datos

| Operación | Endpoint | Scope | Est. | Rate | Notas |
|---|---|---|---|---|---|
| Data stores v2: list/get/create/update/delete/increment entries, list revisions | `/cloud/v2/universes/{u}/data-stores/{ds}/entries[...]` (+ variante `/scopes/{scope}/`) | `universe-datastores.objects:*`, `.versions:list` | **S** | 1,000,000/min (owner) | **Además** se aplican los límites de throughput de la experiencia [INF] |
| Delete / **undelete** data store | `DELETE .../data-stores/{ds}`, `POST ...:undelete` | `universe-datastores.control:delete` | B | — | Borrado recuperable durante un periodo (ver doc) |
| **Snapshot de data stores** (backup lógico antes de migraciones) | `POST /cloud/v2/universes/{u}/data-stores:snapshot` | `universe-datastores.control:snapshot` | S | 60/min | Usar antes de cada release con migración de esquema |
| Data stores v1 (legacy) | `/datastores/v1/...` | `universe-datastores.*` | B | 5000/min | Preferir v2 |
| Ordered data stores v2 | `/cloud/v2/universes/{u}/ordered-data-stores/...` | `universe.ordered-data-store.scope.entry:*` | S | — | Leaderboards persistentes |
| Memory store: queues, sorted maps, **flush** | `/cloud/v2/universes/{u}/memory-store/...` | `memory-store.*` | S (flush op: B) | — | Flush = destructivo |
| **Secrets store** (API keys de terceros para el juego) | `/cloud/v2/universes/{u}/secrets[...]` | `universe.secret:read/write` | B | 120/min | Cifrado con public key del universe |

### 2.3 Ejecución de Luau headless

| Operación | Endpoint | Scope | Est. | Rate |
|---|---|---|---|---|
| Crear tarea (versión actual o **versión concreta** del place) | `POST /cloud/v2/universes/{u}/places/{p}[/versions/{v}]/luau-execution-session-tasks` | `universe.place.luau-execution-session:write` | S | **5/min** |
| Binary input (hasta subir objetos grandes; URL presignada 15 min) | `POST /cloud/v2/universes/{u}/luau-execution-session-task-binary-inputs` | idem | S | 5/min |
| Get task (estado, output) | `GET .../luau-execution-sessions/{sid}/tasks/{tid}` | `...:read` | S | — |
| Logs de la tarea | `GET .../tasks/{tid}/logs` | `...:read` | S | — |

Límites declarados en el schema [HV]: script ≤ **4 MB**, timeout por defecto y máximo **5 minutos**, valores de retorno ≤ **4 MB** tras
serialización JSON, logs retenidos ≤ **450 KB**, `binaryOutputUri` válida 15 min. Puede hacer `SavePlaceAsync` [HT, DevForum].
Límite de concurrencia por place (10) citado en DevForum [HT]. Contexto de ejecución: servidor sin jugadores reales [INFERENCIA → verificar en spike;
no hay `Players.LocalPlayer` ni cliente].

**Uso en la fábrica**: runner de **tests de engine** (Jest-Lua), smoke tests de arranque de servicios, validación de migraciones de datos contra
DataStores del universe de CI, generación procedural de mundo ("build scripts") guardada con `SavePlaceAsync` en places de trabajo.
Con 5 tareas/min por owner, **agrupar todos los tests en una sola tarea** por build.

### 2.4 Assets y Creator Store

| Operación | Endpoint | Scope | Est. | Rate |
|---|---|---|---|---|
| Crear/actualizar asset (imagen/decal, audio, modelo, mesh…), versiones, rollback, archive/restore | `/assets/v1/assets[...]` | `asset:read/write` | B | 120/min (create/update) |
| Permisos de assets (compartir con universe/grupo) | `PATCH /asset-permissions-api/v1/assets/permissions` | `asset-permissions:write` | B | 100/min |
| Cuotas de subida | `GET /cloud/v2/users/{id}/asset-quotas` | `asset:read` | B | 60/min |
| Creator Store products | `/cloud/v2/creator-store-products` | `creator-store-product:*` | B | 30/min |
| Toolbox search/saves | `/toolbox-service/v1|v2/...` | `creator-store-*:read` | B | — |
| Generate speech asset (TTS) | `POST /cloud/v2/universes/{u}:generateSpeechAsset` | `universe:write, asset:*` | B | 4/s |

Todo asset subido pasa **moderación** de Roblox (asíncrona): la API devuelve una operación; el asset puede ser rechazado [HV/INF].

### 2.5 Monetización y economía

| Operación | Endpoint | Scope | Est. | Rate | Gate |
|---|---|---|---|---|---|
| Game passes: create/list/get/**update (incluye precio)** | `/game-passes/v1/universes/{u}/game-passes[...]` | `game-pass:read/write` | B | 5/s write | **ECONOMY_CHANGE** |
| Developer products v2: create/list/get/update | `/developer-products/v2/universes/{u}/developer-products[...]` | `developer-product:read/write` | B | 3/s write | **ECONOMY_CHANGE** |
| Get subscription (de un usuario) | `GET /cloud/v2/universes/{u}/subscription-products/{sp}/subscriptions/{s}` | `universe.subscription-product.subscription:read` | B | 500/min | Lectura |
| Crear/editar productos de suscripción | — | — | — | — | **NO DISPONIBLE** (Creator Hub manual) |
| Price optimization / managed pricing | — | — | — | — | **NO DISPONIBLE** vía API (Creator Hub) |
| Inventario de usuario (ownership) | `GET /cloud/v2/users/{id}/inventory-items` | `user.inventory-item:read` | B | 100/min | Soporte/auditoría |
| Badges (crear, actualizar, icono) | `POST /legacy-badges/v1/universes/{u}/badges` (**scope `manage-and-spend-robux`**), `PATCH .../badges/{id}`, `POST /legacy-publish/v1/badges/{id}/icon` | E | 100/min | Crear badge puede costar Robux → gate |

### 2.6 Configs, experimentos, analytics, discovery

| Operación | Endpoint | Scope | Est. | Rate |
|---|---|---|---|---|
| **Configs**: get published, get/patch/overwrite/reset **draft**, **publish**, revisions, **restore** | `/creator-configs-public-api/v1/configs/universes/{u}/repositories/{repo}/...` | `universe:read/write` | B | publish 10/min |
| **Experiments**: list/create/update/discard/start/schedule/complete, **stats**, **calculateMde** | `/creator-configs-public-api/v1/experimentation/universes/{u}/experiments...` | `universe:read/write` | E | write 10/min |
| **Analytics Query**: métricas time-series y valores de dimensión (asíncrono: 202 + polling de operación) | `POST /analytics-query-api/v1/universes/{u}/metrics`, `.../dimension-values`, `GET .../operations/...` | `universe.analytics:read` | B | **30/min** |
| **Thumbnail personalization** (subir thumbnails de home, reglas de targeting) | `/thumbnail-personalization-api/v1/universes/{u}/...` | `universe.thumbnail:read/write` | E | 50/min write |
| **Experience Events** (crear/editar eventos LiveOps visibles en plataforma) | `/virtual-events/v3/...` | `universe.event:read/write` | E | 20/min write |
| **Notificaciones a usuarios** (experience notifications) | `POST /cloud/v2/users/{id}/notifications` | `user.user-notification:write` | S | 4000/s |
| Iconos y thumbnails de juego (legacy) | `/v1/game-icon`, `/v1/game-thumbnails` | legacy | E | — |

Analytics Query [HV `cloud/guides/analytics`]: granularidades OneMinute…OneMonth; breakdowns (Platform, Country, AgeGroup, IsNewUser, FunnelStep…);
429 con código 3000 = presupuesto de data points excedido; retención de 4 años (métricas estándar) y 28 días (performance).
Frescura observada por la comunidad: 5–13 h de retraso según métrica [HT, hilo del anuncio]. Existe un servidor MCP comunitario que
expone "168 métricas en 16 categorías" [HT, `michaeldougal/Roblox-MCP-Analytics`].

### 2.7 Publicidad

| Operación | Endpoint | Scope | Est. | Rate | Gate |
|---|---|---|---|---|---|
| **Ads Manager**: listar universes anunciables, billing accounts, campaign options, **crear/actualizar campañas**, creatives, estado | `/ads-management/v1/...` (10 ops) | `ad.campaign:read/write`, `ad.billing:read` | **E** | 60/min write | **SPEND_AD_BUDGET** siempre humano |
| Sponsored games / campaigns (web legacy) | `/v2/sponsored-*` | — | — | — | No usar (legacy, sin estabilidad declarada) |

### 2.8 Moderación y comunidad

| Operación | Endpoint | Scope | Est. | Rate |
|---|---|---|---|---|
| **User restrictions** (bans por universe/place, logs) | `/cloud/v2/universes/{u}[/places/{p}]/user-restrictions[...]` | `universe.user-restriction:read/write` | B | 150/s |
| Grupos: miembros, roles, join requests, foros | `/cloud/v2/groups/{g}/...` | `group:*`, `group-forum:read` | B | 150–300/min |
| Traducción de texto | `POST /cloud/v2/universes/{u}:translateText` | `universe:write` | B | 10,000/min |
| Localization tables / auto-localization (legacy) | `/legacy-localization-tables/v1/...` | `legacy-universe:manage` | E | 100/min |

### 2.9 APIs web públicas documentadas (lectura de juegos de terceros)

El mismo OpenAPI oficial documenta dominios web "clásicos" (`games.roblox.com`, `thumbnails.roblox.com`, `develop.roblox.com`…). Algunas operaciones
admiten **acceso anónimo** (`security: [{}]` o cookie legacy) [HV]:

| Operación | Endpoint | Est. | Datos | Uso |
|---|---|---|---|---|
| Detalle de juegos (multi) | `GET https://games.roblox.com/v1/games?universeIds=…` | E | nombre, descripción, creador, **playing (CCU)**, **visits**, **favoritedCount**, created, updated, maxPlayers, price, `universeAvatarType`, **`genre_l1`/`genre_l2`** (taxonomía oficial de géneros), `isContentRestricted`, `creationSource` (campos del schema `GameDetailResponse`) | **Fuente principal del Trend Engine** |
| Votos (multi) | `GET https://games.roblox.com/v1/games/votes?universeIds=…` | — | up/down votes | Rating |
| Favoritos | `GET https://games.roblox.com/v1/games/{universeId}/favorites/count` | E | favoritos | Redundante con /v1/games |
| Juegos similares | `GET https://games.roblox.com/v1/games/recommendations/game/{universeId}` | E | lista de universes relacionados | Grafo de similitud / competidores |
| Media | `GET https://games.roblox.com/v2/games/{universeId}/media` | E | imágenes/vídeos | Análisis de creatives |
| Iconos/thumbnails (multi) | `GET https://thumbnails.roblox.com/v1/games/icons`, `/v1/games/multiget/thumbnails` | **S** | URLs de imágenes | Análisis visual (features, no copia) |
| Info de producto (paid access) | `GET https://games.roblox.com/v1/games/games-product-info` | E | precio de acceso | Señal de monetización |

No documentadas en el OpenAPI oficial (⇒ **no oficiales**): endpoints de *sorts/charts* de la home y Discover (p.ej. `explore-api`), búsqueda de juegos,
lista de game passes de un juego de terceros. Ver tratamiento legal en `07_TREND_INTELLIGENCE.md` §2 y ⛔ STOP-01.

## 3. Capacidades de la fábrica ejecutables vía Open Cloud

| Acción de fábrica | Vía | Viable hoy | Nivel de permiso |
|---|---|---|---|
| Publicar build a CI/staging | Place publishing | **Sí** | WRITE_CLOUD / PUBLISH_STAGING |
| Publicar a producción | Place publishing (`Published`) | **Sí** (técnicamente) | PUBLISH_PRODUCTION (humano) |
| Ejecutar tests de engine en CI | Luau Execution | **Sí** | RUN_TESTS |
| Backups antes de migraciones | `data-stores:snapshot` | **Sí** | WRITE_CLOUD |
| Soporte: leer/corregir datos de un jugador | Data stores v2 | **Sí** | READ / WRITE_CLOUD (prod: humano) |
| Kill-switch / flags en vivo | Configs publish + MessagingService | **Sí** | WRITE_CLOUD (flags de seguridad) / ECONOMY_CHANGE (flags económicos) |
| A/B tests | Experiments API (E) | **Sí** (experimental) | WRITE_CLOUD con aprobación de diseño |
| Leer métricas | Analytics Query (B) | **Sí** | READ |
| Leer errores de producción | Server logs (B) | **Sí** | READ |
| Crear/editar passes y dev products, precios | APIs (B) | **Sí** | ECONOMY_CHANGE (humano) |
| Suscripciones, price optimization, questionnaire de madurez, elegibilidad de ads, Creator Rewards | — | **NO DISPONIBLE** vía API | Humano en Creator Hub |
| Campañas de ads | Ads Management (E) | **Sí** (experimental) | SPEND_AD_BUDGET (humano) |
| Subir thumbnails/iconos | Thumbnail personalization (E), legacy icon | **Sí** | WRITE_CLOUD + policy scan |
| Notificar jugadores / crear eventos | Notifications (S), Events (E) | **Sí** | WRITE_CLOUD (LiveOps, con plantilla aprobada) |
| Banear exploiters | User restrictions (B) | **Sí** | WRITE_CLOUD (con evidencia; revisión humana en bans permanentes) |
| Trend data de otros juegos | — | **NO en Open Cloud** (sólo tus universes) | Ver `07_TREND_INTELLIGENCE.md` |

## 4. Viabilidad de las herramientas `roblox.*` propuestas en el brief

| Tool propuesta | Veredicto | Mapeo |
|---|---|---|
| `roblox.publish_place` | **VIABLE** | `POST /universes/v1/{u}/places/{p}/versions` |
| `roblox.publish_universe` | **NO EXISTE como operación única**. Un universe se "publica" publicando sus places + `PATCH` de universe (visibilidad) | compuesta |
| `roblox.read_datastore` / `write_datastore` | **VIABLE** | data stores v2 |
| `roblox.get_universe` / `get_places` | **VIABLE** (`GET` universe/place; listar places de un universe: vía web API legacy `/v1/universes/{id}/places` [INF: presente en OpenAPI bajo `/v1/universes` sin estabilidad declarada]) | |
| `roblox.get_metrics` | **VIABLE** (beta) | Analytics Query |
| `roblox.get_assets` | **VIABLE** para assets propios (`GET /assets/v1/assets/{id}`, versiones); búsqueda en Creator Store vía toolbox-service | |

## 5. Riesgos específicos de dependencia de API

- **189 de 228** operaciones relevantes (~83%) son BETA (129) o EXPERIMENTAL (60); sólo 39 son STABLE [HV: recuento sobre `docs/data/open-cloud-endpoints.txt`]. El cliente propio debe aislar cada familia
  detrás de un adaptador con tests de contrato (llamadas reales contra el universe de CI, semanales).
- Roblox anunció "soporte MCP nativo" para estas APIs como plan futuro [HV, anuncio 2026-08-24]. Si llega, el `roblox-cloud-mcp` propio debe
  degradarse a **capa de políticas** encima del oficial (ver DEC-003).
