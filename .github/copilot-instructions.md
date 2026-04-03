# MotoTracker — Copilot Instructions

You are an AI coding assistant working on **MotoTracker**, a Flutter app for motorcycle tracking.

## Before writing any code

1. Read `openspec/ARCHITECTURE.md` — it contains all project conventions (folder structure, naming, patterns, theme tokens, i18n, routing).
2. If a feature spec exists at `openspec/features/<name>/spec.md`, read it entirely before implementing anything.

## Project conventions (summary)

- **Architecture:** Clean Architecture per feature — `domain/` (entities + repositories) → `data/` (Supabase impl) → `presentation/` (providers + screens + widgets).
- **State management:** Riverpod only. Use `ConsumerWidget` / `ConsumerStatefulWidget`. Never use `setState` when Riverpod is available.
- **Navigation:** `go_router` only. All routes live in `lib/core/router/app_router.dart`.
- **Theme:** Always use `ThemeTokens` constants. Never hardcode colors or font sizes.
- **i18n:** All user-facing strings go in `lib/i18n/<feature>_es.i18n.json` AND `lib/i18n/<feature>_en.i18n.json`. Run `dart run slang` after editing.
- **Entities:** Pure Dart, `const` constructor, implement `copyWith` + `fromJson` + `toJson` + `toInsertJson`.
- **Repositories:** Abstract class in `domain/repositories/`, Supabase implementation named `Supabase<Entity>Repository` in `data/`.
- **Screens:** Receive only primitive parameters (IDs, strings), not full entities.
- **Async UI:** Use the existing `AsyncValueBuilder` widget from `shared/widgets/` for loading/error/data states.

## Stack

Flutter · Dart · Riverpod · Supabase · go_router · slang · Groq AI

## Folder quick-reference

```
lib/features/<name>/
├── domain/entities/          ← Pure Dart entity class
├── domain/repositories/      ← Abstract repository
├── data/                     ← SupabaseXxxRepository
└── presentation/
    ├── providers/             ← Riverpod providers
    ├── screens/               ← Full-page widgets
    └── widgets/               ← Feature-specific components
```

## When adding a new feature

1. Check `openspec/features/<name>/spec.md` for entity shape, repository contract, providers, routes, and i18n keys.
2. Implement layers in order: **domain → data → presentation**.
3. Register routes in `lib/core/router/app_router.dart`.
4. Add string keys to both `_es.i18n.json` and `_en.i18n.json`, then run `dart run slang`.
5. Update `FEATURES.md` — move the item from Roadmap to Implemented with `[x]`.

