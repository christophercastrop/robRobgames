# 02 — Toolchain

> Actividad de repos medida el 2026-09-26 con `git clone --depth 1` (fecha del último commit en la rama por defecto) y
> `git ls-remote --tags` (último tag). "Último commit" ≠ release: se indican ambos. Todo lo de esta tabla es **[HECHO VERIFICADO]** salvo
> la columna *Recomendación* (**[DECISIÓN PROPUESTA]**).

## 1. Evaluación herramienta por herramienta

### 1.1 Sincronización Git ↔ Studio

| Herramienta | Problema | Madurez | Mantenimiento (último commit / tag) | Ventajas | Riesgos | Recomendación |
|---|---|---|---|---|---|---|
| **Rojo** (`rojo-rbx/rojo`, MPL-2.0) | Filesystem como fuente de verdad; `rojo build` (→ .rbxl/.rbxm), `rojo serve` (live sync), `sourcemap`, `syncback` | Muy alta, estándar de facto | 2026-07-05 / **v7.7.0 (2026-07-01)** | Build headless en Linux; sourcemaps para luau-lsp; syncback (place→proyecto) desde 7.7 | Sin Team Create real; releases espaciadas | **ADOPTAR** (núcleo) |
| **Roblox Script Sync** (Studio, beta oficial) | Sincronizar *scripts* de Studio a carpeta local | Beta | Oficial | Compatible con Team Create; cero instalación | Solo scripts, sin build headless, sin package manager, Studio es la fuente de verdad | **NO como núcleo**; aceptable para colaboradores sólo-Studio |
| **Argon** (`dervexdev/argon`) | Alternativa a Rojo con sync bidireccional | Media | 2024-06-09 / 2.0.2 | Two-way sync | **Sin commits desde 2024-06** | **DESCARTAR** |
| **Azul** (`ransomwave/azul`) | Alternativa a Rojo (Studio-first sync) | Baja-media | 2026-09-25 / v2.2.0 | Muy activo | Comunidad pequeña, filosofía Studio-first | **VIGILAR** |
| **Remodel** (`rojo-rbx/remodel`) | Manipular .rbxl por script | — | 2023-07-22 (deprecado en favor de Lune) | — | Abandonado | **DESCARTAR** → Lune |
| **run-in-roblox** | Ejecutar scripts en Studio desde CLI | — | 2020-07-19 | — | Abandonado | **DESCARTAR** → Open Cloud Luau Execution |

### 1.2 Gestión de toolchain y paquetes

| Herramienta | Problema | Mantenimiento | Recomendación |
|---|---|---|---|
| **Rokit** (`rojo-rbx/rokit`) | Instala versiones fijadas de CLIs (rojo, stylua, selene, lune, wally…) | 2026-05-09 / v1.2.0 (2025-09-30); compatible con `aftman.toml`/`foreman.toml` | **ADOPTAR** |
| Aftman | Idem | 2025-07-09 / v0.3.0-pre1; README de Rokit indica futuro incierto | DESCARTAR (usar Rokit) |
| Foreman (Roblox) | Idem (uso interno Roblox) | 2026-05-01 / v1.7.0 | DESCARTAR para nosotros (Rokit es drop-in) |
| **Wally** (`UpliftGames/wally`) | Package manager Roblox (registry público) | 2026-09-26 (commits activos) / última release estable **v0.3.2 (2023-06-05)**, `v0.4.0-alpha.0` | **ADOPTAR** para deps de terceros (ecosistema mayoritario), con lockfile commiteado |
| **pesde** (`pesde-pkg/pesde`) | Package manager multi-runtime (Roblox + Lune + Luau) | 2026-08-07 / v0.7.4 | **VIGILAR**; migrar si Wally se estanca (la fábrica mapea deps propias por ruta, no depende del registry) |

### 1.3 Calidad de código

