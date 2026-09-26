# DECISIONS

Todas las decisiones están en estado **PROPUESTA** hasta que un humano las marque `ACEPTADA` (con fecha e iniciales). Los hechos que las soportan están
en los documentos de investigación; aquí no se mezclan hechos con decisiones: la sección *Evidence* sólo referencia.

---
**DEC-001** · Estado: PROPUESTA
Decision: Monorepo `roblox-factory` (SDK, juegos, factory services, MCP, skills, KB, docs).
Evidence: `19_FACTORY_INFRASTRUCTURE.md` §4; skills de Claude Code se cargan por directorio en monorepos (docs Claude Code).
Alternatives: multi-repo (factory, sdk, mcp, skills, analytics, template, game-*).
Reason: un checkout para agentes; cambios atómicos SDK+juegos; CI de compatibilidad trivial.
Consequences: CI con filtros por path; permisos gruesos; extraer repos si hay colaboradores externos.
Confidence: Alta.

**DEC-002** · PROPUESTA
Decision: Usar el **MCP integrado oficial de Roblox Studio**; no construir `studio.*` propio.
Evidence: doc `studio/mcp`, anuncios 2026-02-21 y 2026-03-05; standalone archivado 2026-04-03.
Alternatives: MCPs de terceros (weppy AGPL, boshyxd archivado), MCP propio vía plugin.
Reason: oficial, mantenido, cubre ~90% de herramientas requeridas.
Consequences: dependencia de una estación Win/macOS; sin permisos granulares → políticas propias.
Confidence: Alta.

**DEC-003** · PROPUESTA
Decision: Construir `roblox-cloud-mcp` **fino** con niveles de permiso, dry-run/plan, aprobaciones y auditoría; migrar a proxy de políticas cuando exista MCP oficial de Open Cloud.
Evidence: no existe MCP oficial de Open Cloud (anunciado como futuro 2026-08-24); MCPs de terceros sin gates.
Alternatives: usar rbxcloud CLI directamente; MCPs comunitarios.
Reason: el valor diferencial es el control de riesgo, no el wrapper HTTP.
Consequences: mantener cliente contra OpenAPI oficial (83% beta/experimental).
Confidence: Alta.

**DEC-004** · PROPUESTA
Decision: Luau `--!strict` nativo; no roblox-ts.
Evidence: `02_TOOLCHAIN.md` §1.5; Studio MCP/Assistant/documentación en Luau; luau-lsp maduro.
Alternatives: roblox-ts.
Reason: menos capas; depuración directa; agentes y docs oficiales en Luau.
Consequences: renunciar a ecosistema npm/TS.
Confidence: Media-alta.

**DEC-005** · PROPUESTA
Decision: Rojo como fuente de verdad del código (filesystem→Studio); Script Sync de Studio sólo para colaboradores Studio-only.
Evidence: Rojo v7.7.0 (2026-07-01) con syncback; Script Sync es beta y sólo scripts.
Alternatives: Script Sync, Argon, Azul.
Reason: build headless en Linux y CI.
Consequences: Team Create no es el flujo principal.
Confidence: Alta.

**DEC-006** · PROPUESTA
Decision: UI con **Vide** + design system propio; Charm para estado.
Evidence: actividad (Vide 2026-09-25, Charm 2026-06-21); React Lua sin commits desde 2024-12; Fusion en beta.
Alternatives: React Lua, Fusion, Roact legacy.
Reason: API pequeña (buena para agentes), activo.
Consequences: pre-1.0 → pin de versión y spike en F2.
Confidence: Media.

**DEC-007** · PROPUESTA
Decision: Networking con **Zap** (IDL + codegen); spike de 1 día comparando con Blink en F1.
Evidence: Zap v0.6.29 (2026-06), Blink v1.0.0-pre.10 (2026-09).
Alternatives: Blink, RemoteEvents manuales, ByteNet.
Reason: remotes tipados/validados reducen superficie de exploit.
Consequences: paso de codegen en CI.
Confidence: Media.

**DEC-008** · PROPUESTA
Decision: ProfileStore detrás de la interfaz `PlayerData` del SDK.
Evidence: sucesor de ProfileService; patrón de session locking de referencia.
Alternatives: DataStore propio con locks en MemoryStore.
Reason: probado; wrapper permite sustituir.
Consequences: bus factor del mantenedor.
Confidence: Media-alta.

