# Spec: Maintenance Tracking

> **For the AI assistant:** Read `openspec/ARCHITECTURE.md` AND this full spec before generating any code.
> The garage feature (`openspec/specs/garage/spec.md`) is your primary pattern reference.

---

## Meta

| Field | Value |
|---|---|
| **Feature** | `features/maintenance` |
| **Status** | `ready` |
| **Date** | 2026-04-02 |
| **Roadmap ref** | `FEATURES.md → 🔧 Maintenance Tracking` |

---

## Summary

Maintenance Tracking lets users log maintenance records for each motorcycle (oil changes, brakes, chain, filters, etc.), view history by date and mileage, and receive AI-generated suggestions for pending maintenance based on current km and motorcycle model.

---

## User Stories

- [ ] US-1: As a user I want to log a maintenance record on a motorcycle so I can track what has been done and when.
- [ ] US-2: As a user I want to see the full maintenance history of a motorcycle, sorted by date, so I can review past work.
- [ ] US-3: As a user I want the AI to suggest pending maintenance based on current km and motorcycle model so I know what to do next.
- [ ] US-4: As a user I want to delete a maintenance record with confirmation so I can correct mistakes.

---

## Data Model (Domain Entity)

```dart
// lib/features/maintenance/domain/entities/maintenance_record.dart

class MaintenanceRecord {
  const MaintenanceRecord({
    required this.id,
    required this.userId,
    required this.motorcycleId,  // FK to motorcycles.id
    required this.type,          // MaintenanceType enum
    required this.description,   // Free-text notes, max 500 chars
    required this.performedAtKm, // Mileage at which it was performed, >= 0
    required this.performedAt,   // Date when maintenance was done
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String motorcycleId;
  final MaintenanceType type;
  final String description;
  final int performedAtKm;
  final DateTime performedAt;
  final DateTime createdAt;

  String get displayTitle => '${type.label} @ ${performedAtKm}km';
}

enum MaintenanceType {
  oilChange,
  brakes,
  chain,
  airFilter,
  tires,
  sparkPlugs,
  coolant,
  battery,
  general,
  other;

  String get label => switch (this) {
    MaintenanceType.oilChange   => 'Oil Change',
    MaintenanceType.brakes      => 'Brakes',
    MaintenanceType.chain       => 'Chain',
    MaintenanceType.airFilter   => 'Air Filter',
    MaintenanceType.tires       => 'Tires',
    MaintenanceType.sparkPlugs  => 'Spark Plugs',
    MaintenanceType.coolant     => 'Coolant',
    MaintenanceType.battery     => 'Battery',
    MaintenanceType.general     => 'General Service',
    MaintenanceType.other       => 'Other',
  };
}
```

### Domain Constraints

- `motorcycleId`: must reference an existing motorcycle owned by the same user.
- `performedAtKm`: must be >= 0; should be <= motorcycle's current km.
- `description`: optional, max 500 characters.
- `performedAt`: cannot be in the future.
- `type`: required, must be a valid `MaintenanceType`.

---

## Repository Contract (Domain)

```dart
// lib/features/maintenance/domain/repositories/maintenance_record_repository.dart

abstract class MaintenanceRecordRepository {
  /// Returns all maintenance records for a motorcycle, ordered by performedAt DESC.
  Stream<List<MaintenanceRecord>> watchByMotorcycle(String motorcycleId);

  Future<MaintenanceRecord?> getById(String id);
  Future<void> add(MaintenanceRecord record);
  Future<void> update(MaintenanceRecord record);
  Future<void> remove(String id);

  /// Returns the most recent record for each MaintenanceType for a motorcycle.
  Future<Map<MaintenanceType, MaintenanceRecord>> getLatestByType(String motorcycleId);
}
```

---

## Supabase Schema (Data)

### Table: `maintenance_records`

```sql
CREATE TABLE maintenance_records (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  motorcycle_id    UUID NOT NULL REFERENCES motorcycles(id) ON DELETE CASCADE,
  type             TEXT NOT NULL,             -- MaintenanceType enum value (snake_case)
  description      TEXT NOT NULL DEFAULT '',
  performed_at_km  INTEGER NOT NULL DEFAULT 0,
  performed_at     DATE NOT NULL,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE maintenance_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own maintenance_records" ON maintenance_records
  FOR ALL USING (auth.uid() = user_id);

-- Index for fast history queries
CREATE INDEX idx_maintenance_motorcycle ON maintenance_records(motorcycle_id, performed_at DESC);
```

### Column ↔ Dart Field Mapping

