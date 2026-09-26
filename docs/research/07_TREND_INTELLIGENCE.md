# 07 — Roblox Trend Intelligence Engine

> Objetivo: detectar oportunidades **antes** de construir, con datos legítimamente accesibles, y producir features para el Opportunity Engine.
> Regla: **medir lo observable, estimar con supuestos explícitos, y marcar lo no observable**.

## 1. Qué podemos medir realmente

| Dato | Observable | Fuente | Calidad |
|---|---|---|---|
| CCU actual por juego (`playing`) | **Sí** | `games.roblox.com/v1/games` (documentado, anónimo, EXPERIMENTAL) [HV] | Alta (instantáneo) |
| Visitas acumuladas (`visits`) | **Sí** | idem | Alta; delta diario = proxy de "visitas/día" |
| Favoritos (`favoritedCount`) | **Sí** | idem | Alta |
| Up/down votes | **Sí** | `games.roblox.com/v1/games/votes` [HV] | Alta |
| Fecha de creación / última actualización | **Sí** (`created`, `updated`) | `/v1/games` | `updated` cambia con cualquier publicación → proxy de cadencia |
| Género / subgénero oficiales | **Sí** (`genre_l1`, `genre_l2`) | `/v1/games` [HV] + taxonomía oficial `experience-genres.md` | Media (autodeclarado; Roblox corrige los inexactos [HV]) |
| Creador (usuario/grupo), max players, avatar type, precio de acceso, `isContentRestricted` | **Sí** | `/v1/games` | Alta |
| Juegos similares (grafo) | **Sí** | `/v1/games/recommendations/game/{universeId}` [HV] | Media (personalización desconocida) |
| Icono, thumbnails, media | **Sí** | `thumbnails.roblox.com` (STABLE), `/v2/games/{id}/media` [HV] | Alta |
| Nombre/descripción (y cambios en el tiempo) | **Sí** | `/v1/games` + historial propio de snapshots | Alta |
| Posición en Charts / Home sorts / Search rank | **Sólo vía endpoints no documentados** o inspección manual | ⛔ STOP-01 | — |
| Game passes de terceros y precios | **No vía API documentada** (sólo thumbnails por ID) | Página del juego (manual) | — |
| Developer products de terceros | **No observable** (se ven sólo in-game) | — | — |
| DAU, retención, sesión, ingresos de terceros | **NO OBSERVABLE** | Estimaciones de terceros (RoMonitor) no verificables | Baja |
| Eventos (Experience Events) de terceros | Parcial (página del juego) | — | — |
| Señales sociales (vídeos, streams, posts) | **Sí** con APIs oficiales de cada plataforma | YouTube Data API, Twitch Helix, Reddit API | Media |
| Búsquedas web | Parcial | Google Trends (sin API oficial GA; ver DATA-SOURCES) | Media-baja |

## 2. Fuentes y legalidad (resumen; detalle en `inventories/DATA-SOURCES.md`)

**fuente → dato → ToS → coste → frecuencia → utilidad**

| Fuente | Dato | Legalidad/ToS | Coste | Frecuencia | Utilidad |
|---|---|---|---|---|---|
| `games.roblox.com/v1/games` (+votes, recommendations) | CCU, visitas, favs, votos, género, fechas | Documentado por Roblox en su referencia oficial; acceso anónimo. Uso comercial automatizado **no explícitamente autorizado** ⇒ bajo volumen, caché, UA identificable | 0 | Horaria (CCU), diaria (resto) | **Muy alta** |
| `thumbnails.roblox.com` | Iconos/thumbnails | Idem (STABLE) | 0 | Diaria / on-change | Alta (creative analysis) |
| Explore/Charts/Search endpoints de la web | Rankings de sorts | **No documentados** → riesgo ToS ⇒ ⛔ STOP-01 | 0 | — | Alta |
| Roblox Charts (web, humano) | Top/Trending por género | Uso manual permitido | Horas humanas | Semanal | Media (seed de IDs) |
| RoMonitor Stats | Históricos CCU/visitas, estimaciones | Web/extensión; **no hay API pública documentada** [HT] → uso manual o acuerdo comercial | 0 / acuerdo | Manual | Media |
| Rolimon's | Principalmente limiteds/trading; lista de juegos | Sin API de juegos verificada [INF] | 0 | Manual | Baja para juegos |
| YouTube Data API v3 | Vídeos, vistas, títulos por keyword/juego | Oficial; ToS de YouTube API | Gratis (cuota por defecto 10,000 unidades/día; `search.list`=100 u) [HT] | Diaria | Alta (demanda/viralidad) |
| Twitch Helix | Streams, viewers, títulos | Oficial | Gratis | Horaria | Baja-media (Roblox es una sola categoría) |
| Reddit Data API | Posts/comentarios en subreddits Roblox | Oficial; términos comerciales de Reddit | Gratis/limitado; comercial de pago [HT] | Diaria | Media |
| TikTok | Tendencias de hashtags/sonidos | Research API sólo académica [HT] → **no disponible**; Creative Center manual | — | Manual | Media |
| X (Twitter) API | Menciones | De pago [HT] | $$ | — | Baja/coste alto → **no** |
| Discord | — | Sólo servidores propios con bot; **no** scraping de servidores ajenos | — | — | Comunidad propia |
| Google Trends | Interés de búsqueda relativo | Sin API GA (API alpha anunciada 2025 [HT]); uso manual o librerías no oficiales (riesgo) | 0 | Semanal | Baja-media |

