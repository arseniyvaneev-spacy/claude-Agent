#!/usr/bin/env bash
# PostToolUse-Hook: Läuft nach Edit/Write. Betrifft die Änderung einen Agenten
# oder Skill, wird scripts/validate.sh in dem Repo ausgeführt, in dem die
# geänderte Datei liegt (nicht zwingend der Projektordner der Session – wichtig
# bei Worktrees und zweiten Klonen). Bei Fehlern geht die Ausgabe über stderr
# an Claude (Exit-Code 2), damit Claude sie korrigiert.

set -uo pipefail

standard_repo="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
repo="$standard_repo"
eingabe="$(cat)"

# Pfad der geänderten Datei lesen; ohne jq im Zweifel das Standard-Repo prüfen.
if command -v jq >/dev/null 2>&1; then
  pfad="$(jq -r '.tool_input.file_path // .tool_response.filePath // empty' <<<"$eingabe")"
  [[ "$pfad" == *"/.claude/agents/"* || "$pfad" == *"/.claude/skills/"* ]] || exit 0

  # Repo der geänderten Datei bestimmen. Liegt sie in keinem Git-Repo,
  # bleibt es beim Standard-Repo.
  ordner="$(dirname "$pfad")"
  while [[ ! -d "$ordner" && "$ordner" != "/" ]]; do ordner="$(dirname "$ordner")"; done
  if top="$(git -C "$ordner" rev-parse --show-toplevel 2>/dev/null)"; then
    repo="$top"
  fi
fi

# Anderes Projekt ohne eigenen Validator: nichts zu prüfen.
[[ -x "$repo/scripts/validate.sh" ]] || exit 0

if ! ausgabe="$("$repo/scripts/validate.sh" 2>&1)"; then
  echo "validate.sh ist nach dieser Änderung rot ($repo) – bitte beheben:" >&2
  echo "$ausgabe" >&2
  exit 2
fi
exit 0
