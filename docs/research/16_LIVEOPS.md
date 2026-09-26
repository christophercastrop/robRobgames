# 16 — LiveOps, Configs y Experimentación

## 1. Principio

LiveOps = **contenido y parámetros data-driven** sobre sistemas ya implementados, cambiados vía **ConfigService** (nativo) y calendarios versionados,
sin publicar código salvo para contenido nuevo. Roblox recomienda cadencia **semanal ideal, mensual mínima** de actualizaciones [HV `monetization/index.md`].

## 2. Plataforma LiveOps reutilizable (§33) — módulo `LiveOps` del SDK

| Capacidad | Diseño | Fuente de verdad | Cambio sin publicar |
|---|---|---|---|
| Daily rewards | Calendario de N días, streak con gracia, reset UTC | `config/liveops/daily.yaml` → config JSON `liveops.daily` | Sí (recompensas dentro de catálogo existente) |
| Weekly challenges / quests | Definiciones declarativas: `{id, trigger_event, count, filters, reward, window}`; se evalúan escuchando el **bus de eventos de dominio** | `liveops.quests` | Sí (si los `trigger_event` existen) |
| Events (in-game) | Ventana temporal + modificadores + contenido desbloqueado + tienda temporal | `liveops.events` + Experience Events API (visible en plataforma) | Parcial (contenido nuevo requiere build) |
| Limited content | Ítems con ventana de disponibilidad **real** (sin falsa urgencia [HV]) | catálogo + ventana en config | Sí |
| Rotations | Tiendas/mapas/modos rotativos con semilla determinista por periodo | config | Sí |
| Seasonal / season pass | Temporadas con track gratis + premium (pass o **suscripción** — Roblox permite battle pass como suscripción [HV]) | config + products | Premium track = ECONOMY_CHANGE |
| Multipliers | x2 XP/moneda global o por segmento | config (`econ.*` ⇒ ECONOMY_CHANGE) | Sí, con permiso |
| Promotions / bundles | Ofertas con targeting por atributos de **conditional configs** (país, tenure, payer…) [HV] | config + products | ECONOMY_CHANGE |
| Remote configuration | Wrapper `RemoteConfig` del SDK | ConfigService | Sí |
| Notificaciones | Plantillas aprobadas; `users/{id}/notifications` (S) | `liveops/notifications.yaml` | Sí (plantillas pre-aprobadas) |

**Calendario LiveOps**: `games/<slug>/config/liveops/calendar.yaml` (fechas UTC, evento, configs a aplicar, owner, estado). Un job diario
(`liveops-cron`) compara calendario vs configs publicados y crea el *plan* de cambios; contenido pre-aprobado se aplica en A3, lo económico espera aprobación.

## 3. Configs nativos: hechos que condicionan el diseño [HV `production/configs.md`, OpenAPI]

- ≤1,000 configs activos; JSON ≤100,000 caracteres; tipos string/number/bool/JSON.
- Draft → **staged** (visible en Studio para el equipo) → publish (15 s–1 min o gradual en 15 min).
- **Conditional configs**: ≤100 condiciones por juego, ≤20 por key; atributos compartidos con los filtros de analytics.
- `ConfigService` sólo en servidor; `ConfigSnapshot` no se auto-actualiza (aplicar entre rondas); `SetTestingValue` para pruebas en un servidor.
- API: draft/patch/overwrite/publish/revisions/**restore** (BETA) ⇒ rollback de config en segundos.

Diseño de keys [DEC-023]: agrupar en pocas keys JSON por dominio (`liveops.quests`, `econ.shop`, `ff.flags`) con **schema validado en CI** (JSON Schema)
para no agotar el límite y poder validar antes de publicar.

## 4. Feature flags y kill switches

- `ff.<feature>` (bool) para activar features ya desplegadas; `kill.<system>` para desactivar sistemas problemáticos (compras de un producto, trading,
  un evento) en incidentes → aplicable en A3 por el runbook.
- Cada flag tiene owner, fecha de caducidad y se elimina tras estabilizar (deuda de flags revisada mensualmente).

## 5. A/B testing (§32)

Capacidades reales: **Experiments nativo** (in-game sobre configs y matchmaking), 14–60 días, ≤2 variantes + control (in-game), métricas nativas D1, D7,
playtime, ARPU, ARPPU, payer conversion, session time; MDE; targeting; alertas tempranas de daño; API EXPERIMENTAL [HV]. Thumbnails: personalización/pruebas
nativas. **No hace falta construir un sistema propio de asignación** [DEC-024]; sólo:

- Registro de exposición propio (`experiment_exposure`) para análisis de métricas custom (tutorial funnel, economía) que el experimento nativo no calcula aún
  ("custom creator-defined metrics" anunciado como futuro [HV newsroom 2026-08]).
- Plantilla de experimento y gobierno.

Plantilla (`knowledge/experiments/<id>.md`):

```yaml
id: EXP-<game>-<nnn>
hypothesis: "Si <cambio>, entonces <métrica> mejora porque <mecanismo>"
population: {rollout_pct: 50, targeting: "new users, all platforms"}
variants: {control: {...}, B: {...}}
primary_metric: D7 retention          # una sola
guardrails: [first_play_bounce, ARPDAU, crash_rate, playtime]
mde: calculado vía calculateMde (API) antes de lanzar
duration_days: max(14, días hasta n requerida)
significance: α=0.05 bilateral; sin peeking (sólo se decide al final o por alerta de daño)
decision_rule: "Ship si primaria mejora con IC95% > 0 y ningún guardrail empeora > umbral"
status: planned|running|decided
decision: ship|revert|iterate
learning_scope: game|genre|global
```

Experimentos típicos: onboarding (pasos, tiempo a primera recompensa), tutorial (guiado vs libre), UI (posición del botón de tienda), pricing (vía
**price optimization nativo** en lugar de A/B manual cuando aplique), shop placement, progresión (curva g), dificultad, quests, thumbnails (personalization), eventos.

**Precaución estadística**: con tráfico bajo (soft launch) la mayoría de tests no tendrán potencia → priorizar cambios grandes, usar MDE para decidir si vale la pena,
y preferir secuencias pre/post con controles (holdout) sólo como evidencia débil.

## 6. Autonomía LiveOps

| Acción | Nivel |
|---|---|
| Programar contenido pre-aprobado del calendario | A3 |
| Ajustar parámetros no económicos dentro de rangos validados | A3 |
| Cambios económicos (multiplicadores, precios, ofertas) | A2 |
| Lanzar experimento (diseño aprobado) | A2 |
| Leer/decidir experimento según regla pre-registrada | A3 (ship/revert) con notificación; A2 si afecta economía |
| Crear eventos con contenido nuevo | A1–A2 |
