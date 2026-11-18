#!/usr/bin/env bash
# PostToolUse-Hook: Läuft nach Edit/Write. Betrifft die Änderung einen Agenten
# oder Skill, wird ./scripts/validate.sh ausgeführt. Bei Fehlern geht die
# Ausgabe über stderr an Claude (Exit-Code 2), damit Claude sie korrigiert.

set -uo pipefail

repo="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
eingabe="$(cat)"

# Pfad der geänderten Datei lesen; ohne jq im Zweifel immer prüfen.
if command -v jq >/dev/null 2>&1; then
  pfad="$(jq -r '.tool_input.file_path // .tool_response.filePath // empty' <<<"$eingabe")"
  [[ "$pfad" == *"/.claude/agents/"* || "$pfad" == *"/.claude/skills/"* ]] || exit 0
fi

if ! ausgabe="$("$repo/scripts/validate.sh" 2>&1)"; then
  echo "validate.sh ist nach dieser Änderung rot – bitte beheben:" >&2
  echo "$ausgabe" >&2
  exit 2
fi
exit 0
