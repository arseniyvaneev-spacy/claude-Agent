#!/usr/bin/env bash
# Installiert die Agents und Skills aus diesem Repo global nach ~/.claude,
# damit sie in jedem Projekt in Claude Code verfügbar sind.
#
# Nutzung:
#   ./scripts/install.sh          # Symlinks (Updates per git pull wirken sofort)
#   ./scripts/install.sh --copy   # Kopien statt Symlinks
#   ./scripts/install.sh --force  # vorhandene Dateien mit gleichem Namen ersetzen
#
# Ziel lässt sich über CLAUDE_HOME ändern (Standard: ~/.claude).

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO_DIR/.claude"
DEST="${CLAUDE_HOME:-$HOME/.claude}"

MODE="link"
FORCE=0
for arg in "$@"; do
  case "$arg" in
    --copy)  MODE="copy" ;;
    --force) FORCE=1 ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "Unbekannte Option: $arg" >&2; exit 1 ;;
  esac
done

mkdir -p "$DEST/agents" "$DEST/skills"

installed=0
skipped=0

install_item() {
  local src="$1" target="$2"
  if [[ -e "$target" || -L "$target" ]]; then
    # Eigener Symlink aus diesem Repo → einfach erneuern
    if [[ -L "$target" && "$(readlink "$target")" == "$src" ]]; then
      :
    elif [[ $FORCE -eq 1 ]]; then
      rm -rf "$target"
    else
      echo "  übersprungen (existiert schon): $target  → --force zum Ersetzen"
      skipped=$((skipped + 1))
      return
    fi
  fi
  if [[ "$MODE" == "copy" ]]; then
    rm -rf "$target"
    cp -R "$src" "$target"
  else
    ln -sfn "$src" "$target"
  fi
  echo "  ✓ $(basename "$target")"
  installed=$((installed + 1))
}

echo "Agents → $DEST/agents"
for f in "$SRC"/agents/*.md; do
  [[ -e "$f" ]] || continue
  install_item "$f" "$DEST/agents/$(basename "$f")"
done

echo "Skills → $DEST/skills"
for d in "$SRC"/skills/*/; do
  [[ -f "$d/SKILL.md" ]] || continue
  d="${d%/}"
  install_item "$d" "$DEST/skills/$(basename "$d")"
done

echo
echo "Fertig: $installed installiert, $skipped übersprungen ($MODE)."
echo "In Claude Code prüfen mit: /agents"
