# CLAUDE.md — Roblox Game Factory

Este repositorio contiene hoy la **investigación y el blueprint** de la fábrica (carpeta `docs/`).
La implementación se hará en este mismo monorepo siguiendo `docs/FACTORY-BACKLOG.md`.

## Antes de construir nada

1. Lee `docs/RECOMMENDED-ARCHITECTURE.md` y `docs/DECISIONS.md`. Las decisiones con estado `PROPUESTA`
   requieren aprobación humana; no las trates como cerradas.
2. Revisa `docs/research/21_IMPLEMENTATION_ROADMAP.md` para saber en qué fase estamos.
3. Cualquier afirmación sobre Roblox con más de ~60 días de antigüedad debe re-verificarse
   (Roblox cambia APIs, monetización y políticas con frecuencia; ver `docs/SOURCES.md`).

## Reglas no negociables

- **Never trust the client.** Toda mutación de economía/inventario/progreso es server-authoritative (`docs/research/12_SECURITY.md`).
- **No inventes endpoints.** La lista oficial está en `docs/data/open-cloud-endpoints.txt` (extraída del OpenAPI oficial).
  Si algo no está ahí ni en el Creator Hub, es `NO DISPONIBLE`.
- **Permisos por niveles** (`docs/research/04_MCP_ARCHITECTURE.md` §Seguridad): nunca uses claves con
  `PUBLISH_PRODUCTION`, `ECONOMY_CHANGE`, `SPEND_AD_BUDGET` o `DELETE_PRODUCTION_DATA` sin aprobación humana registrada.
- **No clones.** Pasa el gate de originalidad (`docs/research/18_COMPLIANCE.md` §No-clone) antes de cualquier asset/metadata.
- **No scraping que incumpla ToS.** Fuentes permitidas en `docs/inventories/DATA-SOURCES.md`.
- **YAGNI.** Antes de construir un componente propio, comprueba la tabla Build-vs-Buy (`docs/research/19_FACTORY_INFRASTRUCTURE.md`).

## Convenciones previstas (cuando exista código)

- Luau en modo `--!strict`, formateado con StyLua, lint con Selene, tipos con luau-lsp.
- Juegos en `games/<slug>/` (proyecto Rojo propio); SDK compartido en `packages/sdk/`, mapeado por ruta en el `.project.json`.
- Servicios de fábrica en Python (`factory/`), MCP propio en `mcp/roblox-cloud-mcp/`.
- Commits pequeños; cada PR de juego debe pasar: format → lint → typecheck → unit (Lune) → build (Rojo) → engine tests (Open Cloud Luau Execution) → security audit → policy scan.