**⛔ STOP-01 — decisión humana/legal requerida**: (a) si el uso automatizado de endpoints **documentados pero no-Open-Cloud** de Roblox para inteligencia
de mercado comercial es aceptable (propuesta: sí, a ≤1 req/s, con caché y sin autenticación de usuario); (b) si se permite usar endpoints
**no documentados** de sorts/charts (propuesta: **no**; seed de IDs mediante grafo de recomendaciones + revisión humana semanal de Charts).
Hasta resolverlo, el Trend Engine funciona **sólo** con endpoints documentados.

## 3. Descubrimiento del universo de juegos a seguir (sin endpoints no documentados)

1. **Seeds**: lista manual semanal (humano, 15 min) de Charts por género + juegos mencionados en YouTube/Reddit (extracción de nombres → búsqueda manual del universeId o desde URLs de juego en descripciones de vídeos, que contienen placeId → universe vía `develop`/`games` endpoints).
2. **Expansión por grafo**: BFS sobre `/v1/games/recommendations/game/{id}` desde seeds, profundidad ≤2, filtrando CCU ≥ 50.
3. **Tracked set**: ~2,000–5,000 universes [EST]; tiers: T1 (CCU≥1k, snapshot horario), T2 (100–1k, cada 3 h), T3 (<100, diario; purga tras 30 días sin crecer).
4. Volumen [EST]: si `/v1/games` acepta ~50 IDs por petición [HT, límite a verificar], 5,000 juegos/hora ≈ 100 peticiones/hora — trivial.

## 4. Trend Database — esquema

```sql
-- Entidades
create table experience (
  universe_id bigint primary key, root_place_id bigint, name text, creator_id bigint, creator_type text,
  created_at timestamptz, genre_l1 text, genre_l2 text, avatar_type text, max_players int,
  first_seen_at timestamptz, tracking_tier smallint, is_tracked boolean default true
);
create table developer (creator_id bigint, creator_type text, name text, verified boolean, primary key (creator_id, creator_type));

-- Series temporales (particionar por mes; TimescaleDB opcional)
create table experience_snapshot (
  universe_id bigint references experience, ts timestamptz,
  ccu int, visits bigint, favorites bigint, up_votes bigint, down_votes bigint, updated_at timestamptz,
  name_hash text, description_hash text, icon_asset_hash text, primary key (universe_id, ts)
);
create table experience_daily (  -- agregado diario (job)
  universe_id bigint, day date, ccu_peak int, ccu_avg real, visits_delta bigint, favorites_delta bigint,
  rating real, updated_count int, primary key (universe_id, day)
);

-- Metadata y creatividad
create table metadata_change (universe_id bigint, ts timestamptz, field text, old_value text, new_value text);
create table thumbnail_features (universe_id bigint, asset_hash text, captured_at timestamptz,
  palette jsonb, has_character boolean, has_text boolean, text_ocr text, style_tags text[], embedding vector(768));

-- Clasificación (tema / mecánica / meta-loop)
create table taxonomy_term (id serial primary key, kind text check (kind in ('theme','mechanic','meta_loop','social')), name text, parent_id int);
create table experience_classification (universe_id bigint, term_id int, confidence real, source text, -- 'official_genre'|'llm_text'|'vision'|'human'
  classified_at timestamptz, model_version text, primary key (universe_id, term_id, source));

-- Señales sociales
create table social_mention (id bigserial primary key, platform text, external_id text, universe_id bigint null,
  keyword text, published_at timestamptz, views bigint, engagement bigint, captured_at timestamptz);

-- Features y scores (versionados)
create table trend_features (universe_id bigint, day date, r7 real, r28 real, accel real, momentum real, z_anom real,
  rel_genre real, age_days int, update_freq_30d real, fav_per_kvisit real, like_ratio real, primary key (universe_id, day));
create table trend_state (universe_id bigint, day date, state text, -- exploding|growing|stable|declining|reviving|new
  score real, model_version text, primary key (universe_id, day));
create table cluster (id serial primary key, day date, mechanic_term int, theme_term int, n_games int,
  n_new_30d int, ccu_sum int, r7_weighted real, clone_wave boolean, novel boolean);
create table opportunity (id serial primary key, created_at timestamptz, cluster_id int, thesis text,
  opportunity_score real, components jsonb, uncertainty real, status text, model_version text);
```

