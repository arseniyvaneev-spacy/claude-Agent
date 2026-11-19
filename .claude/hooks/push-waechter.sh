#!/usr/bin/env bash
# PreToolUse-Hook für den github-maintainer-Agenten.
#
# Dünner Wrapper: Die eigentliche Prüfung steckt in push-waechter.py und braucht
# python3. Ohne python3 lehnt dieser Wrapper Pushes ab, statt sie
# durchzuwinken – ein fehlender Interpreter darf den Schutz nicht still abschalten.
#
# Exit-Code 2 blockiert den Tool-Aufruf und zeigt stderr an Claude.

set -u

here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
checker="$here/push-waechter.py"

if command -v python3 >/dev/null 2>&1 && [ -r "$checker" ]; then
  exec python3 "$checker"
fi

# Fallback: kein python3 (oder Prüfskript fehlt). Im Zweifel blockieren.
input="$(cat)"
if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)"
else
  cmd="$input"
fi

if printf '%s' "$cmd" | grep -q 'push'; then
  echo "Blockiert durch push-waechter: python3 oder push-waechter.py fehlt," \
       "deshalb werden Pushes abgelehnt." >&2
  exit 2
fi

exit 0