| Herramienta | Problema | Mantenimiento | Recomendación |
|---|---|---|---|
| **StyLua** | Formatter | 2026-05-16 / v2.5.2 | **ADOPTAR** |
| **Selene** | Linter (con std Roblox) | 2026-05-20 / 0.31.0 | **ADOPTAR** |
| **luau-lsp** (`JohnnyMorganz/luau-lsp`) | Language server + `luau-lsp analyze` (typecheck CLI con sourcemap Rojo) | 2026-09-26 / 1.70.0 (2026-09-20) | **ADOPTAR** (typecheck en CI) |
| Roblox LSP (Nightrains) | LSP antiguo | Superado por luau-lsp [INF] | DESCARTAR |
| **Luau** (`luau-lang/luau`) | Lenguaje/compilador/`luau-analyze` | 2026-09-25 | Referencia |
| **darklua** | Transformaciones/bundling de Luau (p.ej. requires por ruta) | 2026-07-13 / v0.19.0 | **OPCIONAL** (sólo si se adopta require-by-string fuera del engine) |
| **Moonwave** | Docs desde comentarios | 2026-06-02 / v1.4.2 | **OPCIONAL** (docs del SDK) |

### 1.4 Testing

| Herramienta | Problema | Mantenimiento | Recomendación |
|---|---|---|---|
| **Jest-Lua** (`jsdotlua/jest-lua`, MIT) | Framework de test estilo Jest, usado internamente por Roblox; **sólo corre dentro del engine** | 2024-12-23 / v3.10.0 | **ADOPTAR** para tests de engine (ejecutados vía Open Cloud Luau Execution). Riesgo: actividad baja → fijar versión |
| TestEZ | Framework BDD antiguo | 2023-01-30 / v0.4.2 | DESCARTAR |
| **Lune** (`lune-org/lune`) | Runtime Luau standalone (fs, net, process, **roblox** lib para leer/escribir .rbxl) | 2026-09-26 / v0.10.5 | **ADOPTAR**: tests unitarios puros offline en Linux, scripts de tooling, validación de place files |

### 1.5 Lenguaje alternativo

| Herramienta | Evaluación | Recomendación |
|---|---|---|
| **roblox-ts** (TS→Luau) | Activo (2026-09-18; v3.0.0 de 2024-09). Tipado fuerte y ecosistema npm. Añade capa de compilación; el MCP de Studio, Assistant, docs oficiales y ejemplos son Luau; la depuración en Studio ocurre sobre Luau generado. | **NO ADOPTAR** [DEC-004]. Luau `--!strict` + luau-lsp da tipado suficiente sin capa extra. |

### 1.6 Frameworks y librerías de runtime

| Librería | Categoría | Mantenimiento | Evaluación | Recomendación |
|---|---|---|---|---|
| **Knit** | Service/Controller framework | 2024-07-31 / v1.7.0 | Sin actividad 2 años; el patrón es trivial de replicar | **NO** — loader propio de ~150 líneas en el SDK |
| **Nevermore** | Mega-librería modular | 2026-09-24 | Muy completo pero opinado y pesado | **NO como base**; consultar como referencia |
| **Matter** (ECS) | ECS | 2024-07-16 | Parado | **NO** |
| **jecs** (`Ukendio/jecs`) | ECS de alto rendimiento | 2026-09-17 / v0.11.0 | Activo, rápido | **SÓLO** juegos simulation-heavy (muchas entidades) |
| **Reflex** | State (Redux-like) | 2025-12-20 / v4.3.1 | Maduro, menos activo | Alternativa |
| **Charm** (`littensy/charm`) | State atómico + sync servidor→cliente | 2026-06-21 / v0.7.6 | Activo, encaja con UI reactiva | **ADOPTAR** para estado cliente/replicación de lectura |
| **Fusion** | UI reactiva | 2026-02-01 / v0.3-beta | Sigue en beta | Alternativa |
| **React Lua** (`jsdotlua/react-lua`) | UI (port de React usado por Roblox) | 2024-12-04 / v17.2.1 | Estable pero parado | Alternativa conservadora |
| **Vide** (`centau/vide`) | UI reactiva ligera | 2026-09-25 / 0.4.1 | Muy activo, API pequeña (buena para LLMs) | **ADOPTAR** [DEC-006] (spike de validación en Fase 2) |
| **Promise** (evaera) | Async | 2023-10-15 / v4.0.0-rc.3 | Estable pero parado | Evitar en código nuevo; usar `task` + corutinas; permitir sólo en deps |
| **Janitor** / **Trove** (RbxUtil) | Limpieza de conexiones | Janitor 2025-10-18 / v1.17.0; RbxUtil 2026-07-27 | Ambos válidos | **ADOPTAR Trove** (RbxUtil activo) |
| **Zap** (`red-blox/zap`) | Networking con IDL + codegen (serialización buffer, validación de tipos) | 2026-06-23 / v0.6.29 | Genera remotes tipados y validados → reduce superficie de exploit | **ADOPTAR** candidato principal [DEC-007] |
| **Blink** (`1Axen/blink`) | Networking IDL + codegen | 2026-09-19 / v1.0.0-pre.10 | Muy activo, en pre-release | Alternativa (spike comparativo) |
| ByteNet | Networking | 2025-08-01 | Menos activo | NO |
| Warp | Networking | Repo no accesible en la verificación | — | NO |
| **ProfileStore** (MadStudio) | Session-locked player data sobre DataStore | 2025-07-31 | Sucesor de ProfileService (2024-10), patrón de referencia de la comunidad | **ADOPTAR** detrás de una interfaz `PlayerData` del SDK (permite sustituirlo) |

