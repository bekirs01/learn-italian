# Learn Italian for Beginners

Premium offline Italian learning app for iPhone, iPad, and Apple Watch. No account required.

Target language: Italian (`it`, `it-IT`). Learner UI and glosses follow the Translation Language setting.

## Technology

Flutter and Dart. iOS-first, Android compatible. Offline-first. No backend, Firebase, Supabase, authentication, ads, or analytics.

## Run

```bash
flutter pub get
flutter run
```

Then:

```bash
dart format .
flutter analyze
flutter test
```

## How the layers fit

| Layer | Where | What it does |
| --- | --- | --- |
| Product identity | `assets/product.json` | Name, accent, writing system, direction, translation languages, `alphabet` / `audio` flags |
| Target-language content | `assets/content/*.json` | Glyphs, words, phrases, optional romanization and audio IDs |
| Learner meanings | `assets/content/translations/<code>.json` | Gloss of each content ID in the learner's language |
| UI chrome | `lib/core/l10n/` | Nav, settings, quiz, empty states |

Switching Translation Language changes learner glosses and UI chrome. It never replaces the target-language `text` / `glyph`.

## Feature flags

- `alphabet`: when false (or `writingSystem` is `other`), the Alphabet tab stays but shows an empty inventory.
- `audio`: when true, play controls speak the target language (bundled recording if present, otherwise native TTS). UI sound effects are separate and gated by Settings.

Romanization is not a flag. If a row has a `romanization` value distinct from `pronunciation`, Alphabet shows it.

## Quiz

Words, phrases, and alphabet units with `quizEnabled: true` feed the in-app Quiz. Launch a mixed session from Home, or a words/phrases session from those tabs. Alphabet items only use recognition modes.

## Principles

- English-only code, comments, docs, identifiers, and base UI copy
- Modular, reusable architecture; data-driven learning content
- Small widgets, no duplicated business logic, `const` where it belongs
- Premium UI with motion, depth, sound, and haptics that stay fast and accessible
- No extra packages or architecture changes without an explicit reason
