---
name: agent-anlegen
description: Legt einen neuen Claude-Code-Subagenten (.claude/agents/*.md) oder einen neuen Skill (.claude/skills/*/SKILL.md) nach den Konventionen dieses Repos an. Verwenden, wenn ein neuer Agent, Subagent oder Skill erstellt oder ein bestehender überarbeitet werden soll.
---

# Neuen Agenten oder Skill anlegen

## Agent oder Skill?

| | Subagent | Skill |
|---|---|---|
| Was | eigene Instanz mit eigenem Kontext und eigenen Tools | Anleitung, die in den laufenden Kontext geladen wird |
| Gut für | abgeschlossene Aufgaben (Review, Recherche, Debugging) | wiederkehrende Abläufe, Vorlagen, Checklisten |
| Ort | `.claude/agents/<name>.md` | `.claude/skills/<name>/SKILL.md` |

Faustregel: Soll es **eigenständig arbeiten und ein Ergebnis zurückliefern** → Agent. Soll es **Wissen oder einen Ablauf beisteuern** → Skill.

## Subagent – Vorlage

```markdown
---
name: kebab-case-name
description: Was der Agent tut UND wann er eingesetzt werden soll. Für automatische Nutzung „Proaktiv einsetzen, wenn …“ ergänzen.
tools: Read, Grep, Glob        # nur, was wirklich gebraucht wird; weglassen = alle Tools
model: inherit                 # oder sonnet / opus / haiku
---

Du bist … (Rolle in einem Satz)

## Vorgehen
1. …

## Regeln
- …

## Ausgabe
…
```

## Skill – Vorlage

```markdown
---
name: kebab-case-name
description: Was der Skill macht und wann er verwendet werden soll.
---

# Titel

## Schritte
1. …
```

Zusätzliche Dateien (Vorlagen, Skripte, Referenzen) kommen in denselben Skill-Ordner und werden in der SKILL.md mit relativem Pfad erwähnt.

## Qualitätskriterien

- **`name`** = Dateiname bzw. Ordnername, kebab-case, eindeutig.
- **`description`** ist das Wichtigste: Danach entscheidet Claude, ob der Agent/Skill genutzt wird. Konkrete Auslöser nennen.
- **Tools minimal halten**: Ein Review-Agent braucht kein `Write`, ein Planungs-Agent kein `Edit`.
- **Ausgabeformat festlegen**, damit Ergebnisse vergleichbar sind.
- Keine Secrets, keine persönlichen Daten, keine absoluten Pfade.

## Nach dem Anlegen

1. `./scripts/validate.sh` ausführen.
2. Eintrag in der Tabelle im `README.md` ergänzen.
3. Mit dem Skill `git-commit` committen (`feat(agents): …` bzw. `feat(skills): …`).
