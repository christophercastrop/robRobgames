#!/usr/bin/env bash
# Checks estáticos del monorepo (P0-02): format → lint → typecheck → unit (Lune) → build (Rojo).
# Uso: tools/ci/check.sh   (requiere tools/ci/install-tools.sh o `rokit install`)
# FACTORY_SELENE_OFFLINE=1 usa una std mínima local cuando selene no puede descargar la API dump de Roblox
# (p. ej. detrás de un proxy TLS que su cliente HTTP no acepta). CI siempre usa la std real "roblox".
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export PATH="$ROOT/.tools/bin:$PATH"
cd "$ROOT"

LUAU_SOURCES=(packages/sdk/src)
GAME_PROJECTS=(templates/game-template)
for game in games/*/; do
	[ -f "$game/default.project.json" ] && GAME_PROJECTS+=("${game%/}")
done
DEFS="$ROOT/.tools/globalTypes.d.luau"

step() { echo; echo "::group::$1"; }
end() { echo "::endgroup::"; }

step "format (stylua --check)"
stylua --check packages templates games tools
end

step "lint (selene)"
lint_targets=("${LUAU_SOURCES[@]}")
for project in "${GAME_PROJECTS[@]}"; do lint_targets+=("$project/src"); done
if [ "${FACTORY_SELENE_OFFLINE:-0}" = "1" ]; then
	(cd tools/ci/selene-offline && selene "${lint_targets[@]/#/$ROOT/}")
else
	selene "${lint_targets[@]}"
fi
end

step "typecheck (rojo sourcemap + luau-lsp analyze)"
for project in "${GAME_PROJECTS[@]}"; do
	(
		cd "$project"
		rojo sourcemap default.project.json -o sourcemap.json
		luau-lsp analyze --platform=roblox --sourcemap=sourcemap.json \
			--definitions=@roblox="$DEFS" --base-luaurc="$ROOT/.luaurc" \
			src "$ROOT/packages/sdk/src"
	)
done
end

step "unit tests (lune)"
lune run packages/sdk/tests/run
end

step "build (rojo build)"
mkdir -p out
for project in "${GAME_PROJECTS[@]}"; do
	name="$(basename "$project")"
	rojo build "$project/default.project.json" -o "out/$name.rbxl"
done
ls -la out
end

echo; echo "all static checks passed"