**DEC-009** · PROPUESTA
Decision: Cliente Open Cloud propio (Python) generado desde el OpenAPI oficial de `Roblox/creator-docs`.
Evidence: rbxcloud no cubre APIs de 2026; OpenAPI oficial con 720 operaciones y metadatos de scopes/rate limits.
Alternatives: rbxcloud; cliente manual.
Reason: cobertura y actualización automática.
Consequences: tests de contrato semanales.
Confidence: Alta.

**DEC-010** · PROPUESTA
Decision: Unit tests con Lune (Linux) + engine tests con Jest-Lua vía **Open Cloud Luau Execution** en un universe CI.
Evidence: Luau Execution STABLE (≤5 min, ≤4 MB, 5 tareas/min); Jest-Lua sólo corre en engine.
Alternatives: run-in-roblox (abandonado), tests sólo en Studio.
Reason: CI headless real.
Consequences: una tarea por pipeline; cola si hay muchos juegos.
Confidence: Alta.

**DEC-011** · PROPUESTA
Decision: Aprobaciones humanas mediante GitHub Environments (required reviewers) + verificación de `plan_hash` en el MCP.
Evidence: `04_MCP_ARCHITECTURE.md` §5.
Alternatives: aprobaciones en Slack/app propia.
Reason: auditado, sin infraestructura nueva.
Consequences: humanos necesitan acceso a GitHub.
Confidence: Alta.

**DEC-012** · PROPUESTA
Decision: 6 roles LLM (Market Analyst, Game Designer, Engineer×N, Reviewer fork, Release Manager, Live Analyst) + orquestador determinista; especialización vía skills.
Evidence: `06_AGENT_ARCHITECTURE.md` §1–2.
Alternatives: jerarquía de ~16 agentes del brief.
Reason: menos coordinación/contexto duplicado; separación por permisos e independencia.
Consequences: skills más ricas; Reviewer obligatorio.
Confidence: Media-alta.

**DEC-013** · PROPUESTA
Decision: Conocimiento de ingeniería en `knowledge/` como fuente única para Claude Skills y Roblox Assistant Skills (export).
Evidence: ambos formatos son Markdown con frontmatter.
Alternatives: mantener dos conjuntos.
Reason: evitar divergencia.
Consequences: script de exportación.
Confidence: Media.

**DEC-014** · PROPUESTA
Decision: Orquestador en Python + Postgres + GitHub Issues/Projects; subagentes vía Claude Agent SDK o `claude -p`.
Evidence: `06` §3; `19` §2.
Alternatives: frameworks multiagente genéricos; Managed Agents.
Reason: mínimo, auditable.
Consequences: evaluar Managed Agents para jobs programados en F7.
Confidence: Media.

**DEC-015** · PROPUESTA
Decision: Opportunity model bayesiano explícito con priors documentados y recalibración cada 5 lanzamientos; sin ML opaco hasta ≥15–20 lanzamientos.
Evidence: ausencia de evidencia pública predictiva (`08` §1).
Alternatives: ML sobre datos de terceros.
Reason: pocos datos propios; interpretabilidad.
Consequences: juicio humano relevante al inicio.
Confidence: Alta.

**DEC-016** · PROPUESTA
Decision: Arquitectura de juego por defecto Service/Controller + bus de eventos + estado reactivo + red tipada; ECS opcional justificado.
Evidence: `10` §1.
Alternatives: ECS por defecto; Knit.
Reason: simple, testeable, legible por agentes.
Consequences: disciplina contra "god services".
Confidence: Media-alta.

**DEC-017** · PROPUESTA
Decision: Por juego, universes separados de staging y producción + universe CI compartido.
Evidence: DataStores/configs/experiments/analytics son por universe.
Alternatives: places de test en el mismo universe.
Reason: aislamiento de datos.
Consequences: gestión manual de creación de universes (sin API).
Confidence: Alta.

**DEC-018** · PROPUESTA
Decision: Analytics Roblox-native primero; warehouse propio sólo para lo que Roblox no da (F7).
Evidence: `13` §1.
Alternatives: pipeline de eventos propio desde el día 1.
Reason: coste y privacidad; alineación con discovery.
Consequences: latencia de 5–13 h en Query API.
Confidence: Alta.

**DEC-019** · PROPUESTA
Decision: Dashboards con Metabase/Grafana OSS; sin UI propia.
Evidence: `13` §4.
Alternatives: app propia.
Reason: YAGNI.
Consequences: —
Confidence: Alta.

**DEC-020** · PROPUESTA
Decision: El núcleo del loop de los juegos no depende de paid random items; si se usan, capa opcional con OddsTable + PolicyService.
Evidence: `paid-random-items.md`, requisitos de Kids/Select y regulatorios.
Alternatives: gacha como núcleo.
Reason: compliance y acceso a audiencias.
Consequences: posible menor ARPPU en ciertos géneros.
Confidence: Media-alta.