| SQL Column | Dart Field | SQL Type | Dart Type |
|---|---|---|---|
| `id` | `id` | UUID | String |
| `user_id` | `userId` | UUID | String |
| `motorcycle_id` | `motorcycleId` | UUID | String |
| `type` | `type` | TEXT | MaintenanceType |
| `description` | `description` | TEXT | String |
| `performed_at_km` | `performedAtKm` | INTEGER | int |
| `performed_at` | `performedAt` | DATE | DateTime |
| `created_at` | `createdAt` | TIMESTAMPTZ | DateTime |

> `MaintenanceType` serialization: use `type.name` (e.g. `"oilChange"`) for `toJson`; parse with `MaintenanceType.values.byName(json['type'])` in `fromJson`.

---

## Providers (Riverpod)

```dart
// lib/features/maintenance/presentation/providers/maintenance_providers.dart

final maintenanceRepositoryProvider = Provider<MaintenanceRecordRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseMaintenanceRecordRepository(client);
});

// Real-time history for a specific motorcycle
final maintenanceByMotorcycleProvider =
    StreamProvider.family<List<MaintenanceRecord>, String>((ref, motorcycleId) {
  return ref.watch(maintenanceRepositoryProvider).watchByMotorcycle(motorcycleId);
});

// AI suggestions notifier
class MaintenanceSuggestionsNotifier extends StateNotifier<AsyncValue<List<String>>> {
  MaintenanceSuggestionsNotifier(this._aiService) : super(const AsyncValue.data([]));

  final AiService _aiService;

  Future<void> loadSuggestions({
    required String languageCode,
    required String make,
    required String model,
    required int year,
    required int currentKm,
    required List<MaintenanceRecord> recentRecords,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _aiService.generateMaintenanceSuggestions(
      languageCode: languageCode,
      make: make,
      model: model,
      year: year,
      currentKm: currentKm,
      recentRecords: recentRecords,
    ));
  }
}

final maintenanceSuggestionsProvider = StateNotifierProvider.family<
    MaintenanceSuggestionsNotifier, AsyncValue<List<String>>, String>(
  (ref, motorcycleId) => MaintenanceSuggestionsNotifier(ref.watch(aiServiceProvider)),
);
```

---

## Screens and Widgets

### Screens

| Screen | Route | Description |
|---|---|---|
| `MaintenanceListScreen` | `/garage/:id/maintenance` | History list for a motorcycle |
| `AddMaintenanceScreen` | `/garage/:id/maintenance/add` | Add new record form |

> The maintenance section is accessed from `MotorcycleDetailScreen` via a button/tab — it is not a standalone bottom-nav item.

### UI States

**`MaintenanceListScreen`**
- 🔄 Loading: skeleton list
- 📭 Empty: "No maintenance records yet" + "Log First Service" CTA
- ❌ Error: error message + "Retry" button
- ✅ Data: grouped list by month, each item shows type icon, date, km, description

**`AddMaintenanceScreen`**
- `MaintenanceType` dropdown / chip selector
- Date picker (`performedAt`)
- Mileage field (digits only, pre-filled with current motorcycle km)
- Description text area (optional, 500 char limit)
- Save button with loading state
- AI Suggestions card: "Based on your km, consider also: ..." (auto-loads on screen open)

### Internal Widgets

- `MaintenanceRecordCard` — card showing type icon, date, km, short description
- `MaintenanceTypeChip` — selectable chip for maintenance type
- `MaintenanceSuggestionsCard` — AI suggestions with loading/error/data states

---

## Routes (go_router)

Add as sub-routes inside the `/garage/:id` route in `lib/core/router/app_router.dart`:

```dart
GoRoute(
  path: 'maintenance',
  builder: (_, state) => MaintenanceListScreen(
    motorcycleId: state.pathParameters['id']!,
  ),
  routes: [
    GoRoute(
      path: 'add',
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: AddMaintenanceScreen(motorcycleId: state.pathParameters['id']!),
        transitionsBuilder: _slideAndFade,
      ),
    ),
  ],
),
```

---

## i18n Strings

### `lib/i18n/maintenance_es.i18n.json`

