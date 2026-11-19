#!/usr/bin/env bash
# Testmatrix für den Push-Wächter. Von überall ausführbar:
#   .claude/hooks/push-waechter.test.sh
# Endet mit Exit-Code ungleich 0, wenn sich ein Fall anders verhält als erwartet.

set -u

here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
hook="$here/push-waechter.sh"
failed=0

if ! command -v jq >/dev/null 2>&1; then
  echo "jq wird gebraucht, um die JSON-Eingabe des Hooks zu bauen." >&2
  exit 1
fi

run() { printf '%s' "$1" | jq -Rs '{tool_input:{command:.}}' | "$hook" >/dev/null 2>&1; }

check() {
  local expected="$1" cmd="$2" got
  if run "$cmd"; then got=ERLAUBT; else got=BLOCKIERT; fi
  if [ "$got" = "$expected" ]; then
    printf '  ok   %-9s %s\n' "$got" "$cmd"
  else
    printf '  FEHLER erwartet=%s bekommen=%s  %s\n' "$expected" "$got" "$cmd"
    failed=1
  fi
}

unset PUSH_WAECHTER_PREFIX

echo "Standard-Präfix claude/ – Pushes dorthin und andere git-Befehle müssen durchgehen:"
check ERLAUBT 'git push -u origin claude/mein-branch'
check ERLAUBT 'git push origin claude/feature'
check ERLAUBT 'git push origin HEAD:claude/feature'
check ERLAUBT 'git push origin claude/a claude/b'
check ERLAUBT 'git status && git push -u origin claude/x'
check ERLAUBT 'git push origin refs/heads/claude/x'
check ERLAUBT 'git commit -m "push to main later"'
check ERLAUBT 'git log --oneline -5'
check ERLAUBT 'git fetch origin main && git merge --no-edit FETCH_HEAD'
check ERLAUBT 'ls -la'

echo
echo "Alles andere muss blockiert werden:"
# Ziel außerhalb der Erlaubnisliste.
check BLOCKIERT 'git push origin main'
check BLOCKIERT 'git push origin HEAD:main'
check BLOCKIERT 'git push origin master'
check BLOCKIERT 'git push origin claude/ok main'
check BLOCKIERT 'git push origin claude/'
check BLOCKIERT 'git push origin claude/../main'
check BLOCKIERT 'git push origin refs/heads/claude/../../main'
# Kein ausdrückliches Ziel: die Git-Konfiguration würde entscheiden.
check BLOCKIERT 'git push'
check BLOCKIERT 'git push origin'
# Erzwungene Updates.
check BLOCKIERT 'git push --force origin claude/x'
check BLOCKIERT 'git push -f origin claude/x'
check BLOCKIERT 'git push --force-with-lease origin claude/x'
check BLOCKIERT 'git push --force-with-lease=main:abc origin claude/x'
check BLOCKIERT 'git push origin +claude/x'
# Löschen.
check BLOCKIERT 'git push origin --delete claude/x'
check BLOCKIERT 'git push origin :claude/x'
check BLOCKIERT 'git push origin claude/x:'
# Massen-Pushes.
check BLOCKIERT 'git push --mirror origin'
check BLOCKIERT 'git push --all origin'
# Historie umschreiben und Refs direkt verschieben.
check BLOCKIERT 'git filter-repo --invert-paths'
check BLOCKIERT 'git filter-branch --all'
check BLOCKIERT 'git update-ref refs/heads/main HEAD'
# Nicht prüfbare Pushes: der Wächter lehnt ab, statt zu raten.
check BLOCKIERT 'bash -c "git push origin main"'
check BLOCKIERT 'sh -c "git push origin main"'
check BLOCKIERT 'eval "git push origin main"'
check BLOCKIERT 'git push origin "main'
# Ein verbotener Push hinter einem erlaubten.
check BLOCKIERT 'git push origin claude/x && git push origin main'
check BLOCKIERT 'cd /tmp && git push origin main'

echo
echo "Eigenes Präfix über PUSH_WAECHTER_PREFIX=feature/:"
export PUSH_WAECHTER_PREFIX="feature/"
check ERLAUBT   'git push -u origin feature/login'
check BLOCKIERT 'git push -u origin claude/login'
check BLOCKIERT 'git push origin main'

echo
echo "Ungültige Präfixe sperren alle Pushes, statt alle zu erlauben:"
for bad in "" "feature" "/" "main"; do
  export PUSH_WAECHTER_PREFIX="$bad"
  check BLOCKIERT 'git push -u origin feature/login'
done
export PUSH_WAECHTER_PREFIX=""
check ERLAUBT 'git status'
unset PUSH_WAECHTER_PREFIX

echo
if [ "$failed" -eq 0 ]; then
  echo "Alle Fälle bestanden."
else
  echo "Einige Fälle sind fehlgeschlagen."
fi
exit "$failed"
