---
name: pr-beschreibung
description: Schreibt eine Pull-Request-Beschreibung (Titel, Zusammenfassung, Änderungen, Testhinweise) aus den Commits und dem Diff eines Branches gegenüber dem Basis-Branch. Verwenden, wenn ein Pull Request erstellt oder beschrieben werden soll oder nach einer PR-Beschreibung gefragt wird.
---

# Pull-Request-Beschreibung schreiben

## Schritte

1. **Basis-Branch bestimmen**: Den Basis-Branch nehmen, den der Nutzer nennt. Sonst den Standard-Branch des Repos (`git symbolic-ref refs/remotes/origin/HEAD`), meist `main`.
2. **Änderungen lesen**:
   - `git log --oneline <basis>..HEAD` – welche Commits gehören dazu?
   - `git diff --stat <basis>...HEAD` – welche Dateien sind betroffen?
   - `git diff <basis>...HEAD` – was hat sich inhaltlich geändert?
3. **Vorlage suchen**: Gibt es `pull_request_template.md` (im Root, in `.github/` oder `docs/`) oder den Ordner `.github/PULL_REQUEST_TEMPLATE/`, dann deren Gliederung verwenden statt der Standardgliederung unten.
4. **Beschreibung schreiben** (Format unten):
   - Das *Warum* aus Commit-Nachrichten und Code ableiten. Nichts erfinden: Ist der Grund unklar, beim Nutzer nachfragen oder als offene Frage markieren.
   - Nur beschreiben, was tatsächlich im Diff steht.
5. **Ausgeben, nicht veröffentlichen**: Die Beschreibung dem Nutzer zeigen. Den PR nur erstellen oder aktualisieren, wenn das ausdrücklich verlangt wurde.

## Format

```markdown
<Titel: kurz, im Imperativ, z. B. im Stil von Conventional Commits>

## Worum geht es?
<1–3 Sätze: Problem oder Ziel und die Lösung>

## Änderungen
- <wichtigste Änderung>
- <weitere Änderung>

## Testen
- <wie geprüft wurde bzw. wie Reviewer es prüfen können>

## Hinweise
<Breaking Changes, offene Fragen, Folgearbeiten – sonst weglassen>
```

## Regeln

- Sprache des Projekts übernehmen (`git log --oneline -10` ansehen).
- Kurz halten: Reviewer sollen in einer Minute wissen, was sie erwartet.
- Keine Secrets, Tokens oder persönlichen Daten aus dem Diff zitieren.
