#!/usr/bin/env python3
"""PreToolUse-Wächter für den github-maintainer-Agenten.

Erlaubt `git push` nur auf Branches mit einem festen Präfix (Standard:
`claude/`) und lehnt alles ab, was er nicht sicher zerlegen kann.
Exit-Code 2 blockiert den Tool-Aufruf und zeigt stderr an Claude, Exit 0
lässt ihn durch.

Prinzip: Erlaubnisliste statt Verbotsliste, im Zweifel blockieren. Ein Push
muss Remote und Ziel ausdrücklich nennen, und das Ziel muss mit dem Präfix
beginnen. Ein nacktes `git push`, dessen Ziel aus der Git-Konfiguration käme,
wird abgelehnt.

Das Präfix lässt sich über die Umgebungsvariable PUSH_WAECHTER_PREFIX ändern,
z. B. "feature/". Es muss mit "/" enden. Ein leeres oder ungültiges Präfix
sperrt alle Pushes, statt alle zu erlauben.

Das ist ein Schutz gegen Versehen, keine Sicherheitsgrenze: Er läuft im selben
Prozess, der die Befehle erzeugt. Die harte Grenze ist der Branch-Schutz auf
GitHub (Ruleset auf dem Default-Branch).
"""

import json
import os
import re
import shlex
import sys

SELF = "push-waechter"

PREFIX = os.environ.get("PUSH_WAECHTER_PREFIX", "claude/")
PREFIX_OK = re.fullmatch(r"[A-Za-z0-9._\-]+(?:/[A-Za-z0-9._\-]+)*/", PREFIX) is not None

# Push-Optionen, die Remote-Zustand umschreiben oder zerstören, egal wohin.
FORBIDDEN_PUSH_OPTS = (
    "--force",
    "--force-with-lease",
    "--force-if-includes",
    "--delete",
    "--mirror",
    "--all",
    "--prune",
)

# Git-Unterbefehle, die Historie umschreiben oder Refs direkt verschieben.
FORBIDDEN_SUBCOMMANDS = ("filter-branch", "filter-repo", "update-ref", "symbolic-ref")

# Tokens, hinter denen eine verschachtelte Shell steckt, die wir nicht prüfen können.
NESTED_SHELL = ("eval", "bash", "sh", "zsh", "dash", "xargs", "env")

SHELL_OPERATORS = {"&&", "||", ";", "|", "&", "\n"}


def block(reason):
    print(f"Blockiert durch {SELF}: {reason}", file=sys.stderr)
    sys.exit(2)


def read_command():
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw)
    except (ValueError, TypeError):
        # Nicht das erwartete Format: den Rohtext prüfen, statt ihm zu trauen.
        return raw
    tool_input = payload.get("tool_input") or {}
    if not isinstance(tool_input, dict):
        return raw
    return tool_input.get("command") or ""


def tokenize(cmd):
    """Zerlegt einen Shell-Befehl; Operatoren bleiben eigene Tokens."""
    lexer = shlex.shlex(cmd, posix=True, punctuation_chars=True)
    lexer.whitespace_split = True
    return list(lexer)


def segments(tokens):
    """Teilt die Token-Liste an Shell-Operatoren in einzelne Befehle."""
    out, current = [], []
    for token in tokens:
        if token in SHELL_OPERATORS:
            if current:
                out.append(current)
            current = []
        else:
            current.append(token)
    if current:
        out.append(current)
    return out


def allowed_dest(target):
    name = target[len("refs/heads/"):] if target.startswith("refs/heads/") else target
    return (
        name.startswith(PREFIX)
        and len(name) > len(PREFIX)
        and re.fullmatch(r"[A-Za-z0-9._\-/]+", name) is not None
    )


