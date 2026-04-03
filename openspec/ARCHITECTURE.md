# MotoTracker — Architecture Reference

> **For AI assistants:** This file is the single source of truth for project conventions.
> Read this document AND the feature's `spec.md` before generating any code.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State management | Riverpod (`flutter_riverpod`) |
| Backend / DB | Supabase (PostgreSQL + Auth + Storage) |
| AI | Groq (`llama-3.1-8b-instant`) |
| Navigation | go_router |
| i18n | slang (ES default / EN) |
| Theme | Dark theme with `ThemeTokens` (orange `#FF5722`) |

---

## Folder Structure

```
lib/
├── app/                        # MaterialApp, ProviderScope root
├── core/
│   ├── constants/              # Environment variables (dart-define-from-file)
│   ├── router/                 # app_router.dart (GoRouter provider)
│   ├── theme/                  # ThemeTokens, AppTheme
│   └── utils/                  # Validators, TextFormatters, LocaleController
├── features/
│   ├── ai/                     # AI service (Groq)
│   ├── auth/                   # Authentication (Supabase)
│   ├── garage/                 # Garage and motorcycles
│   └── profile/                # User profile
├── i18n/                       # JSON string files + slang-generated code
├── shared/
│   └── widgets/                # Reusable widgets
└── main.dart
```

### Internal structure of each `feature/`

```
features/<name>/
├── domain/
│   ├── entities/           # Pure Dart classes (no external dependencies)
│   └── repositories/       # Abstract classes (contracts)
├── data/
│   └── supabase_<name>_repository.dart   # Concrete Supabase implementation
└── presentation/
    ├── providers/          # Riverpod providers
    ├── screens/            # Full screens (route root widgets)
    └── widgets/            # Feature-specific widgets
```

---

## Code Conventions

### Entities (Domain)

- Pure Dart classes — **no Flutter or external package imports**.
- Always use `const` constructor.
- Must implement: `copyWith`, `fromJson`, `toJson`, `toInsertJson` (without `id` or `created_at`).
- Singular names: `Motorcycle`, `MaintenanceRecord`, `LegalDocument`.

```dart
// ✅ Correct
class Motorcycle {
  const Motorcycle({ required this.id, ... });

  factory Motorcycle.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
  Map<String, dynamic> toInsertJson() { ... }  // For INSERT (no id, no created_at)
  Motorcycle copyWith({ ... }) { ... }
}
```

### Repositories (Domain)

- Abstract class with `Future<>` and `Stream<>` methods.
- Naming: `<Entity>Repository` (e.g. `MotorcycleRepository`).
- Standard operations: `watchAll`, `getById`, `add`, `update`, `remove`.
- Stream operations: return `Stream<List<Entity>>`.

```dart
abstract class MotorcycleRepository {
  Stream<List<Motorcycle>> watchMotorcycles(String userId);
  Future<Motorcycle?> getById(String id);
  Future<void> add(Motorcycle motorcycle);
  Future<void> update(Motorcycle motorcycle);
  Future<void> remove(String id);
}
```

### Repositories (Data)

- Naming: `Supabase<Entity>Repository`.
- Implements the domain abstract class.
- Receives `SupabaseClient` in the constructor.
- Uses `supabase.from('table_name')` for queries.
- Uses `.stream()` for Supabase Realtime.

### Providers (Presentation)

- One file per feature: `<feature>_providers.dart`.
- `Provider<Repository>` instantiates the repository with the Supabase client.
- `StreamProvider` for real-time lists.
- `FutureProvider.family` for queries by ID.
- `StateNotifierProvider` for complex form state.
- Always depends on `authUserProvider` to filter by `userId`.

```dart
// Standard provider pattern
final motorcycleRepositoryProvider = Provider<MotorcycleRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseMotorcycleRepository(client);
});

final motorcyclesProvider = StreamProvider<List<Motorcycle>>((ref) {
  final authUser = ref.watch(authUserProvider).valueOrNull;
  if (authUser == null) return Stream.value([]);
  final repository = ref.watch(motorcycleRepositoryProvider);
  return repository.watchMotorcycles(authUser.id);
});
```

### Screens and Widgets

- Extend `ConsumerWidget` or `ConsumerStatefulWidget` (never plain `StatefulWidget` when Riverpod is needed).
- Screens receive only primitive parameters (IDs, strings) — not full entities.
- Use `AsyncValueBuilder` from `shared/widgets/` to handle loading/error/data states.
- Never put business logic directly in widgets; everything goes through providers.

### Navigation (go_router)

- Routes defined only in `lib/core/router/app_router.dart`.
- Route pattern: `/<feature>` for main screen, `/<feature>/add` for form, `/<feature>/:id` for detail.
- Custom transitions with `CustomTransitionPage` (slide + fade).
- Router has guards in `redirect` based on `authUserProvider`.

---

## Visual Theme

```dart
// Tokens available in ThemeTokens
ThemeTokens.background        // #121212  — main background
ThemeTokens.surface           // #1E1E1E  — cards, modals
ThemeTokens.surfaceHighlight  // #2A2A2A  — hover, selected
ThemeTokens.primary           // #FF5722  — orange, action color
ThemeTokens.primaryDark       // #E64A19  — dark orange
ThemeTokens.border            // #2C2C2C  — subtle borders
ThemeTokens.success           // #03DAC6  — confirmations
ThemeTokens.textPrimary       // #FFFFFF
ThemeTokens.textSecondary     // #A0A0A0
```

---

## Internationalization (slang)

- JSON files in `lib/i18n/`: `<feature>_es.i18n.json` and `<feature>_en.i18n.json`.
- After adding strings: run `dart run slang` to regenerate `strings.g.dart`.
- Access in code: `context.t.<namespace>.<key>` or `t.<namespace>.<key>` with `AppLocaleUtils`.
- Interpolation: `"deleteConfirmation": "Delete ${name}?"` → `t.garage.deleteConfirmation(name: moto.displayName)`.

---

## Database (Supabase)

- All tables have: `id UUID PRIMARY KEY DEFAULT gen_random_uuid()`, `user_id UUID REFERENCES auth.users`, `created_at TIMESTAMPTZ DEFAULT NOW()`.
- Row Level Security (RLS) enabled on all tables: users can only see/modify their own records.
- Table names in plural snake_case: `motorcycles`, `maintenance_records`, `legal_documents`.
- Column names in snake_case.

### Standard RLS Policy

```sql
-- SELECT / INSERT / UPDATE / DELETE — same logic
CREATE POLICY "Users manage own records" ON <table>
  FOR ALL USING (auth.uid() = user_id);
```

---

## AI (Groq)

- Contract: `AiService` abstract in `features/ai/domain/services/ai_service.dart`.
- Implementation: `GroqAiService` in `features/ai/data/`.
- Prompts in `features/ai/domain/prompts/`.
- Responses always in structured JSON.
- Response language passed as `languageCode` parameter.

---

## SDD Workflow

```
1. Copy  openspec/_templates/feature_spec.md  →  openspec/specs/<name>/spec.md
2. Fill in the spec (30–60 min)
3. Prompt the AI: "Read openspec/ARCHITECTURE.md and openspec/specs/<name>/spec.md, then implement the domain layer"
4. Review generated code against the spec's acceptance criteria
5. Repeat per layer: domain → data → presentation
6. Update FEATURES.md with [x] and a link to the spec
```

---

## Spec File Conventions

- Spec status: `draft` | `ready` | `in-progress` | `implemented`.
- Commit prefix for specs: `spec:` → `spec: add maintenance tracking spec`.
- Every spec must have a `## References` section listing relevant existing files.

