# REALITY MATRIX (§96) — a 2026-09-26

| Capability | Possible Today | Official | Automatable | Reliable | Human Required |
|---|---:|---:|---:|---:|---:|
| Market research (datos públicos de juegos) | Sí | Parcial (endpoints documentados, no Open Cloud) | Sí (A4 recolección) | Media | Decisiones y STOP-01 |
| Trend detection (CCU, visitas, crecimiento) | Sí | Parcial | Sí | Media (lag, sin rankings) | Seeds semanales |
| Datos de competidores: DAU, retención, ingresos | **No** | No | No | — | — |
| Concept generation | Sí | n/a | Sí (A3) | Media (tiende a la media) | Sí (elección) |
| GDD | Sí | n/a | Sí (A2) | Media-alta | Aprobación |
| Coding (Luau) | Sí | n/a | Sí (A3) | Alta con SDK+CI+review | Revisión de núcleo |
| Studio editing (instancias, scripts, blockouts) | Sí | **Sí** (Studio MCP) | Sí (A3) en Win/macOS | Media | Supervisión |
| Build headless | Sí | OSS (Rojo) | Sí (A4) | Alta | No |
| Unit tests | Sí | OSS (Lune) | Sí (A4) | Alta | No |
| Engine tests headless | Sí | **Sí** (Luau Execution) | Sí (A4) | Alta (5/min) | No |
| Playtesting automatizado (cliente, input, capturas) | Sí | **Sí** (Studio MCP, experimental) | Parcial (A3) | Media-baja | Supervisión |
| Playtesting de diversión | Sí | n/a | **No** | — | **Sí** |
| Visual testing | Parcial | Parcial (`screen_capture`) | Sí (detección) | Media | Juicio estético |
| Multiplayer testing | Sí (Studio local server/Team Test) | Sí (manual) | **No** headless | — | **Sí** |
| Device testing | Sí | n/a | No | — | **Sí** |
| Security audit | Sí | n/a | Sí (A3) | Media-alta | Hallazgos altos |
| Policy compliance | Parcial | Cuestionario oficial (manual) | Parcial (A3 scan) | Media (no certifica) | **Envío del cuestionario** |
| Publishing (staging/prod) | Sí | **Sí** (place publishing API) | Sí (A3 staging / A2 prod) | Alta | Aprobación prod |
| Creación de universes | Sí | Creator Hub | **No** (sin endpoint) | — | **Sí** |
| Analytics | Sí | **Sí** (dashboard + Query API beta) | Sí (A4) | Alta (lag 5–13 h) | No |
| Server error monitoring | Sí | **Sí** (server logs API beta) | Sí (A4) | Media-alta | No |
| Remote config / flags | Sí | **Sí** (Configs) | Sí (A3) | Alta | Económicos |
| A/B testing | Sí | **Sí** (Experiments; API experimental) | Sí (A2/A3) | Alta (con volumen) | Lanzamiento |
| Monetization changes (passes/products/precios) | Sí | **Sí** (APIs beta) | Sí técnicamente | Alta | **Sí** (A2) |
| Suscripciones / price optimization | Sí | Creator Hub | **No** vía API | — | **Sí** |
| Advertising | Sí | **Sí** (Ads Manager; API experimental) | Técnicamente sí | Media | **Sí** (gasto) |
| LiveOps (contenido pre-aprobado) | Sí | Sí (configs, events, notifications) | Sí (A3) | Alta | Contenido nuevo/económico |
| Asset generation 2D | Sí | Mixto | Sí (A2) | Media | Curación |
| Asset generation 3D props | Sí | **Sí** (generate_mesh/Cube) | Sí (A2) | Media-baja | Curación |
| Personajes/animación/música | Parcial | — | No fiable | Baja | **Sí** |
| Localización | Sí | **Sí** (translateText beta, auto-translation) | Sí (A3) | Media-alta | Tienda/metadata |
| Performance optimization | Sí | Parcial (métricas oficiales) | Parcial (A3 servidor) | Media | Perfilado cliente |
| Incident response | Sí | Sí (flags, restarts, rollback) | Parcial (A3 flags) | Media-alta | Rollback/restart |
| Community management | Sí | — | **No** seguro | — | **Sí** |
| Juzgar "¿volverán los jugadores?" antes de lanzar | **No** | — | No | — | Humanos + datos de soft launch |

**Dónde termina la automatización (resumen)**: todo lo server-side y cloud es A3–A4; el cliente en Studio es A3 experimental; multi-cliente, dispositivos reales,
diversión, arte clave, comunidad, gasto, precios, lanzamiento a producción y compliance final requieren humanos.
