# Agenten

Agent Teacher und Snow AI leben in diesem Repository als **Claude-Code-Agenten**:

| Agent | Datei | Werkzeuge |
|---|---|---|
| Agent Teacher | `.claude/agents/agent-teacher.md` | Read, Grep, Glob, WebSearch, WebFetch |
| Snow AI | `.claude/agents/snow-ai.md` | Read, Grep, Glob, WebSearch, WebFetch |

Beide sind nur lesend: Sie haben kein Schreib-, Shell- oder GitHub-Schreibwerkzeug. Das ist technisch erzwungen, nicht nur eine Prompt-Regel.

## Benutzen
In jeder Claude-Code-Session mit diesem Repo (Terminal, Web, App), z. B.:
- „Lass Snow AI recherchieren, ob …“
- „Agent Teacher, erklär mir Subagents.“
- oder `@agent-snow-ai` / `@agent-agent-teacher` erwähnen.

## Archiv
`agent-teacher/` und `snow-ai/` enthalten die frühere ElevenLabs-Konfiguration (Sprachagenten) und `snow-ai/charakter-profil.md`, die Vorlage für Snow AI.
