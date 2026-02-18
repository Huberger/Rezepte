# Rezepte

Eine SwiftUI App (iOS 17+) zum Verwalten von Rezeptfotos mit SwiftData. Enthält:
- Models: Recipe, Category
- Liste mit Suche & Sortierung
- Hinzufügen-Formular mit PhotosPicker
- Detailansicht mit Zoom und editierbaren Bemerkungen
- Bildkompression beim Speichern
- Export (JSON + Bilder -> ZIP) via ShareSheet

Anleitung zum Öffnen:
1. Repository klonen: `git clone https://github.com/Huberger/Rezepte.git`
2. In Xcode ein neues iOS App-Projekt (App, SwiftUI, Swift, iOS 17) anlegen und die Dateien aus `Sources/` in das Projekt ziehen.
3. Deployment Target: iOS 17.0

Import deiner Bilder:
- Füge die Bilder über die Fotomediathek in der App hinzu (PhotosPicker) oder importiere sie in die Photos‑App deines iPad und wähle sie in der App.

---

**Hinweis**: Informationen zum Konversationsverlauf mit GitHub Copilot finden Sie in [CONVERSATION_HISTORY.md](CONVERSATION_HISTORY.md).