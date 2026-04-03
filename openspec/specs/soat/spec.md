# Spec: SOAT Registry and Expiry Review

> **For the AI assistant:** Read `openspec/ARCHITECTURE.md` AND this full spec before generating any code.
> The garage and maintenance specs are the primary pattern references.

---

## Meta

| Field | Value |
|---|---|
| **Feature** | `features/soat` |
| **Status** | `ready` |
| **Date** | 2026-04-02 |
| **Roadmap ref** | `FEATURES.md -> Legal Documents -> SOAT` |

---

## Purpose

Enable users to register, review, and manage SOAT policies per motorcycle, including active-policy lookup by license plate within the authenticated user scope.

---

## Summary

This feature lets users register and manage SOAT (mandatory insurance) data for each motorcycle, including insurer, policy number, start date, and expiry date. It also defines in-app expiry review states so users can quickly identify policies that are expiring soon (30, 15, and 5 days), plus a lookup flow to retrieve SOAT information from a provided license plate (`placa`). The first iteration focuses on clean CRUD + review UX; push notifications and cross-document grouping remain out of scope.

---

## Requirements

### Requirement: Active SOAT lookup by plate

The system SHALL return the authenticated user's active SOAT policy when a normalized license plate is provided.

#### Scenario: User searches a plate with an active policy

- GIVEN an authenticated user and a motorcycle with an active SOAT policy
- WHEN the user searches by that motorcycle's license plate
- THEN the app returns the active SOAT policy details
- AND no data from other users is returned

---

## User Stories

- [ ] US-1: As a user I want to register SOAT data for a motorcycle so I always have policy details available.
- [ ] US-2: As a user I want to see my motorcycle SOAT status (active, expiring soon, expired) so I can renew on time.
- [ ] US-3: As a user I want to review SOAT entries per motorcycle in chronological order so I can keep policy history.
- [ ] US-4: As a user I want to edit or delete a SOAT entry so I can correct outdated information.
- [ ] US-5: As a user I want to find SOAT information by entering a license plate so I can quickly check coverage without browsing the full garage list.

---

## Data Model (Domain Entity)

```dart
// lib/features/soat/domain/entities/soat_policy.dart

class SoatPolicy {
  const SoatPolicy({
    required this.id,
    required this.userId,
    required this.motorcycleId,     // FK to motorcycles.id
    required this.insurer,          // Insurance provider name
    required this.policyNumber,     // Unique per user + motorcycle
    required this.startDate,        // Coverage start date
    required this.expiryDate,       // Coverage expiry date
    required this.notes,            // Optional free text, max 500 chars
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String motorcycleId;
  final String insurer;
  final String policyNumber;
  final DateTime startDate;
  final DateTime expiryDate;
  final String notes;
  final DateTime createdAt;

  String get displayName => '$policyNumber - $insurer';

  int daysUntilExpiry(DateTime now) =>
      expiryDate.difference(DateTime(now.year, now.month, now.day)).inDays;

  bool isExpired(DateTime now) => daysUntilExpiry(now) < 0;
}
```

### Domain Constraints

- `motorcycleId`: must reference an existing motorcycle owned by the same user.
- `insurer`: required, trimmed, 2-80 characters.
- `policyNumber`: required, trimmed, uppercase, 4-40 characters.
- `startDate`: required.
- `expiryDate`: required and must be strictly after `startDate`.
- `notes`: optional, max 500 characters.
- License plate lookup uses `motorcycles.license_plate` (related entity), normalized to uppercase alphanumeric without spaces before querying.
- Expiry review bands:
  - `expired`: `daysUntilExpiry < 0`
  - `due5`: `0 <= daysUntilExpiry <= 5`
  - `due15`: `6 <= daysUntilExpiry <= 15`
  - `due30`: `16 <= daysUntilExpiry <= 30`
  - `active`: `daysUntilExpiry > 30`

---

## Repository Contract (Domain)

