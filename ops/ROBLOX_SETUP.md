# Roblox setup — pasos humanos (Top 20: acciones 1, 2, 3 y 6)

Estas acciones **no se pueden automatizar** (no existen endpoints para crear universes ni para gestionar identidad/2FA/Plus) o requieren
una estación con Roblox Studio. Marca cada casilla y anota IDs (nunca secretos) en `ops/environments.toml` (copia de `environments.example.toml`).

Verificado contra el Creator Hub (repo `Roblox/creator-docs`, 2026-09-26). Re-verificar si han pasado >60 días.

---

## Acción 1 — Aprobar decisiones clave (≈30 min)

Edita `docs/DECISIONS.md` y cambia `Estado: PROPUESTA` → `Estado: ACEPTADA (AAAA-MM-DD, iniciales)` o `RECHAZADA` en:

- [ ] DEC-001 Monorepo
- [ ] DEC-002 Studio MCP oficial
- [ ] DEC-003 `roblox-cloud-mcp` propio y fino
- [ ] DEC-010 Lune + Jest-Lua vía Luau Execution
- [ ] DEC-011 Aprobaciones con GitHub Environments
- [ ] DEC-012 6 roles de agente + orquestador
- [ ] Presupuesto: LEAN / PROFESSIONAL (ver `docs/research/20_COST_MODEL.md` §6)

> El scaffold ya creado (monorepo, toolchain, CI estático) sigue las propuestas DEC-001/004/005/031 y es reversible.

## Acción 2 — Identidad, grupo y titularidad (⛔ STOP-05 mínimo)

- [ ] Decidir **titular legal** de la fábrica (persona o entidad) y quién recibirá DevEx (formularios W-9/W-8 en el portal DevEx).
- [ ] Cuenta propietaria: **age check**, **ID verification**, **2FA** activada. (Requisitos para publicar a todas las edades y para ads/rewarded video: 13+, ID-verified, 2FA.)
- [ ] **Roblox Plus** activo en la cuenta que publica (alternativa: fee de 1,000 Robux por juego, reembolsable a 90 días).
- [ ] Crear un **grupo** Roblox de la fábrica y transferir allí los juegos (API keys de grupo, ingresos del grupo, roles mínimos).
- [ ] Roles del grupo: `Owner` (humano), `Release` (publica), `Dev` (Team Create/edición), `Analyst` (lectura). Nada de permisos de gasto/pago salvo Owner.
- [ ] Cuenta separada para automatización (si se usan API keys de usuario), con 2FA.

## Acción 3 — Universes y API keys

### 3.1 Universes (Creator Hub → Creations → Create experience; no hay endpoint de creación)

| Universe | Nombre sugerido | Visibilidad | Uso |
|---|---|---|---|
| CI (compartido) | `Factory CI` | Privado | Place por juego para engine tests (Luau Execution) |
| Staging (por juego) | `hello-factory [STAGING]` | Privado / trusted friends | Staging del primer juego |
| Producción de prueba | `hello-factory` | 16+ (sólo cuando lleguemos a la acción 18) | Demo E2E |

Para cada universe: completar el **Maturity & Compliance Questionnaire** (obligatorio para juegos públicos), habilitar
*Enable Studio Access to API Services* sólo en CI/staging, anotar `universe_id` y `place_id` en `ops/environments.toml`.

### 3.2 API keys (Creator Dashboard → Open Cloud → API Keys; preferir keys **del grupo**)

Scopes exactos según el OpenAPI oficial (`docs/data/open-cloud-endpoints.txt`). Una key por fila; restringir por experiencia; **expiración ≤ 90 días**.

| Key (secret de GitHub) | Environment de GitHub | Experiencias | APIs / scopes | IP allowlist |
|---|---|---|---|---|
| `ROBLOX_CI_API_KEY` | `ci` | Factory CI | Place publishing: `universe-places:write` · Luau execution: `universe.place.luau-execution-session:write` + `:read` · Data stores (CI): `universe-datastores.objects:*`, `universe-datastores.control:list` | No posible con runners hospedados de GitHub (IPs variables) → compensar con restricción por experiencia + expiración corta; con runner self-hosted, sí |
| `ROBLOX_STAGING_API_KEY` | `staging` | `* [STAGING]` | `universe-places:write` · `universe-datastores.control:snapshot` · lectura `universe:read` | idem |
| `ROBLOX_PROD_API_KEY` | `production` (required reviewers) | juegos de producción | `universe-places:write` · `universe-datastores.control:snapshot` | idem; **sólo** accesible tras aprobación |
| `ROBLOX_READ_API_KEY` | `analytics` | todas | `universe.analytics:read` · `universe:read` (server logs) · `universe.place:read` | idem |

**No crear todavía** keys con scopes de `game-pass:write`, `developer-product:write`, `ad.campaign:write`, `universe-datastores.control:delete`,
`memory-store:flush` o `universe.place.instance:write` (niveles ECONOMY_CHANGE / SPEND_AD_BUDGET / DELETE_PRODUCTION_DATA / break-glass).

### 3.3 GitHub

- [ ] Repo → Settings → Environments: crear `ci`, `staging`, `production` (required reviewers: ≥1 humano), `analytics`.
- [ ] Guardar cada key como **environment secret** (no como secret de repo).
- [ ] Branch protection en `main`: checks `static` obligatorios, PR review obligatoria.

## Acción 6 — Studio plane (estación Windows o macOS)

Studio no corre en Linux; el MCP integrado usa transporte **stdio** en la máquina local.

1. [ ] Instalar/actualizar **Roblox Studio** a la última versión e iniciar sesión con la cuenta de desarrollo (no la propietaria).
2. [ ] Instalar Claude Code en la misma máquina y clonar este repo.
3. [ ] En Studio: **Assistant Settings → MCP Servers → Enable Studio as MCP server**; usar **Quick connect** para Claude, o copiar el JSON/CLI que muestra.
4. [ ] Instalar la toolchain: `rokit install` en la raíz del repo; instalar el plugin de Rojo (`rojo plugin install`).
5. [ ] Abrir un place **de desarrollo** (nunca de producción), `rojo serve templates/game-template/default.project.json` y conectar desde el plugin.
6. [ ] Verificación (pedírsela a Claude Code):
   - `list_roblox_studios` devuelve la instancia.
   - `search_game_tree` muestra `ServerScriptService.Server` sincronizado por Rojo.
   - `start_stop_play` → `get_console_output` contiene `[factory] server started` → `screen_capture` → `start_stop_play` (parar).
7. [ ] Política local: sin `insert_asset` desde Creator Store salvo allowlist; una sola instancia de Studio por sesión de agente.

Registrar el resultado en `ops/STUDIO_PLANE_CHECK.md` (fecha, versión de Studio, capturas).