```json
{
  "title": "Mantenimiento",
  "history": "Historial",
  "addRecord": "Registrar servicio",
  "empty": "Sin registros de mantenimiento",
  "type": "Tipo de servicio",
  "performedAt": "Fecha",
  "performedAtKm": "Kilometraje",
  "description": "Notas (opcional)",
  "saveSuccess": "Registro guardado correctamente.",
  "saveError": "No se pudo guardar el registro. Intenta de nuevo.",
  "deleteConfirmation": "¿Eliminar este registro de mantenimiento? Esta acción no se puede deshacer.",
  "aiSuggestions": "Sugerencias de IA",
  "aiSuggestionsEmpty": "No hay sugerencias disponibles.",
  "types": {
    "oilChange": "Cambio de aceite",
    "brakes": "Frenos",
    "chain": "Cadena",
    "airFilter": "Filtro de aire",
    "tires": "Llantas",
    "sparkPlugs": "Bujías",
    "coolant": "Refrigerante",
    "battery": "Batería",
    "general": "Servicio general",
    "other": "Otro"
  }
}
```

### `lib/i18n/maintenance_en.i18n.json`

```json
{
  "title": "Maintenance",
  "history": "History",
  "addRecord": "Log Service",
  "empty": "No maintenance records yet",
  "type": "Service type",
  "performedAt": "Date",
  "performedAtKm": "Mileage",
  "description": "Notes (optional)",
  "saveSuccess": "Record saved successfully.",
  "saveError": "Could not save record. Please try again.",
  "deleteConfirmation": "Delete this maintenance record? This action cannot be undone.",
  "aiSuggestions": "AI Suggestions",
  "aiSuggestionsEmpty": "No suggestions available.",
  "types": {
    "oilChange": "Oil Change",
    "brakes": "Brakes",
    "chain": "Chain",
    "airFilter": "Air Filter",
    "tires": "Tires",
    "sparkPlugs": "Spark Plugs",
    "coolant": "Coolant",
    "battery": "Battery",
    "general": "General Service",
    "other": "Other"
  }
}
```

> After editing JSON files: run `dart run slang` to regenerate `strings.g.dart`.

---

## AI Integration

### New method in `AiService`

```dart
// Add to lib/features/ai/domain/services/ai_service.dart
Future<List<String>> generateMaintenanceSuggestions({
  required String languageCode,
  required String make,
  required String model,
  required int year,
  required int currentKm,
  required List<MaintenanceRecord> recentRecords,  // last 5 records
});
```

### Prompt

```
You are an expert motorcycle mechanic assistant.
Motorcycle: {year} {make} {model}, current mileage: {currentKm}km.
Recent maintenance: {recentRecords}  (type, km, date for each)
Based on typical service intervals for this motorcycle,
suggest 3–5 maintenance items the user should consider next.
Focus on safety-critical items first.
Respond ONLY with valid JSON: {"suggestions": ["...", "...", "..."]}
Respond in the language indicated by languageCode: {languageCode}
```

---

## Acceptance Criteria

- [ ] AC-1: User can view the full maintenance history of a motorcycle.
- [ ] AC-2: History is sorted by `performedAt` descending.
- [ ] AC-3: User can add a new maintenance record with type, date, km, and optional notes.
- [ ] AC-4: The form pre-fills mileage with the motorcycle's current km.
- [ ] AC-5: The form validates: type required, km >= 0, date not in the future.
- [ ] AC-6: User can delete a record with a confirmation dialog.
- [ ] AC-7: AI suggestions load automatically when `AddMaintenanceScreen` opens.
- [ ] AC-8: All text is available in both ES and EN (including all `MaintenanceType` labels).
- [ ] AC-9: Loading / empty / error states render correctly on all screens.
- [ ] AC-10: Routes are nested correctly under `/garage/:id/maintenance`.

---

## Constraints and Edge Cases

- Records are scoped to a `motorcycleId`; deleting a motorcycle cascades to its records.
- `performedAtKm` can be less than current mileage (for logging past work retroactively).
- If `recentRecords` is empty, AI prompt should still work (graceful degradation).
- `MaintenanceType.other` with an empty `description` should be allowed but warn the user.
- Offline: show a clear error toast if Supabase is unreachable; do not silently discard records.

---

## References

- `openspec/ARCHITECTURE.md`
- `openspec/specs/garage/spec.md` — full pattern reference
- `lib/features/garage/domain/entities/motorcycle.dart` — entity pattern
- `lib/features/garage/domain/repositories/motorcycle_repository.dart` — repository pattern
- `lib/features/garage/data/supabase_motorcycle_repository.dart` — Supabase implementation pattern
- `lib/features/garage/presentation/providers/garage_providers.dart` — providers pattern
- `lib/features/ai/domain/services/ai_service.dart` — AI service contract to extend
- `lib/core/router/app_router.dart` — add nested routes here
- `lib/i18n/garage_es.i18n.json` — i18n format reference

