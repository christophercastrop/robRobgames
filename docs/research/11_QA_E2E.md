# 11 — QA, Testing, E2E, Visual QA, Performance y Device Matrix

## 1. Capas de test (§39)

| Capa | Qué prueba | Herramienta | Dónde corre | Automatizable | Coste/velocidad |
|---|---|---|---|---|---|
| **Unit** | Lógica pura (curvas de economía, validadores, reducers de estado, parsers de config) sin APIs de Roblox | Lune + mini-runner (o Jest-Lua si se porta) | Linux CI | **A4** | segundos |
| **Integration (engine)** | Servicios del SDK con APIs reales del engine (DataStore en universe CI, MarketplaceService stubs, ConfigService testing values, Instances) | Jest-Lua dentro de **Open Cloud Luau Execution** | Roblox cloud (place CI) | **A4** | 1–5 min; 5 tareas/min por owner |
| **Simulation** | Economía y progresión a escala (miles de jugadores sintéticos, Monte Carlo) | `factory econ simulate` (Python) + réplica Luau de fórmulas verificada por tests de paridad | Linux CI | **A4** | minutos |
| **Server-side bot sim** | Flujos completos **sin cliente**: "jugador" simulado que invoca los handlers de servidor (los mismos que usa Net) — tutorial, compras mock, guardado, migraciones | Jest-Lua + harness `SimPlayer` del SDK | Luau Execution | **A4** | minutos |
| **Playtest automatizado** | Cliente real en Studio: spawn, moverse, interactuar, UI, consola sin errores, capturas | **Studio MCP** (`start_stop_play`, `user_*_input`, `character_navigation`, `get_console_output`, `screen_capture`) guiado por guiones `tests/e2e/*.yaml` | Studio plane (Win/macOS) | **A3 experimental** | 5–15 min/guion |
| **UI testing** | Layout en resoluciones, overlaps, texto cortado, localización | place `ui-gallery` + `execute_luau` (lee `AbsolutePosition/AbsoluteSize/TextFits`) + `screen_capture` + visión | Studio plane | **A3** | minutos |
| **Networking** | Contratos de remotes (Zap IDL), validación de payloads, rate limits, fuzzing de argumentos | Tests de engine que invocan handlers con payloads malformados | Luau Execution | **A4** | minutos |
| **Persistence** | Guardado/carga, session locking, migraciones vN→vN+1, recuperación | Engine tests contra DataStores CI + snapshot staging | Luau Execution | **A4** | minutos |
| **Performance** | Frame time servidor, memoria, instancias, red | Perf harness del SDK (métricas `Stats`) en Luau Execution (servidor) + Studio (cliente) + Analytics performance en staging/prod | Mixto | **A3** servidor / **A1** cliente real | — |
| **Multiplayer** | N clientes simultáneos, replicación, carreras | Studio "Local Server" con N jugadores / Team Test | Studio (humano) | **A1** — no hay API headless multi-cliente | caro |
| **Exploit testing** | Llamadas maliciosas a remotes, estados imposibles, duplicación | Engine tests adversariales + revisión S11 | Luau Execution | **A3** | minutos |
| **Device testing** | Hardware real (Android gama baja, iOS, consola) | Humanos / device farm propia | Físico | **A0–A1** | caro |

## 2. E2E autónomo (§40): hasta dónde llega

| Paso del brief | Cómo | Oficial | Automatizable |
|---|---|---|---|
| spawn | `start_stop_play` | Sí (MCP) | Sí (A3) |
| walk | `character_navigation` (mueve directamente, no simula controles) o `user_keyboard_input` (WASD) | Sí | Sí |
| interact | `user_keyboard_input`/`user_mouse_input` sobre ProximityPrompts/ClickDetectors; o `execute_luau` disparando el prompt | Sí | Sí |
| purchase mock item | En Studio las compras de prueba no cobran [HT, comportamiento de Studio]; mejor: `SimPlayer` server-side con receipt sintético contra `ProcessReceipt` | Parcial | Sí (server-side) |
| complete tutorial | Guion + asserts sobre eventos de funnel | Sí | Sí |
| die / respawn | `execute_luau` (Humanoid.Health = 0) + esperar respawn | Sí | Sí |
| teleport | TeleportService **no funciona entre places en Studio playtest** [HT] | No | **NO** en Studio; probar en staging con humanos o con test de lógica server-side |
| save | Forzar guardado vía API del SDK | Sí | Sí |
| disconnect / rejoin | Parar/iniciar playtest y verificar carga (Studio usa DataStores si "Enable Studio Access to API Services") | Sí | Sí (con DataStores de un place de test) |
| validate persistence | Asserts sobre PlayerData tras rejoin | Sí | Sí |
| Varios jugadores reales en servidor publicado | — | **NO** (bots que se autentican como usuarios = ToS) | **NO** |

**Frontera de la automatización** [INFERENCIA]: todo lo **server-side** es A4; lo **cliente en Studio** es A3 experimental (dependiente del MCP y de una
estación Win/macOS); lo **multi-cliente y en dispositivos reales** requiere humanos (A0–A1). Se compensa con: telemetría de staging (errores de
cliente capturados por `ScriptContext.Error` → logs), soft launch 16+ y playtests humanos programados.

### Formato de guion E2E (Studio MCP)

