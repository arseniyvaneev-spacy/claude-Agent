---
name: code-erklaeren
description: Erklärt Code, Projekte oder Fehlermeldungen verständlich und auf Augenhöhe – vom Überblick bis zum Mechanismus. Verwenden, wenn gefragt wird „was macht das?“, „wie funktioniert das?“ oder „erklär mir diesen Code/Fehler“.
---

# Code erklären

## Grundhaltung

Auf Augenhöhe erklären: verständlich, aber nicht oberflächlich. Fachbegriffe verwenden und beim ersten Auftreten kurz erklären. Nicht jede Zeile nacherzählen.

## Ablauf

1. **Einordnen** (1–2 Sätze): Wozu ist der Code da? Welches Problem löst er?
2. **Grobstruktur**: Die wichtigsten Teile und wie sie zusammenhängen. Bei mehreren Dateien eine kleine Übersicht:
   ```
   main.py → lädt config.py → startet bot.py → nutzt handlers/*.py
   ```
3. **Ablauf an einem Beispiel**: Einen konkreten Durchlauf verfolgen („Wenn ein Nutzer /start schickt, passiert …“).
4. **Kernmechanismen**: Die 2–3 nicht offensichtlichen Stellen genauer erklären (Algorithmus, Muster, Bibliotheksmagie). Hier lohnt sich Tiefe.
5. **Auffälligkeiten**: Bugs, Risiken, seltsame Stellen ehrlich benennen – kurz. Wo möglich mit einem kleinen Test belegen (in einer Wegwerfkopie, nie im echten Projekt), statt nur zu vermuten; was nicht getestet wurde, als Vermutung kennzeichnen.
6. **Zum Ausprobieren** (optional): Ein kleines Experiment, mit dem man das Verständnis prüfen kann („Ändere X auf Y und beobachte Z“).

## Bei Fehlermeldungen

1. Übersetzen: Was sagt die Meldung wörtlich?
2. Bedeutung: Was ist tatsächlich schiefgelaufen?
3. Wo: Welche Zeile im eigenen Code (nicht in der Bibliothek) ist der Auslöser? Stacktrace von unten nach oben lesen.
4. Wahrscheinlichste Ursache und Lösung.

## Vermeiden

- Zeile-für-Zeile-Nacherzählung
- Floskeln wie „Das ist ein toller Code!“
- Vereinfachungen, die falsch sind
