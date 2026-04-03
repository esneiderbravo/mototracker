# Spec: [Feature Name]

> **For the AI assistant:** Read `openspec/ARCHITECTURE.md` first, then this full spec
> before generating any code.

---

## Meta

| Field | Value |
|---|---|
| **Feature** | `features/<name>` |
| **Status** | `draft` \| `ready` \| `in-progress` \| `implemented` |
| **Date** | YYYY-MM-DD |
| **Roadmap ref** | Link or name in FEATURES.md |

---

## Summary

<!-- 2–3 sentences: what this feature does, why it exists, who uses it -->

---

## User Stories

```
As a [type of user]
I want [action or functionality]
so that [benefit or result]
```

- [ ] US-1: ...
- [ ] US-2: ...
- [ ] US-3: ...

---

## Data Model (Domain Entity)

```dart
// lib/features/<name>/domain/entities/<entity>.dart

class <Entity> {
  const <Entity>({
    required this.id,
    required this.userId,
    required this.field1,      // Description and constraints
    required this.field2,      // Description and constraints
    // ...
    required this.createdAt,
  });

  final String id;
  final String userId;
  final <Type> field1;
  final <Type> field2;
  // ...
  final DateTime createdAt;

  // Relevant computed getters
  String get displayName => '...';
}
```

### Domain Constraints

- `field1`: required, max 100 characters.
- `field2`: must be positive, unit in km.
- _(list all business rules here)_

---

## Repository Contract (Domain)

```dart
// lib/features/<name>/domain/repositories/<entity>_repository.dart

abstract class <Entity>Repository {
  Stream<List<<Entity>>> watch<Entities>(String userId);
  Future<<Entity>?> getById(String id);
  Future<void> add(<Entity> entity);
  Future<void> update(<Entity> entity);
  Future<void> remove(String id);
  // Additional methods specific to this feature:
  // Future<List<<Entity>>> getByMotorcycleId(String motorcycleId);
}
```

---

## Supabase Schema (Data)

### Table: `<table_name>`

```sql
CREATE TABLE <table_name> (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  motorcycle_id UUID REFERENCES motorcycles(id) ON DELETE CASCADE,
  field1        TEXT NOT NULL,
  field2        INTEGER NOT NULL DEFAULT 0,
  -- ...
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS
ALTER TABLE <table_name> ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own <table_name>" ON <table_name>
  FOR ALL USING (auth.uid() = user_id);
```

### Column ↔ Dart Field Mapping

| SQL Column | Dart Field | SQL Type | Dart Type |
|---|---|---|---|
| `id` | `id` | UUID | String |
| `user_id` | `userId` | UUID | String |
| `field1` | `field1` | TEXT | String |
| `field2` | `field2` | INTEGER | int |
| `created_at` | `createdAt` | TIMESTAMPTZ | DateTime |

---

## Providers (Riverpod)

```dart
// lib/features/<name>/presentation/providers/<name>_providers.dart

// 1. Repository provider
final <entity>RepositoryProvider = Provider<<Entity>Repository>((ref) { ... });

// 2. Real-time list
final <entities>Provider = StreamProvider<List<<Entity>>>((ref) { ... });

// 3. By ID
final <entity>ByIdProvider = FutureProvider.family<<Entity>?, String>((ref, id) { ... });

// 4. (Optional) Notifier for form state
class Add<Entity>Notifier extends StateNotifier<AsyncValue<void>> { ... }
final add<Entity>Provider = StateNotifierProvider<Add<Entity>Notifier, AsyncValue<void>>(...);
```

---

## Screens and Widgets

### Screens

| Screen | Route | Description |
|---|---|---|
| `<Name>ListScreen` | `/<name>` | List with states: loading / empty / error / data |
| `Add<Name>Screen` | `/<name>/add` | Creation form |
| `<Name>DetailScreen` | `/<name>/:id` | Detail with actions |

### UI States per Screen