Campos del brief **no medibles** y por tanto **excluidos**: `MonetizationSignals` de terceros más allá de precio de acceso y private servers
(marcar como manual), `SearchRank` (⛔ STOP-01), DAU/retención de terceros (no observable).

## 5. Detección de crecimiento — fórmulas

Notación: `C_d` = CCU medio diario (media de snapshots del día), `V_d` = visitas del día (Δ del contador), `MA7(x)` = media móvil 7 días,
`k` = pseudo-conteo para estabilizar bases pequeñas (k = 50 CCU; k_V = 1,000 visitas).

| Medida | Fórmula | Uso |
|---|---|---|
| Crecimiento absoluto 7d | `ΔC7 = MA7(C)_t − MA7(C)_{t−7}` | Tamaño del movimiento |
| Crecimiento relativo 7d (log) | `r7 = ln((MA7(C)_t + k) / (MA7(C)_{t−7} + k))` | Comparable entre tamaños; r7=0.69 ≈ ×2 |
| Crecimiento 28d | `r28 = ln((MA7(C)_t + k)/(MA7(C)_{t−28} + k))` | Tendencia |
| Aceleración | `a = r7_t − r7_{t−7}` | Explosión incipiente vs madurez |
| Momentum | `m_t = EWMA(r1, half-life 7d)`, con `r1 = ln((C_t+k)/(C_{t−1}+k))` | Suavizado |
| Anomalía | `z = (ln(C_t+k) − median_28) / (1.4826·MAD_28)` sobre residuos desestacionalizados (día de semana) | Picos (updates, virales, eventos) |
| Relativo a categoría | `rel = r7 − median_w(r7 | genre_l2 o cluster)` (mediana ponderada por CCU) | Separa juego vs marea del género |
| Cohorte por edad | `r7` vs percentil en cohorte de edad (`age_days` en buckets 0–30, 31–90, 91–365, >365) | Juegos nuevos vs veteranos |
| Engagement proxy | `fav_per_kvisit = ΔFav_7 / (ΔV_7/1000)`; `like_ratio = up/(up+down)` | Calidad percibida |
| Estacionalidad | Descomposición STL semanal sobre `ln(C)` | Evitar falsos positivos de fin de semana |

**Estados** (umbrales = **[HIPÓTESIS]** a calibrar por backtesting sobre 90 días de histórico; ver §7):

| Estado | Regla inicial |
|---|---|
| EXPLODING | `r7 ≥ 0.69` ∧ `a > 0` ∧ `MA7(C) ≥ 500` ∧ `z ≥ 3` |
| GROWING | `r7 ≥ 0.18` (≈+20% s/s) ∧ `r28 > 0` |
| STABLE | `|r28| < 0.10` |
| DECLINING | `r28 ≤ −0.30` |
| REVIVING | `r7 ≥ 0.30` ∧ `r28_{t−7} ≤ −0.30` ∧ `age_days > 180` |
| NEW_ENTRANT | `age_days ≤ 30` ∧ `MA7(C) ≥ 200` |