```dart
// lib/features/soat/domain/repositories/soat_policy_repository.dart

abstract class SoatPolicyRepository {
  /// Real-time SOAT history for one motorcycle, newest expiry first.
  Stream<List<SoatPolicy>> watchByMotorcycle(String motorcycleId);

  Future<SoatPolicy?> getById(String id);
  Future<void> add(SoatPolicy policy);
  Future<void> update(SoatPolicy policy);
  Future<void> remove(String id);

  /// Returns the most recent non-expired policy for one motorcycle, if any.
  Future<SoatPolicy?> getActivePolicy(String motorcycleId);

  /// Returns the active SOAT policy by license plate for a scoped user.
  Future<SoatPolicy?> getActiveByLicensePlate({
    required String userId,
    required String licensePlate,
  });

  /// Returns SOAT history by license plate for a scoped user.
  Future<List<SoatPolicy>> getHistoryByLicensePlate({
    required String userId,
    required String licensePlate,
  });

  /// Returns all policies expiring within [days] for current user.
  Future<List<SoatPolicy>> getExpiringSoon({
    required String userId,
    required int days,
  });
}
```

---

## Supabase Schema (Data)

### Table: `soat_policies`

```sql
CREATE TABLE soat_policies (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  motorcycle_id  UUID NOT NULL REFERENCES motorcycles(id) ON DELETE CASCADE,
  insurer        TEXT NOT NULL DEFAULT '',
  policy_number  TEXT NOT NULL DEFAULT '',
  start_date     DATE NOT NULL,
  expiry_date    DATE NOT NULL,
  notes          TEXT NOT NULL DEFAULT '',
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT soat_expiry_after_start CHECK (expiry_date > start_date)
);

ALTER TABLE soat_policies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own soat_policies" ON soat_policies
  FOR ALL USING (auth.uid() = user_id);

-- Helps avoid accidental duplicates in same motorcycle context.
CREATE UNIQUE INDEX uq_soat_motorcycle_policy
  ON soat_policies(user_id, motorcycle_id, policy_number);

CREATE INDEX idx_soat_motorcycle_expiry
  ON soat_policies(motorcycle_id, expiry_date DESC);

CREATE INDEX idx_soat_user_expiry
  ON soat_policies(user_id, expiry_date ASC);

-- Dependency for plate-based lookup performance on motorcycles table.
CREATE INDEX idx_motorcycles_user_plate
  ON motorcycles(user_id, license_plate);
```

### Column <-> Dart Field Mapping

| SQL Column | Dart Field | SQL Type | Dart Type |
|---|---|---|---|
| `id` | `id` | UUID | String |
| `user_id` | `userId` | UUID | String |
| `motorcycle_id` | `motorcycleId` | UUID | String |
| `insurer` | `insurer` | TEXT | String |
| `policy_number` | `policyNumber` | TEXT | String |
| `start_date` | `startDate` | DATE | DateTime |
| `expiry_date` | `expiryDate` | DATE | DateTime |
| `notes` | `notes` | TEXT | String |
| `created_at` | `createdAt` | TIMESTAMPTZ | DateTime |

---

## Providers (Riverpod)

```dart
// lib/features/soat/presentation/providers/soat_providers.dart

final soatPolicyRepositoryProvider = Provider<SoatPolicyRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseSoatPolicyRepository(client);
});

final soatByMotorcycleProvider =
    StreamProvider.family<List<SoatPolicy>, String>((ref, motorcycleId) {
  return ref.watch(soatPolicyRepositoryProvider).watchByMotorcycle(motorcycleId);
});

final activeSoatByMotorcycleProvider =
    FutureProvider.family<SoatPolicy?, String>((ref, motorcycleId) {
  return ref.watch(soatPolicyRepositoryProvider).getActivePolicy(motorcycleId);
});

final soatByLicensePlateProvider =
    FutureProvider.family<SoatPolicy?, String>((ref, rawPlate) {
  final authUser = ref.watch(authUserProvider).valueOrNull;
  if (authUser == null) return Future.value(null);

  final normalizedPlate = rawPlate.toUpperCase().replaceAll(' ', '');
  return ref.watch(soatPolicyRepositoryProvider).getActiveByLicensePlate(
        userId: authUser.id,
        licensePlate: normalizedPlate,
      );
});

final expiringSoatProvider = FutureProvider.family<List<SoatPolicy>, int>((ref, days) {
  final authUser = ref.watch(authUserProvider).valueOrNull;
  if (authUser == null) return Future.value([]);
  return ref.watch(soatPolicyRepositoryProvider).getExpiringSoon(
        userId: authUser.id,
        days: days,
      );
});
```