def check_push(seg):
    """Prüft einen `git push`-Befehl. Kehrt bei Erfolg zurück, blockiert sonst."""
    if not PREFIX_OK:
        block(
            f"PUSH_WAECHTER_PREFIX ist ungültig ({PREFIX!r}); es darf nicht leer "
            "sein und muss mit '/' enden, z. B. 'claude/'. Bis dahin sind alle "
            "Pushes gesperrt."
        )

    idx = seg.index("push")
    args = seg[idx + 1 :]

    for arg in args:
        for opt in FORBIDDEN_PUSH_OPTS:
            if arg == opt or arg.startswith(opt + "="):
                block(f"`{opt}` ist bei einem Push nicht erlaubt.")
        # Kurzoptionen: -f (force), -d (delete). -u und andere sind in Ordnung.
        if re.fullmatch(r"-[A-Za-z]+", arg):
            if "f" in arg[1:]:
                block("Force-Push ist nicht erlaubt.")
            if "d" in arg[1:]:
                block("Remote-Branches zu löschen ist nicht erlaubt.")

    positional = [a for a in args if not a.startswith("-")]
    if not positional:
        block(
            "ein Push muss Remote und Branch nennen, z. B. "
            f"`git push -u origin {PREFIX}mein-thema`; ein nacktes `git push` "
            "nimmt sein Ziel aus der Git-Konfiguration und ist nicht erlaubt."
        )

    refspecs = positional[1:]
    if not refspecs:
        block(
            "ein Push muss den Branch ausdrücklich nennen, z. B. "
            f"`git push -u origin {PREFIX}mein-thema`."
        )

    for spec in refspecs:
        if spec.startswith("+"):
            block(f"erzwungene Refspec `{spec}` ist nicht erlaubt.")
        src, sep, dest = spec.partition(":")
        target = dest if sep else src
        if sep and not src:
            block(f"Refspec `{spec}` löscht einen Remote-Branch; nicht erlaubt.")
        if not target:
            block(f"Refspec `{spec}` hat kein Ziel; nicht erlaubt.")
        if ".." in target:
            block(f"Push-Ziel `{target}` enthält `..`; nicht erlaubt.")
        if not allowed_dest(target):
            block(
                f"Push-Ziel `{target}` liegt außerhalb der Erlaubnisliste. "
                f"Erlaubt sind nur Branches unter `{PREFIX}`; alles andere "
                "kommt per Pull Request auf andere Branches."
            )


def main():
    cmd = read_command()
    if not cmd or "git" not in cmd:
        sys.exit(0)

    try:
        tokens = tokenize(cmd)
    except ValueError:
        # Z. B. unbalancierte Anführungszeichen. Erwähnt der Befehl einen Push, ablehnen.
        if "push" in cmd:
            block("Befehl nicht zerlegbar; ein darin enthaltener Push wird abgelehnt.")
        sys.exit(0)

    # Ein einzelnes Token mit `git` und `push` ist ein verschachtelter Befehlsstring,
    # z. B. bash -c "git push origin main". Den prüfen wir nicht, wir lehnen ihn ab.
    for token in tokens:
        if "git" in token and "push" in token and token not in ("git", "push"):
            block(
                "ein Push in einem Befehlsstring kann nicht geprüft werden; "
                "`git push` bitte direkt ausführen."
            )

    mentions_push = "push" in tokens

    for seg in segments(tokens):
        if "git" not in seg:
            continue

        for sub in FORBIDDEN_SUBCOMMANDS:
            if sub in seg:
                block(f"`git {sub}` ist nicht erlaubt.")

        if "push" not in seg:
            continue

        if any(t in NESTED_SHELL for t in seg):
            block(
                "ein Push in einer weiteren Shell kann nicht geprüft werden; "
                "`git push` bitte direkt ausführen."
            )

        check_push(seg)
        mentions_push = False  # dieser wurde geprüft

    if mentions_push:
        # Ein Push, den die Zerlegung nicht erreicht hat (seltsame Quotes, Substitution …).
        block("der Push-Befehl ließ sich nicht finden und prüfen; abgelehnt.")

    sys.exit(0)


if __name__ == "__main__":
    main()