### 1.7 CLIs de Open Cloud

| Herramienta | Mantenimiento | Recomendación |
|---|---|---|
| **rbxcloud** (`Sleitnick/rbxcloud`, Rust CLI/lib) | 2025-03-23 / v0.17.0 | Útil para scripts puntuales; **no cubre** APIs de 2026 (analytics, configs, experiments). La fábrica usa cliente propio generado desde el OpenAPI oficial [DEC-009]. |

## 2. Workflow Git ↔ Roblox recomendado

```text
Claude Code (Cloud plane, Linux)                 Claude Code (Studio plane, Win/macOS)
        │                                                   │
        ▼                                                   ▼
repositorio Git (monorepo) ──── rojo serve ────► Roblox Studio ◄── MCP integrado (stdio)
        │   src/*.luau, *.project.json, configs          │   playtest, input simulado,
        │                                                 │   screen_capture, consola
        ▼                                                 │
CI (GitHub Actions, Linux)                                │
  stylua --check → selene → luau-lsp analyze               │
  → lune tests (puros) → rojo build → .rbxl               │
  → Open Cloud: publish a place de CI (versionType=Saved) │
  → Open Cloud: Luau Execution (Jest-Lua) → logs          │
  → security audit + policy scan                          │
        ▼                                                 │
Open Cloud: publish a universe STAGING ──────────────────►  playtest humano / agente (Studio plane)
        ▼
Aprobación humana (release gate)
        ▼
Open Cloud: publish a universe PRODUCTION (versionType=Published)
```

**Qué funciona sin abrir Studio** [HV]: edición de código, build, publicación de places, ejecución headless de Luau (tests), gestión de
DataStores/MemoryStores/Configs/Experiments/passes/dev products, restart de servidores, lectura de logs de servidores de producción
(`server-management/v1/.../game-servers/{jobId}/logs`, BETA), analytics.

**Qué requiere Studio** [HV/INF]: playtest con cliente y render, input real, UI visual, multi-cliente, edición visual de mundo, captura de pantalla.

## 3. Versiones fijadas iniciales (`rokit.toml`) [DEC]

```toml
[tools]
rojo = "rojo-rbx/rojo@7.7.0"
stylua = "JohnnyMorganz/StyLua@2.5.2"
selene = "Kampfkarren/selene@0.31.0"
luau-lsp = "JohnnyMorganz/luau-lsp@1.70.0"
lune = "lune-org/lune@0.10.5"
wally = "UpliftGames/wally@0.3.2"
```

Actualización: job mensual de Renovate/Dependabot-like (o tarea programada de Claude) que abre PR con bump + CI verde. Nunca `latest` sin pin.

## 4. Lo que NO forma parte del toolchain (y por qué)

- **Frameworks "todo en uno"** (Knit/Nevermore) → acoplamiento; el SDK propio es pequeño y auditable.
- **roblox-ts** → capa de compilación extra sin ganancia neta con agentes (ver DEC-004).
- **Plugins de Studio de terceros con acceso de red** (incluidos MCPs de terceros) → superficie de supply-chain; sólo el MCP integrado oficial.
- **Emuladores de cliente no oficiales / bots que se loguean como usuarios** → violan ToS; E2E sólo vía Studio o simulación server-side (ver `11_QA_E2E.md`).
