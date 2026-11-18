---
name: python-projekt-setup
description: Legt ein neues, sauberes Python-Projekt an – Ordnerstruktur, pyproject.toml, virtuelle Umgebung, .env-Handling, Tests und Linting. Verwenden, wenn ein neues Python-Projekt, Skript-Projekt, Bot oder Tool gestartet werden soll.
---

# Python-Projekt aufsetzen

## 1. Rahmen klären

Frage kurz nach (oder leite aus dem Kontext ab):
- Projektname (wird zu `paketname` in snake_case)
- Art: CLI-Tool, Bot, Web-API, Bibliothek, Skript-Sammlung
- Python-Version (Standard: aktuelle stabile Version, die installiert ist – `python3 --version`)

## 2. Struktur (src-Layout)

```
projektname/
├── src/
│   └── paketname/
│       ├── __init__.py
│       ├── __main__.py      # Einstieg: python -m paketname
│       └── config.py        # liest Umgebungsvariablen
├── tests/
│   ├── __init__.py
│   └── test_basis.py
├── .env.example             # alle Variablen OHNE echte Werte
├── .gitignore
├── pyproject.toml
└── README.md
```

## 3. pyproject.toml

```toml
[project]
name = "projektname"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = []

[project.optional-dependencies]
dev = ["pytest", "ruff"]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.ruff]
line-length = 100

[tool.ruff.lint]
select = ["E", "F", "I", "B", "UP"]

[tool.pytest.ini_options]
testpaths = ["tests"]
```

## 4. Konfiguration & Secrets

- Secrets **nur** über Umgebungsvariablen bzw. `.env` (mit `python-dotenv`), nie im Code.
- `.env` steht in `.gitignore`, `.env.example` wird committet.
- `config.py` liest Variablen zentral und bricht mit klarer Fehlermeldung ab, wenn Pflichtwerte fehlen.

## 5. Umgebung einrichten

Bevorzugt `uv`, falls installiert (`which uv`), sonst `venv` + `pip`:

```bash
# mit uv
uv venv && uv pip install -e ".[dev]"

# ohne uv
python3 -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
```

## 6. Prüfen

```bash
ruff check . && pytest
python -m paketname
```

Erst als fertig melden, wenn beides läuft.

## 7. README

Kurz: was das Projekt macht, Installation (Befehle aus Schritt 5), Start, benötigte Umgebungsvariablen.
