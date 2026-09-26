#!/usr/bin/env bash
# Instala en $TOOLS_DIR (por defecto .tools/bin) las versiones pinneadas en rokit.toml, descargando los binarios
# de GitHub Releases. Se usa en CI y en sesiones cloud (Linux x86_64). En estaciones de desarrollo usar `rokit install`.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOLS_DIR="${TOOLS_DIR:-$ROOT/.tools/bin}"
mkdir -p "$TOOLS_DIR"

version() { # version <tool> -> versión pinneada en rokit.toml
	sed -n "s/^$1 = \"[^@]*@\(.*\)\"/\1/p" "$ROOT/rokit.toml"
}

fetch() { # fetch <binario> <url>
	local bin="$1" url="$2"
	if [ -x "$TOOLS_DIR/$bin" ]; then return; fi
	local tmp; tmp="$(mktemp -d)"
	curl -fsSL --retry 4 --retry-delay 2 -o "$tmp/tool.zip" "$url"
	unzip -oq "$tmp/tool.zip" -d "$tmp"
	install -m 0755 "$tmp/$bin" "$TOOLS_DIR/$bin"
	rm -rf "$tmp"
	echo "installed $bin from $url"
}

GH=https://github.com
v=$(version rojo);     fetch rojo     "$GH/rojo-rbx/rojo/releases/download/v$v/rojo-$v-linux-x86_64.zip"
v=$(version stylua);   fetch stylua   "$GH/JohnnyMorganz/StyLua/releases/download/v$v/stylua-linux-x86_64.zip"
v=$(version selene);   fetch selene   "$GH/Kampfkarren/selene/releases/download/$v/selene-$v-linux.zip"
v=$(version luau-lsp); fetch luau-lsp "$GH/JohnnyMorganz/luau-lsp/releases/download/$v/luau-lsp-linux-x86_64.zip"
v=$(version lune);     fetch lune     "$GH/lune-org/lune/releases/download/v$v/lune-$v-linux-x86_64.zip"
v=$(version wally);    fetch wally    "$GH/UpliftGames/wally/releases/download/v$v/wally-v$v-linux.zip"

# Definiciones de tipos de Roblox de la misma versión de luau-lsp (para `luau-lsp analyze`).
DEFS="$ROOT/.tools/globalTypes.d.luau"
if [ ! -f "$DEFS" ]; then
	curl -fsSL --retry 4 -o "$DEFS" \
		"https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/$(version luau-lsp)/scripts/globalTypes.d.luau"
fi

echo "tools ready in $TOOLS_DIR"