---

## Screens and Widgets

### Screens

| Screen | Route | Description |
|---|---|---|
| `SoatLookupScreen` | `/soat/lookup` | Search by plate and show active SOAT summary or not-found state |
| `SoatListScreen` | `/garage/:id/soat` | SOAT history list for a motorcycle + active status banner |
| `AddSoatScreen` | `/garage/:id/soat/add` | New SOAT policy form |
| `SoatDetailScreen` | `/garage/:id/soat/:soatId` | Full policy details + edit/delete actions |

### UI States

**`SoatLookupScreen`**
- Plate input with formatter (uppercase, alphanumeric, no spaces).
- Search action fetches `soatByLicensePlateProvider`.
- Not found state: clear message + optional CTA to register SOAT.
- Data state: active SOAT summary + navigation to `SoatDetailScreen`.

**`SoatListScreen`**
- Loading: `AsyncValueBuilder` with loading state.
- Empty: no SOAT records message + CTA to create first policy.
- Error: retry action.
- Data: status badge per record (`active`, `due30`, `due15`, `due5`, `expired`) ordered by `expiryDate` desc.

**`AddSoatScreen`**
- Fields: insurer, policy number, start date, expiry date, notes.
- Validations: required text fields and `expiryDate > startDate`.
- Save button with loading state.

**`SoatDetailScreen`**
- Header with policy number and insurer.
- Coverage date range and computed days until expiry.
- Edit and delete actions with confirmation dialog.

### Internal Widgets

- `SoatPolicyCard` - list row with insurer, policy number, expiry date, status chip.
- `SoatStatusChip` - visual status component for expiry review bands.
- `SoatExpiryBanner` - top banner for active record urgency.

---

## Routes (go_router)

Add one top-level lookup route plus SOAT sub-routes inside `/garage/:id` in `lib/core/router/app_router.dart`:

```dart
GoRoute(
  path: '/soat/lookup',
  builder: (_, state) => SoatLookupScreen(
    initialPlate: state.uri.queryParameters['plate'],
  ),
),

GoRoute(
  path: 'soat',
  builder: (_, state) => SoatListScreen(
    motorcycleId: state.pathParameters['id']!,
  ),
  routes: [
    GoRoute(
      path: 'add',
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: AddSoatScreen(motorcycleId: state.pathParameters['id']!),
        transitionsBuilder: _slideAndFade,
      ),
    ),
    GoRoute(
      path: ':soatId',
      builder: (_, state) => SoatDetailScreen(
        motorcycleId: state.pathParameters['id']!,
        soatId: state.pathParameters['soatId']!,
      ),
    ),
  ],
),
```

---

## i18n Strings

### `lib/i18n/soat_es.i18n.json`

```json
{
  "title": "SOAT",
  "lookup": "Buscar por placa",
  "plate": "Placa",
  "search": "Buscar",
  "notFoundByPlate": "No se encontro un SOAT vigente para esta placa",
  "history": "Historial de SOAT",
  "addPolicy": "Agregar SOAT",
  "insurer": "Aseguradora",
  "policyNumber": "Numero de poliza",
  "startDate": "Inicio de cobertura",
  "expiryDate": "Vencimiento",
  "notes": "Notas (opcional)",
  "empty": "No hay polizas SOAT registradas",
  "saveSuccess": "SOAT guardado correctamente.",
  "saveError": "No se pudo guardar el SOAT. Intenta de nuevo.",
  "deleteConfirmation": "Eliminar esta poliza SOAT? Esta accion no se puede deshacer.",
  "statuses": {
    "active": "Vigente",
    "due30": "Vence pronto (30 dias)",
    "due15": "Vence en 15 dias",
    "due5": "Vence en 5 dias",
    "expired": "Vencido"
  }
}
```

### `lib/i18n/soat_en.i18n.json`

