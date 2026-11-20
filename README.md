# claude-Agent

Eine Sammlung von **Subagenten** und **Skills** für [Claude Code](https://docs.claude.com/en/docs/claude-code/overview) – auf Deutsch, direkt einsetzbar, in jedem Projekt.

## Inhalt

### Agents (`.claude/agents/`)

Subagenten arbeiten in einem eigenen Kontext mit eigenen Tools und liefern ein Ergebnis zurück.

| Agent | Wofür | Tools |
|---|---|---|
| [`code-reviewer`](.claude/agents/code-reviewer.md) | Kritisches Review nach Code-Änderungen, sortiert nach Schwere | nur lesen + Bash |
| [`debugger`](.claude/agents/debugger.md) | Ursache von Fehlern finden, reproduzieren, minimal beheben | lesen, editieren, Bash |
| [`test-writer`](.claude/agents/test-writer.md) | Aussagekräftige Tests schreiben und ausführen | lesen, schreiben, Bash |
| [`researcher`](.claude/agents/researcher.md) | Web-Recherche mit Quellenbewertung, Belegen und Evidenzstufen (Gesichert / Gut belegt / Hypothese / Spekulation) – für Technik ebenso wie für Wissenschaft | Web + lesen |
| [`bericht-pruefer`](.claude/agents/bericht-pruefer.md) | Prüft einen Bericht des `researcher` gegen dessen Regeln (Aufbau, Evidenzstufen, Quellen, Ton) – ohne Webzugriff, also Konsistenz, nicht Wahrheit | nur lesen |
| [`github-maintainer`](.claude/agents/github-maintainer.md) | Branch, Commit, Push, Pull Request als Entwurf, Issue-Kommentare – merged nie; Pushes nur auf ein Branch-Präfix, abgesichert durch den Hook `push-waechter` | lesen, schreiben, Bash, GitHub |
| [`architect`](.claude/agents/architect.md) | Features und Projekte planen, Optionen vergleichen – ändert keinen Code | lesen + Web |
| [`doc-writer`](.claude/agents/doc-writer.md) | README, Docstrings, Anleitungen auf Deutsch | lesen, schreiben |
| [`snow-ai`](.claude/agents/snow-ai.md) | Persönlicher Recherche- und Alltagsassistent: begrenzte Recherche mit Belegen, Belegprüfung, Entscheidungshilfe | Web + lesen (bewusst ohne Schreibrechte) |
| [`agent-teacher`](.claude/agents/agent-teacher.md) | Lehrt Agenten, Prompts und Skills in Schritten mit Beispiel und Übungsaufgabe, prüft Fakten in der Doku | Web + lesen + schreiben (ohne Shell und GitHub) |

**Modelle:** Jeder Agent legt sein Modell im Frontmatter fest, statt dem Modell der Sitzung zu folgen. `opus` für Urteil, Planung und Quellen – `researcher`, `architect`, `code-reviewer`, `debugger`; `sonnet` für feste Abläufe – `bericht-pruefer`, `github-maintainer`, `test-writer`, `doc-writer`, `agent-teacher`, `snow-ai`. Ändern lässt sich das pro Agent in der Zeile `model:`.

### Skills (`.claude/skills/`)

Skills sind Anleitungen, die Claude bei passender Aufgabe in den laufenden Kontext lädt.

| Skill | Wofür |
|---|---|
| [`git-commit`](.claude/skills/git-commit/SKILL.md) | Saubere Commits nach Conventional Commits, inkl. Secret-Check |
| [`python-projekt-setup`](.claude/skills/python-projekt-setup/SKILL.md) | Neues Python-Projekt mit src-Layout, pyproject, .env, pytest, ruff |
| [`agent-anlegen`](.claude/skills/agent-anlegen/SKILL.md) | Neue Agents/Skills nach den Konventionen dieses Repos anlegen |
| [`code-erklaeren`](.claude/skills/code-erklaeren/SKILL.md) | Code und Fehlermeldungen verständlich erklären |
| [`pr-beschreibung`](.claude/skills/pr-beschreibung/SKILL.md) | PR-Beschreibung aus Commits und Diff eines Branches schreiben |
| [`ideen-werkstatt`](.claude/skills/ideen-werkstatt/SKILL.md) | Ideen im Dialog entwickeln: breit sammeln, kritisch bewerten (mit größter Schwäche je Idee), die beste zum One-Pager mit erstem 30-Minuten-Schritt und Abbruchkriterium ausarbeiten; übergibt an `researcher` und `architect` |

## Installation

### Global (in allen Projekten verfügbar)

```bash
git clone https://github.com/arseniyvaneev-spacy/claude-Agent.git
cd claude-Agent
./scripts/install.sh
```

Das legt Symlinks in `~/.claude/agents/`, `~/.claude/skills/` und `~/.claude/hooks/` an. Ein `git pull` aktualisiert damit automatisch alle Projekte.

Die Hooks braucht der `github-maintainer`: Ohne installierten `push-waechter` sperrt er alle Pushes, statt ungeschützt zu pushen. Erlaubt sind standardmäßig nur Branches unter `claude/`; ein anderes Präfix setzt du über die Umgebungsvariable `PUSH_WAECHTER_PREFIX` (z. B. `feature/`, muss mit `/` enden). Der Wächter fängt Versehen ab, ist aber keine Sicherheitsgrenze – die harte Grenze ist ein Ruleset auf dem Default-Branch in GitHub.

| Option | Wirkung |
|---|---|
| `--copy` | Kopien statt Symlinks (z. B. unter Windows ohne Symlink-Rechte) |
| `--force` | Vorhandene Dateien mit gleichem Namen überschreiben |

### Nur für ein Projekt

Den Ordner `.claude/` (oder einzelne Dateien daraus) ins Projekt kopieren. Projekt-Agents haben Vorrang vor globalen mit gleichem Namen.

### Prüfen

In Claude Code `/agents` eingeben – die Agents sollten in der Liste auftauchen.

## Nutzung

Claude wählt Agents und Skills **automatisch** anhand ihrer `description`. Du kannst sie auch direkt ansprechen:

```
> Lass den code-reviewer über meine letzten Änderungen schauen
> Nutze den researcher: Welche Python-Bibliothek eignet sich für Telegram-Bots?
> Plane mit dem architect eine Bewerbungs-Tracking-App
```

## Eigene Agents und Skills hinzufügen

1. In Claude Code sagen: *„Leg einen neuen Agenten für … an“* – der Skill `agent-anlegen` kennt die Vorlagen.
   Oder manuell nach der Vorlage in [`agent-anlegen/SKILL.md`](.claude/skills/agent-anlegen/SKILL.md).
2. Prüfen (läuft in Claude Code nach jeder Änderung an Agents/Skills automatisch per Hook, und bei jedem Pull Request in GitHub Actions):
   ```bash
   ./scripts/validate.sh
   .claude/hooks/push-waechter.test.sh   # nur nötig, wenn der Push-Wächter geändert wurde
   ```
3. Tabelle oben ergänzen, committen.

## Projektstruktur

```
.
├── .claude/
│   ├── agents/          # ein Subagent pro .md-Datei
│   ├── skills/          # ein Ordner pro Skill mit SKILL.md
│   ├── hooks/           # Hook-Skripte (validate-nach-aenderung.sh, push-waechter.* mit Tests)
│   └── settings.json    # Projekt-Hooks (prüft Agents/Skills) + Leseverbot für Secrets
├── .github/workflows/
│   └── pruefen.yml      # bei jedem PR: validate.sh + Tests des Push-Wächters
├── scripts/
│   ├── install.sh       # installiert nach ~/.claude
│   └── validate.sh      # prüft Frontmatter aller Agents/Skills
├── CLAUDE.md            # Regeln für Claude beim Arbeiten in diesem Repo
└── README.md
```
