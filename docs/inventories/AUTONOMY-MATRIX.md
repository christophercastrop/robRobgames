# AUTONOMY-MATRIX

Niveles: **A0** manual · **A1** AI recomienda · **A2** AI ejecuta con aprobación · **A3** AI ejecuta automáticamente dentro de límites · **A4** autónoma con supervisión por excepción.
"✔" = técnicamente posible hoy; "—" = no aplicable o no seguro. **Recommended** = nivel seguro recomendado a 2026-09.

| Activity | A0 | A1 | A2 | A3 | A4 | Recommended |
|---|---|---|---|---|---|---|
| Recolección de datos de trends (endpoints documentados) | ✔ | ✔ | ✔ | ✔ | ✔ | **A4** |
| Uso de endpoints no documentados (sorts) | ✔ | — | — | — | — | **A0** (⛔ STOP-01) |
| Clasificación de juegos (tema/mecánica) | ✔ | ✔ | ✔ | ✔ | ✔ | **A3** (muestreo humano 5%) |
| Scoring de oportunidades | ✔ | ✔ | ✔ | ✔ | — | **A3** score / **A1** recomendación |
| Aprobar prototipo (G0/G1) | ✔ | ✔ | — | — | — | **A1** (humano decide) |
| Generar conceptos | ✔ | ✔ | ✔ | ✔ | — | **A3** (humano elige) |
| GDD | ✔ | ✔ | ✔ | ✔ | — | **A2** (aprobación de GDD) |
| Diseño de economía + simulación | ✔ | ✔ | ✔ | ✔ | — | **A2** |
| Arquitectura técnica | ✔ | ✔ | ✔ | ✔ | — | **A2** |
| Implementación de WPs | ✔ | ✔ | ✔ | ✔ | ✔ | **A3** (merge tras CI + Reviewer) |
| Cambios en SDK núcleo (Economy, Products, PlayerData) | ✔ | ✔ | ✔ | — | — | **A2** |
| Edición en Studio (vía MCP) | ✔ | ✔ | ✔ | ✔ | — | **A3** en places de dev |
| Tests unit/engine/sim | ✔ | ✔ | ✔ | ✔ | ✔ | **A4** |
| Playtest automatizado (Studio MCP) | ✔ | ✔ | ✔ | ✔ | — | **A3** (experimental) |
| Playtest humano ("¿es divertido?") | ✔ | ✔ | — | — | — | **A0/A1** |
| Visual QA | ✔ | ✔ | ✔ | ✔ | — | **A3** detección / **A1** juicio estético |
| Multiplayer testing | ✔ | ✔ | — | — | — | **A1** |
| Security audit | ✔ | ✔ | ✔ | ✔ | — | **A3** (bloqueo automático) |
| Policy scan | ✔ | ✔ | ✔ | ✔ | — | **A3** BLOCK/PASS; WARN → **A2** |
| Maturity questionnaire | ✔ | ✔ | — | — | — | **A1** (borrador AI, humano envía) |
| Publicar a CI/staging | ✔ | ✔ | ✔ | ✔ | ✔ | **A3** |
| Publicar a producción | ✔ | ✔ | ✔ | — | — | **A2** |
| Rollback de versión | ✔ | ✔ | ✔ | — | — | **A2** (A3 sólo kill-switch config) |
| Restart de servidores | ✔ | ✔ | ✔ | — | — | **A2** |
| Analytics / informes | ✔ | ✔ | ✔ | ✔ | ✔ | **A4** |
| Decisión de gate G4/G5/G6, kill | ✔ | ✔ | — | — | — | **A1** |
| Cambios de monetización/precios | ✔ | ✔ | ✔ | — | — | **A2** |
| Price optimization nativo | ✔ | ✔ | — | — | — | **A1** (Creator Hub manual) |
| Publicidad (crear/escalar campañas) | ✔ | ✔ | ✔ | — | — | **A2** con tope de gasto (A1 hasta tener ROAS medido) |
| LiveOps: contenido pre-aprobado programado | ✔ | ✔ | ✔ | ✔ | — | **A3** |
| LiveOps: ofertas/multiplicadores económicos | ✔ | ✔ | ✔ | — | — | **A2** |
| Experimentos: lanzar | ✔ | ✔ | ✔ | — | — | **A2** |
| Experimentos: leer y aplicar regla pre-registrada | ✔ | ✔ | ✔ | ✔ | — | **A3** (no económicos) |
| Notificaciones/Experience Events | ✔ | ✔ | ✔ | ✔ | — | **A3** con plantillas aprobadas |
| Incident detection | ✔ | ✔ | ✔ | ✔ | ✔ | **A4** |
| Incident mitigation (kill switches) | ✔ | ✔ | ✔ | ✔ | — | **A3** (runbooks) |
| Borrado de datos de producción | ✔ | ✔ | ✔ | — | — | **A2** doble aprobación |
| Bans (temporal / permanente) | ✔ | ✔ | ✔ | ✔ | — | **A3** temporal / **A2** permanente |
| Generación de assets 2D (iconos/UI) | ✔ | ✔ | ✔ | ✔ | — | **A2** |
| Generación 3D / personajes / animación | ✔ | ✔ | ✔ | — | — | **A1** |
| Música | ✔ | ✔ | — | — | — | **A0/A1** |
| Metadata (título, descripción, thumbnails) | ✔ | ✔ | ✔ | — | — | **A2** |
| Localización | ✔ | ✔ | ✔ | ✔ | — | **A3** (revisión humana de tienda/metadata) |
| Optimización de rendimiento | ✔ | ✔ | ✔ | ✔ | — | **A3** (con gates) |
| Knowledge base (findings) | ✔ | ✔ | ✔ | ✔ | — | **A3** con revisión mensual |
| Portfolio allocation | ✔ | ✔ | — | — | — | **A1** |
