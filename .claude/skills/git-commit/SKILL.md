---
name: git-commit
description: Erstellt saubere Git-Commits nach Conventional Commits mit aussagekräftiger Nachricht. Verwenden, wenn Änderungen committet werden sollen oder nach einer Commit-Nachricht gefragt wird.
---

# Git-Commit erstellen

## Schritte

1. **Überblick**: `git status` und `git diff` (bzw. `git diff --staged`) lesen.
2. **Prüfen, bevor committet wird**:
   - Keine Secrets (`.env`, API-Keys, Tokens, Passwörter) im Diff? → Sonst abbrechen und warnen.
   - Keine Debug-Reste (`print("DEBUG")`, `console.log`, auskommentierter Code)?
   - Gehören die Änderungen thematisch zusammen? Wenn nicht: in mehrere Commits aufteilen und gezielt mit `git add <datei>` stagen.
3. **Nachricht schreiben** (Format unten).
4. **Committen**: `git commit -m "<betreff>" -m "<body>"`.
5. Nicht pushen, außer es wurde ausdrücklich verlangt.

## Format (Conventional Commits)

```
<typ>(<bereich>): <kurze Beschreibung im Imperativ>

<Warum wurde das geändert? Was war das Problem?
Was ist das neue Verhalten? Max. ~72 Zeichen pro Zeile.>
```

| Typ | Wofür |
|---|---|
| `feat` | neue Funktion |
| `fix` | Bugfix |
| `docs` | nur Dokumentation |
| `refactor` | Umbau ohne Verhaltensänderung |
| `test` | Tests hinzufügen/ändern |
| `chore` | Build, Abhängigkeiten, Konfiguration |
| `perf` | Performance |
| `style` | Formatierung, keine Logik |

## Regeln für den Betreff

- Max. 50–72 Zeichen, kein Punkt am Ende.
- Imperativ: „füge hinzu“, „behebe“ – bzw. englisch „add“, „fix“. Sprache des Projekts übernehmen (`git log --oneline -10` ansehen).
- Beschreibt das *Was*, der Body das *Warum*.

## Beispiele

```
fix(auth): behebe Absturz bei abgelaufenem Token

Abgelaufene Tokens lösten eine unbehandelte KeyError aus, weil
das Feld "exp" fehlte. Jetzt wird der Nutzer zum Login umgeleitet.
```

```
feat(bot): füge /hilfe-Befehl hinzu
```