**Nivel de cluster** (mecánica×tema): `clone_wave` si `n_new_30d ≥ 5` juegos nuevos con `MA7(C) ≥ 100` y `r7_weighted > 0` ⇒ señal de
saturación inminente (entrar tarde); `novel` si el cluster no existía hace 60 días y suma `CCU ≥ 5,000` ⇒ categoría nueva.

## 6. Detección de mecánicas: tema vs mecánica vs meta-loop

Tres ejes independientes (un juego tiene 1..n de cada):

- **Tema** (fantasy/skin): anime, mascotas, terror, memes, supervivencia, coches, fantasía, espacio…
- **Mecánica** (verbos del core loop): mapeada a la **taxonomía oficial** de géneros/subgéneros (p. ej. Simulation→{Idle, Incremental Simulator,
  Physics Sim, Sandbox, Tycoon, Vehicle Sim}; Strategy→{Board & Card, Tower Defense}; Obby & platformer→{Classic, Runner, Tower}; Survival→{1 vs All, Escape};
  Roleplay & avatar sim→{Animal Sim, Dress Up, Life, Morph Roleplay, Pet Care}; Party & casual; Puzzle; RPG; Shooter; Action; Adventure; Sports & racing;
  Social; Shopping; Education; Entertainment; Utility) [HV `experience-genres.md`] + extensiones propias: RNG/rolling, collection, extraction, merge, rhythm…
- **Meta-loop**: estructura de progresión (`play→earn→upgrade→unlock→prestige→repeat`, `collect→complete set`, `roll→rarity chase`, `survive→extract→stash`,
  `build→showcase→social`).

**Pipeline de clasificación** [DEC]:

1. `genre_l1/genre_l2` oficiales → mecánica base (confianza media; autodeclarado).
2. **LLM sobre texto** (nombre, descripción, títulos de vídeos asociados) con salida estructurada contra la taxonomía; modelo barato en batch
   (Haiku 4.5, Batch API −50%) [EST coste: ~1–2k tokens/juego ⇒ 5,000 juegos ≈ 10M tokens ≈ $5–10 por pasada completa en batch].
3. **Visión** sobre icono + 3 thumbnails → tema, estilo, presencia de personaje/texto (features, **no** para reproducir).
4. **Human-in-the-loop**: muestreo del 5% semanal + todos los juegos EXPLODING → etiqueta humana (ground truth para medir precisión).
5. Métrica de calidad: precisión/recall por eje sobre el ground truth; objetivo ≥0.8 en mecánica antes de usar para scoring automático.

Observación de gameplay real (entrar en juegos de terceros) **no se automatiza** (bots en juegos ajenos = ToS); se hace con playtest humano
guiado por una plantilla de análisis (30–45 min por juego relevante).

## 7. Validación del motor (evitar autoengaño)

- **Backtest**: con 90+ días de snapshots, ¿los estados EXPLODING/GROWING en t predicen CCU en t+28? Medir precisión@k y lift vs baseline "top CCU".
- **Predicción de oportunidad ≠ predicción de crecimiento de terceros**: lo que importa es si *nuestros* juegos en clusters señalados rinden mejor
  (medible sólo tras varios lanzamientos) ⇒ el Opportunity Engine arranca con pesos a priori y se recalibra (ver `08_OPPORTUNITY_ENGINE.md` §3).
- **Sesgo de supervivencia**: incluir juegos que murieron (tracked set con purga lenta, no borrar histórico).
- **Latencia**: una tendencia visible en CCU ya lleva días de ventaja a quien la creó; el valor está en detectar **clusters jóvenes con aceleración**
  y **necesidades no servidas** (alta demanda social + baja calidad de oferta: `like_ratio` bajo con CCU alto), no en clonar el top.

## 8. Implementación

`factory/trends/`: `collector.py` (cliente con rate limit ≤1 req/s, retries, caché ETag), `aggregate.py`, `features.py`, `states.py`,
`classify.py` (LLM batch), `clusters.py`, `alerts.py` (→ GitHub Issue/digest semanal). Postgres (+pgvector). Cron en un VPS pequeño
o GitHub Actions schedule (límite: jobs ≤6 h, OK). Coste [EST]: < $30/mes infra + ~$20–40/mes LLM.