**DEC-021** · PROPUESTA
Decision: Simulador económico agent-based + Monte Carlo sobre `economy.yaml`, con paridad Luau.
Evidence: `14` §4.
Alternatives: hojas de cálculo.
Reason: detectar economías rotas antes de producción.
Consequences: mantener arquetipos calibrados.
Confidence: Media.

**DEC-022** · PROPUESTA
Decision: Creative variants basados en capturas reales + pre-evaluación por visión + test nativo con guardrails de bounce/D1.
Evidence: `15` §3; penalización de metadata engañosa.
Alternatives: arte 100% generativo.
Reason: veracidad y cumplimiento.
Consequences: requiere escenas preparadas.
Confidence: Media.

**DEC-023** · PROPUESTA
Decision: Configs agrupados por dominio en keys JSON validadas por JSON Schema en CI.
Evidence: límites de 1,000 configs / 100k chars.
Alternatives: una key por parámetro.
Reason: límites y validación.
Consequences: cambios más gruesos por publicación.
Confidence: Media.

**DEC-024** · PROPUESTA
Decision: No construir asignación propia de A/B; usar Experiments nativo + logging de exposición.
Evidence: `16` §5.
Alternatives: sistema propio.
Reason: YAGNI.
Consequences: limitado a 2 variantes + control.
Confidence: Alta.

**DEC-025** · PROPUESTA
Decision: Blender MCP sólo experimental en F8, aislado.
Evidence: `17` §4.
Alternatives: integrarlo desde el piloto.
Reason: riesgo y calidad.
Consequences: arte del piloto con kits humanos/curados.
Confidence: Alta.

**DEC-026** · PROPUESTA
Decision: Localización: extracción automática + `translateText` + revisión humana de tienda/metadata.
Evidence: `17` §6.
Confidence: Media.

**DEC-027** · PROPUESTA
Decision: Sin control plane UI hasta ≥5 juegos activos.
Evidence: `19` §2.
Confidence: Alta.

**DEC-028** · PROPUESTA
Decision: Piloto = Incremental Simulator cooperativo de sesión corta; tema decidido en G1 con datos del Trend collector.
Evidence: `21` §3.
Alternatives: Tycoon, Tower Defense, Merge, Obby.
Reason: máxima cobertura del SDK con bajo contenido.
Consequences: riesgo de clon alto → originality gate estricto.
Confidence: Media.

**DEC-029** · PROPUESTA (bloqueada por ⛔ STOP-01)
Decision: Trend Engine usa sólo endpoints documentados en la referencia oficial, a ≤1 req/s con caché; no endpoints de sorts no documentados.
Evidence: `07` §2.
Confidence: Media (pendiente de revisión legal).

**DEC-030** · PROPUESTA
Decision: El soft launch se hace siempre como publicación 16+ (nivel 2 de publicación) antes de all-ages; G4 se mide en esa fase.
Evidence: requisitos de publicación 2026-05-19.
Confidence: Alta.

**DEC-031** · PROPUESTA
Decision: Servicios de la fábrica en Python (trends, score, econsim, policy, orchestrator, MCP); tooling de place files en Lune.
Evidence: ecosistema de datos/estadística; MCP Python SDK activo.
Alternatives: TypeScript/Node.
Confidence: Media.

---

## Stop conditions abiertas (decisión humana necesaria)

| ID | Condición | Bloquea |
|---|---|---|
| ⛔ STOP-01 | (a) Uso automatizado comercial de endpoints documentados no-Open-Cloud (`games.roblox.com`, `thumbnails.roblox.com`); (b) uso de endpoints no documentados de sorts/charts | DEC-029, Trend Engine a escala |
| ⛔ STOP-02 | Conceptos basados en IP de terceros | Gate G0/G1 de esos conceptos |
| ⛔ STOP-03 | Dato no observable: CPI/CAC de Roblox Ads antes de gastar; ARPDAU/retención de competidores | Modelo de negocio → se resuelve con campaña de calibración y soft launch propios |
| ⛔ STOP-04 | Recolección de datos de jugadores fuera de Roblox (warehouse propio) — base legal y menores | Warehouse event-level (F7) |
| ⛔ STOP-05 | Titularidad: cuenta/grupo Roblox, DevEx (impuestos, W-8/W-9), entidad legal | Monetización real |
| ⛔ STOP-06 | Semántica de `matchmaking-api/game-instances/launch-update` (rollout de updates) no documentada | Uso en releases |
