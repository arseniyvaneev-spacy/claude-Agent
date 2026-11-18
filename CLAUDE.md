# CLAUDE.md

Dieses Repo ist eine Sammlung von Claude-Code-Subagenten und -Skills. Es enthält keinen Anwendungscode.

## Konventionen

- Sprache aller Agents, Skills und Doku: **Deutsch**.
- Agents: `.claude/agents/<name>.md`, Skills: `.claude/skills/<name>/SKILL.md`.
- `name` im Frontmatter = Datei- bzw. Ordnername, kebab-case, keine Umlaute.
- `description` nennt immer *was* und *wann* – sie steuert die automatische Auswahl.
- Tools pro Agent minimal halten (Review/Planung ohne `Write`/`Edit`).
- Keine Secrets, persönlichen Daten oder absoluten Pfade in Agents/Skills.

## Bei Änderungen

1. Neue Agents/Skills mit dem Skill `agent-anlegen` erstellen.
2. `./scripts/validate.sh` muss grün sein.
3. Tabelle in `README.md` aktuell halten.
4. Commits nach Conventional Commits (Skill `git-commit`), z. B. `feat(agents): …`, `fix(skills): …`.
