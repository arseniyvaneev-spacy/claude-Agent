#!/usr/bin/env bash
# Prüft alle Agents und Skills auf gültiges Frontmatter:
#  - Datei beginnt mit '---' und hat einen schließenden '---'-Block
#  - 'name' und 'description' sind vorhanden
#  - 'name' ist kebab-case und passt zum Datei- bzw. Ordnernamen
#  - Agents: 'tools' enthält nur bekannte Tool-Namen (Warnung bei unbekannten)

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

KNOWN_TOOLS="Read Write Edit MultiEdit Bash Grep Glob WebSearch WebFetch NotebookEdit Task Agent TodoWrite BashOutput KillShell"

errors=0
warnings=0

err()  { echo "  ✗ $1: $2"; errors=$((errors + 1)); }
warn() { echo "  ! $1: $2"; warnings=$((warnings + 1)); }

frontmatter() {
  # gibt den Frontmatter-Block (ohne ---) aus; leer, wenn ungültig
  awk 'NR==1 && $0!="---" {exit} NR==1 {next} $0=="---" {found=1; exit} {print} END {if (!found) exit 1}' "$1"
}

field() {
  # Wert eines einfachen 'key: value'-Felds
  grep -E "^$1:" <<<"$2" | head -1 | sed -E "s/^$1:[[:space:]]*//; s/[[:space:]]+#.*$//"
}

list_field() {
  # Werte eines Listenfelds, kommagetrennt ausgegeben. Versteht alle drei Schreibweisen:
  #   key: A, B          key: [A, B]          key:
  #                                             - A
  #                                             - B
  local inline
  inline="$(field "$1" "$2")"
  if [[ -n "$inline" ]]; then
    inline="${inline#[}"; inline="${inline%]}"
    echo "$inline"
    return
  fi
  awk -v key="$1" '
    $0 ~ "^"key":" {inlist=1; next}
    inlist && /^[[:space:]]*-/ {sub(/^[[:space:]]*-[[:space:]]*/, ""); sub(/[[:space:]]+#.*$/, ""); out = out (out ? "," : "") $0; next}
    inlist && /^[^[:space:]]/ {inlist=0}
    END {print out}
  ' <<<"$2"
}

check_file() {
  local file="$1" expected="$2" kind="$3"
  local fm name desc
  if ! fm="$(frontmatter "$file")" || [[ -z "$fm" ]]; then
    err "$file" "kein gültiger Frontmatter-Block (--- … ---)"
    return
  fi
  name="$(field name "$fm")"
  desc="$(field description "$fm")"

  [[ -z "$name" ]] && err "$file" "'name' fehlt"
  [[ -z "$desc" ]] && err "$file" "'description' fehlt"
  if [[ -n "$name" ]]; then
    [[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || err "$file" "'name' ist kein kebab-case: $name"
    [[ "$name" == "$expected" ]] || err "$file" "'name' ($name) passt nicht zu '$expected'"
  fi
  if [[ -n "$desc" && ${#desc} -lt 40 ]]; then
    warn "$file" "'description' ist sehr kurz – sie entscheidet, wann Claude das nutzt"
  fi

  if [[ "$kind" == "agent" ]]; then
    local tools
    tools="$(list_field tools "$fm")"
    if [[ -n "$tools" ]]; then
      IFS=',' read -ra list <<<"$tools"
      for t in "${list[@]}"; do
        t="$(xargs <<<"$t")"
        [[ "$t" == mcp__* ]] && continue
        [[ " $KNOWN_TOOLS " == *" $t "* ]] || warn "$file" "unbekanntes Tool '$t'"
      done
    fi
  fi
}

echo "Agents:"
for f in .claude/agents/*.md; do
  [[ -e "$f" ]] || continue
  check_file "$f" "$(basename "$f" .md)" agent
done

echo "Skills:"
for d in .claude/skills/*/; do
  [[ -d "$d" ]] || continue
  d="${d%/}"
  if [[ ! -f "$d/SKILL.md" ]]; then
    err "$d" "SKILL.md fehlt"
    continue
  fi
  check_file "$d/SKILL.md" "$(basename "$d")" skill
done

echo
if [[ $errors -gt 0 ]]; then
  echo "❌ $errors Fehler, $warnings Warnungen"
  exit 1
fi
echo "✅ Alles gültig ($warnings Warnungen)"