**`<Name>ListScreen`**
- 🔄 Loading: skeleton cards or `CircularProgressIndicator`
- 📭 Empty: illustration + message + "Add" CTA
- ❌ Error: error message + "Retry" button
- ✅ Data: list of cards using `<Name>Card` widget

**`Add<Name>Screen`**
- Form fields with validators
- Save button with loading state
- Success/error toast on save

**`<Name>DetailScreen`**
- Hero / header
- Information sections
- (Optional) AI Insights
- Danger zone with delete button + confirmation dialog

### Internal Widgets

- `<Entity>Card` — list card
- `<Entity>InfoTile` — info tile (label + value)
- _(add other feature-specific widgets here)_

---

## Routes (go_router)

Add to `lib/core/router/app_router.dart`:

```dart
GoRoute(
  path: '/<name>',
  builder: (context, state) => const <Name>ListScreen(),
  routes: [
    GoRoute(
      path: 'add',
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: const Add<Name>Screen(),
        transitionsBuilder: _slideAndFade,  // reuse existing helper
      ),
    ),
    GoRoute(
      path: ':id',
      builder: (_, state) => <Name>DetailScreen(id: state.pathParameters['id']!),
    ),
  ],
),
```

---

## i18n Strings

### `lib/i18n/<name>_es.i18n.json`

```json
{
  "title": "...",
  "add<Name>": "Agregar ...",
  "empty": "No hay ... registrados",
  "deleteConfirmation": "¿Eliminar ${name}? Esta acción no se puede deshacer.",
  "saveSuccess": "... guardado correctamente.",
  "saveError": "No se pudo guardar. Por favor intenta de nuevo.",
  "notFound": "... no encontrado"
}
```

### `lib/i18n/<name>_en.i18n.json`

```json
{
  "title": "...",
  "add<Name>": "Add ...",
  "empty": "No ... registered yet",
  "deleteConfirmation": "Delete ${name}? This action cannot be undone.",
  "saveSuccess": "... saved successfully.",
  "saveError": "Could not save. Please try again.",
  "notFound": "... not found"
}
```

> After editing JSON files: run `dart run slang` to regenerate `strings.g.dart`.

---

## AI Integration (if applicable)

### New method in `AiService`

```dart
// Add to lib/features/ai/domain/services/ai_service.dart
Future<List<String>> generate<Name>Suggestions({
  required String languageCode,
  required String field1,
  // ...
});
```

### Prompt

```
You are an expert motorcycle assistant.
Given: [context]
Generate: [expected output]
Respond ONLY with valid JSON in this format:
{"suggestions": ["...", "...", "..."]}
Respond in the language indicated by languageCode: {languageCode}
```

---

## Acceptance Criteria

- [ ] AC-1: The user can view their list of `<entities>`.
- [ ] AC-2: The list updates in real time (Supabase Realtime).
- [ ] AC-3: The user can add a new `<entity>` via the form.
- [ ] AC-4: The form validates all required fields.
- [ ] AC-5: The user can delete a `<entity>` with a confirmation dialog.
- [ ] AC-6: All text is available in both ES and EN.
- [ ] AC-7: Loading / empty / error states render correctly.
- [ ] AC-8: Navigation works correctly with go_router.

---

## Constraints and Edge Cases

- What happens if the user has no motorcycles yet? → Show empty state.
- What happens if connection drops during save? → Show error with retry.
- Is there a record limit per user? → Define if applicable.
- Are records deleted when the associated motorcycle is removed? → CASCADE on FK.

---

## References

Existing files the AI should read for context:

- `openspec/ARCHITECTURE.md`
- `lib/features/garage/domain/entities/motorcycle.dart` — reference entity
- `lib/features/garage/domain/repositories/motorcycle_repository.dart` — repository pattern
- `lib/features/garage/data/supabase_motorcycle_repository.dart` — implementation pattern
- `lib/features/garage/presentation/providers/garage_providers.dart` — providers pattern
- `lib/core/router/app_router.dart` — to add routes
- `lib/i18n/garage_es.i18n.json` — string format reference