```yaml
# tests/e2e/tutorial.yaml
name: tutorial_happy_path
place: games/<slug> (rojo serve)
steps:
  - start_play: {mode: play}
  - wait_for: {luau: "return workspace:FindFirstChild(game.Players.LocalPlayer.Name) ~= nil", timeout_s: 20}
  - navigate: {to_tag: "TutorialNPC"}
  - key: {press: "E"}
  - assert_ui: {path: "PlayerGui.Tutorial.Step1", visible: true}
  - screenshot: {name: step1}
  - assert_console: {no_errors: true}
  - stop_play: {}
expect_events: [tutorial_start, tutorial_step:1]
```
El agente de QA traduce cada paso a llamadas MCP y produce `tests/e2e/reports/<run>.md` con capturas.

## 3. Visual QA (§41)

| Técnica | Implementación | Automatizable |
|---|---|---|
| Capturas | `screen_capture` (viewport de Studio) por escena/estado | A3 |
| Comparación | Diff perceptual (SSIM) contra baseline aprobada por humano; umbral por pantalla | A3 |
| Overlaps | `execute_luau` recorre `PlayerGui`: intersección de rects `AbsolutePosition/AbsoluteSize` entre elementos interactivos visibles | A4 (lógico) |
| Texto cortado | `TextLabel.TextFits == false` o `TextBounds` > `AbsoluteSize` | A4 |
| Aspect ratios / dispositivos | Emulación de dispositivos de Studio (resoluciones) — el cambio de dispositivo por script/MCP **no está documentado** ⇒ usar place `ui-gallery` que renderiza cada pantalla en frames con tamaños fijos (phone 19.5:9, tablet 4:3, 16:9, 10-foot) | A3 |
| Missing assets | Scanner: `ContentProvider:PreloadAsync` con callback de fallo sobre todos los `*Id` del DataModel; assets rechazados por moderación | A4 |
| Juicio estético | Modelo de visión como *pre-filtro* (legibilidad, contraste, jerarquía); decisión final humana | A1 |

## 4. Performance gates (§42)

Hechos base [HV `performance-optimization/*`, `analytics/performance.md`]: presupuesto de frame 16.67 ms a 60 FPS; **heartbeat de servidor capado a 60 FPS**;
cliente capado por defecto a 60 FPS (hasta 240 en Windows); mantener **memoria de servidor < 50%** del total; Android ≈ **65%** de la base típica de un juego,
~60% de esos con **2–4 GB RAM**; >50% de jugadores en dispositivos con PassMark 10k–20k; métricas oficiales: FPS cliente, memoria cliente (y % de memoria
disponible por dispositivo), salidas por out-of-memory, crash rate, heartbeat de servidor, memoria de servidor por edad del servidor.

Gates [HIPÓTESIS iniciales, recalibrar con datos de staging/prod]:

| Métrica | Gate (bloquea release) | Warning |
|---|---|---|
| Server heartbeat (p50 / p5) en carga máxima del test | ≥ 55 / ≥ 45 FPS | < 58 p50 |
| Server memory | < 40% del total del servidor tras 2 h de simulación | tendencia creciente (fuga) |
| Client FPS (Analytics, Android) | p50 ≥ 30, sin regresión > 10% vs release previa | regresión > 5% |
| Client memory % (Android) | p90 < 70% de memoria disponible | > 60% |
| OOM exits | Sin aumento vs release previa (IC 95%) | — |
| Instancias en workspace (cliente) | Presupuesto por GDD (p. ej. < 20k partes en streaming radius) | > 80% del presupuesto |
| Red | Payload medio por remote < presupuesto; sin remotes por frame no justificados | — |
| DataStore | 0 errores `*ExperienceThrottled` en test de carga; writes por jugador/min dentro de presupuesto | > 50% del presupuesto |
| Scripts | Ningún handler > 2 ms p95 en servidor (medido con `os.clock` en harness) | > 1 ms |
| Arranque | Tiempo a primera interacción en móvil gama baja (medición humana) | — |

Por plataforma: PC/Mac (baseline alta), **tablet/phone (baseline crítica)**, consola (Xbox/PlayStation: guías 10-foot, gamepad obligatorio, maturity info
obligatoria [HV `console-guidelines.md`]), VR (sólo si el GDD lo incluye).

## 5. Device matrix (§49)

| Clase | Ejemplo de referencia | Qué se prueba | Frecuencia | Método |
|---|---|---|---|---|
| Android gama baja (2–4 GB) | Dispositivo físico de ~3 GB RAM, PassMark ~10k | FPS, memoria, OOM, UI táctil, texto legible | Cada release candidata | Humano (30 min) |
| Android gama media | 4–6 GB | Regresión | Semanal | Humano |
| iPhone reciente + antiguo | 2 modelos | Safe areas, notch, rendimiento | Release | Humano |
| Tablet | iPad / Android tablet | Layout 4:3 | Release | Humano / emulación Studio |
| PC Windows gama baja | iGPU | FPS, gráficos auto | Release | Humano |
| Mac | Apple Silicon | Compatibilidad | Mensual | Humano |
| Xbox / PlayStation | Consola | Gamepad, 10-foot, navegación de UI | Si el juego se habilita en consola | Humano |
| Studio emulation | Presets de dispositivos | Layout/aspect ratio | Cada PR de UI | A3 |

Distribución real por plataforma **de cada juego**: breakdown `Platform` de Analytics (Query API) → ajusta la matriz tras el soft launch.

## 6. Definition of Done de QA por gate

- **G2**: greybox jugable, 0 errores en consola en happy path, playtest humano documentado.
- **G3**: todas las capas A4 verdes, guiones E2E críticos (tutorial, compra, guardado/rejoin) verdes en Studio, perf gates servidor verdes,
  device check humano gama baja, security 0 críticos/altos, policy PASS.
- **Release LIVE**: además, sin regresiones de performance/crash vs versión previa en staging (≥ 24 h con testers).
