# 15 — Discovery, Creative Optimization y Adquisición

## 1. Discovery (§30): documentado · observado · inferido · rumor

**Fuente primaria**: `create.roblox.com/docs/discovery` (actualizada 2026-09-25) [HV].

### 1.1 Documentado [HECHO VERIFICADO]

- **Home – Recommended for You**: dos etapas, *retrieval* (usa señales de engagement, retención y monetización) y *ranking* (personalizado).
  Las señales **sólo se miden sobre usuarios adquiridos orgánicamente desde Recommended for You**; tráfico de ads, curación, búsqueda o amigos **no cuenta** para el ranking.
- **Señales "most important"**: Play Through Rate (jugar tras ver el juego en el sort), First Play Bounce Rate (<60 s y 61–180 s; negativa),
  Play Days per User (D1, D2–7, D8–28), Playtime per User (tope 60 min/día por usuario).
- **Señales "important"**: Intentional Co-Play Days (volver con amigos), Qualified Play Sessions, Spend Days per User, Robux Spent per User.
- Ventana de evaluación extendida a **28 días** (antes 7) y QPTR sustituido por PTR + bounce [HT resumen de anuncios; coherente con la doc].
- **Otras superficies**: Continue Playing, Friends, **Sponsored** (Ads Manager), Curated sorts, **Standout Games** (curación humana de novedad mecánica/visual),
  Live Events, **Search** (semántica, lenguaje natural), **Discover/Charts** (top y trending por género), Experience Events (hasta 5 thumbnails promocionales),
  Experience Notifications.
- **Penalizaciones**: metadata irrelevante o engañosa, liderar con giveaways, **juegos no-únicos que se parecen a títulos existentes**, thumbnails engañosos con
  thumbnail personalization. Existe un **banner de "quality status"** diario en el dashboard si hay problemas de exposición.
- **Thumbnail personalization**: varios thumbnails con reglas de targeting por segmento (API EXPERIMENTAL) [HV OpenAPI].
- **Search ads**: subasta de segunda precio + relevancia; audiencia 13+ todas las regiones; objetivo "Visits" [HV `search-ads.md`].
- **Genre**: cambiable cada 3 meses; Roblox corrige géneros inexactos; alimenta sorts por género en Charts [HV `experience-genres.md`].

### 1.2 Observado (comunidad, sin garantía)

- Picos de tráfico tras updates con evento + notificación a seguidores [HT, patrones de DevForum].
- Juegos con fuerte co-play crecen más rápido vía Friends/Continue Playing [HT].

### 1.3 Inferido

- Como el ranking usa sólo tráfico orgánico de RfY, **ads no "compran" ranking directamente**, pero sí generan jugadores que pueden volver con amigos
  (co-play) y usuarios que luego llegan orgánicamente [INFERENCIA].
- El soft launch 16+ y la evaluación para all-ages (2026-05) hacen que las **primeras semanas con adultos jóvenes** sean determinantes para la trayectoria [INFERENCIA].
- Optimizar thumbnail para CTR sin retención es contraproducente (bounce es señal negativa explícita).

### 1.4 Rumor (no usar para decisiones)

- "Algoritmo secreto" que premia actualizaciones semanales per se, número de favoritos, o nombre con emojis/mayúsculas. **No documentado.**

## 2. Implicaciones de diseño (ingeniería de discovery legítima)

| Señal | Palanca de producto |
|---|---|
| Play Through Rate | Icono/thumbnail/título claros y **veraces**; promesa = lo que se juega en el minuto 1 |
| First-play bounce <60 s | Primera recompensa < 30–60 s; carga rápida en móvil gama baja; sin muros de UI |
| Play days D2–7 / D8–28 | Hábito diario (daily rewards, objetivos multi-día, eventos), progresión con horizonte ≥ 4 semanas |
| Playtime/user (tope 60 min) | Sesiones de 15–40 min con puntos de parada naturales; no inflar artificialmente |
| Co-play days | Co-op nativo, parties, recompensas por jugar con amigos, referral system (`GetJoinData().ReferredByPlayerId`) [HV] |
| Spend days / Robux per user | Ofertas de valor diario pequeñas; suscripción/battle pass |

## 3. Creative optimization (§31)

| Elemento | Herramienta oficial | Automatización |
|---|---|---|
| Icono | Creator Hub / legacy icon API (E) | Generación de variantes A1; subida A2 |
| Thumbnails (home) | **Thumbnail personalization** (targeting por segmento) + dashboard (métrica `ThumbnailWinningSegments` en Analytics Query [HV]) | Variantes A1–A2; experimentación nativa A3 una vez aprobado el set |
| Título / descripción | Universe PATCH (S) | Borradores A1; cambios A2 (policy scan de metadata) |
| Screenshots / trailer | Media del juego | A1 (captura automática de escenas vía Studio MCP + edición humana) |
| Localización de metadata | Traducción automática + revisión | A3 con muestreo |

**Sistema de creative variants** [DEC-022]:

1. **Brief** desde el GDD (fantasía, verbo principal, diferenciador) → 6–10 conceptos de thumbnail (texto+composición).
2. **Producción**: capturas reales del juego (Studio MCP `screen_capture` en escenas preparadas) como base + composición/retoque (humano o IA sobre **arte propio**).
   Regla: **nada de arte de terceros ni personajes/IP ajenas**; nada que muestre contenido inexistente en el juego.
3. **Pre-evaluación**: modelo de visión puntúa legibilidad a 150 px, contraste, foco, coherencia con gameplay; policy scan (texto, logos, IP).
4. **Test real**: thumbnail personalization / experimentos nativos, métrica primaria **PTR** con guardrail **bounce <60 s** y **D1** (evitar clickbait).
5. **Decisión y KB**: patrón ganador + contexto (género, audiencia) → `knowledge/creative/`.

## 4. Adquisición (UA)

- **Ads Manager**: campañas con objetivo (p. ej. Visits), presupuesto, audiencia (salvo search ads), creatives; pago con tarjeta (18+) o **ad credits
  convertidos desde Robux (irreversible; primero se convierten Robux ganados a tasa US 18+)** [HV `ads-manager.md`]. Subasta de segundo precio [HV].
- **API**: `ads-management/v1` (EXPERIMENTAL) permite crear/actualizar campañas [HV] → la fábrica la usa sólo para **lectura/reporting** y para
  preparar borradores; activar/aumentar gasto = `SPEND_AD_BUDGET` humano.
- **Uso recomendado**: *tests de retención pagados* en soft launch (comprar 2–5k usuarios para medir D1/D7 con muestra suficiente) y escalado en G6 sólo con LTV > CAC.
- **Orgánico**: share links + Audience Expansion Rewards (35% de las primeras $100 de usuarios nuevos/reactivados) [HV], referral system, notificaciones,
  Experience Events, creators de YouTube/TikTok (Video Stars program existe para influencers [HV `creator-rewards.md`]).
- **Conversión de Robux ganados a ad credits** es una decisión financiera: convertir Robux que valdrían $0.0054 (US 18+) o $0.0038 en DevEx; evaluar ROAS
  contra ese coste de oportunidad [INFERENCIA].