```json
{
  "title": "SOAT",
  "lookup": "Lookup by plate",
  "plate": "License Plate",
  "search": "Search",
  "notFoundByPlate": "No active SOAT found for this plate",
  "history": "SOAT History",
  "addPolicy": "Add SOAT",
  "insurer": "Insurer",
  "policyNumber": "Policy Number",
  "startDate": "Coverage Start",
  "expiryDate": "Expiry Date",
  "notes": "Notes (optional)",
  "empty": "No SOAT policies registered",
  "saveSuccess": "SOAT saved successfully.",
  "saveError": "Could not save SOAT. Please try again.",
  "deleteConfirmation": "Delete this SOAT policy? This action cannot be undone.",
  "statuses": {
    "active": "Active",
    "due30": "Due soon (30 days)",
    "due15": "Due in 15 days",
    "due5": "Due in 5 days",
    "expired": "Expired"
  }
}
```

> After editing JSON files: run `dart run slang` to regenerate `strings.g.dart`.

---

## Scope Clarification

In scope (v1):
- SOAT CRUD per motorcycle.
- Real-time list and active policy review.
- Expiry review states for 30/15/5 day bands and expired.
- SOAT active lookup by provided license plate within the authenticated user scope.

Out of scope (v1):
- Push notifications.
- Technical-mechanical inspection (RTM).
- AI grouped alerts across all legal documents.

---

## Acceptance Criteria

- [ ] AC-1: User can create, read, update, and delete SOAT entries per motorcycle.
- [ ] AC-2: SOAT list updates in real time and is sorted by `expiryDate` descending.
- [ ] AC-3: Form validates required fields and blocks save if `expiryDate <= startDate`.
- [ ] AC-4: Each SOAT item shows a correct status badge (`active`, `due30`, `due15`, `due5`, `expired`).
- [ ] AC-5: User can view active policy details from list and detail screens.
- [ ] AC-6: All text is available in ES and EN.
- [ ] AC-7: Loading / empty / error states are handled with `AsyncValueBuilder`.
- [ ] AC-8: Routes work under `/garage/:id/soat` without breaking existing garage flows.
- [ ] AC-9: User can retrieve active SOAT info by entering a plate in `/soat/lookup`.
- [ ] AC-10: Plate lookup normalizes input (uppercase, no spaces) before querying.
- [ ] AC-11: Plate lookup is user-scoped; data from other users is never returned.
- [ ] AC-12: If no active SOAT exists for plate, app shows a deterministic not-found state.

---

## Implementation Review Checklist

- [ ] Domain entity uses `const`, `copyWith`, `fromJson`, `toJson`, `toInsertJson`.
- [ ] Repository follows naming and method conventions.
- [ ] Supabase table, indexes, and RLS policy are applied.
- [ ] Providers depend on `authUserProvider` where user scope is needed.
- [ ] Plate lookup provider normalizes plate input before repository call.
- [ ] Screens receive primitive route params only.
- [ ] Theme uses `ThemeTokens` only (no hardcoded colors/sizes).
- [ ] New user-facing strings are added to both SOAT i18n files and `dart run slang` is executed.

---

## Constraints and Edge Cases

- Multiple historical SOAT records per motorcycle are allowed; only one can be active by date logic at a given time.
- Duplicate `policyNumber` for the same user + motorcycle is blocked by unique index.
- If a plate exists but only expired policies are available, lookup returns not-found for active query and can optionally navigate to history.
- Plate inputs with spaces or lowercase letters must resolve to the same normalized value.
- If duplicate `license_plate` records exist in `motorcycles` for one user, repository must apply deterministic ordering (latest `created_at`) or fail with explicit domain error.
- If there is no active policy, show an expired/empty warning banner.
- If device date is incorrect, status calculation can be off; use normalized date-only comparisons.
- Deleting a motorcycle cascades all related SOAT records.

---

## References

- `openspec/ARCHITECTURE.md`
- `openspec/specs/garage/spec.md`
- `openspec/specs/maintenance/spec.md`
- `FEATURES.md`
- `lib/features/garage/domain/entities/motorcycle.dart`
- `lib/features/garage/domain/repositories/motorcycle_repository.dart`
- `lib/features/garage/data/supabase_motorcycle_repository.dart`
- `lib/features/garage/presentation/providers/garage_providers.dart`
- `lib/shared/widgets/async_value_builder.dart`
- `lib/core/router/app_router.dart`
- `lib/i18n/garage_es.i18n.json`
- `lib/i18n/garage_en.i18n.json`

