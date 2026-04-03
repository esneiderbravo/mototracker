# Spec: Garage — Motorcycle Management

> **For the AI assistant:** Read `openspec/ARCHITECTURE.md` first.
> This spec documents the already-implemented feature. Use it as a pattern reference.

---

## Meta

| Field | Value |
|---|---|
| **Feature** | `features/garage` |
| **Status** | `implemented` |
| **Date** | 2025-01-01 |
| **Roadmap ref** | `FEATURES.md → ✅ Garage` |

---

## Purpose

Define the implemented garage behavior for listing and managing motorcycles owned by the authenticated user.

---

## Summary

The garage allows users to register, view, and manage their motorcycles. Each motorcycle has a photo, technical data (make, model, year, color, license plate, mileage), and receives personalized AI insights. It is the main screen of the app after login.

---
## Requirements
### Requirement: List motorcycles for authenticated user

The system SHALL display only motorcycles owned by the authenticated user in the garage list.

#### Scenario: User opens the garage home screen

- GIVEN an authenticated user with one or more motorcycles
- WHEN the user navigates to `/garage`
- THEN the app shows that user's motorcycles in the garage list
- AND motorcycles from other users are not shown

---

### Requirement: Motorcycle detail provides SOAT entry point
The system SHALL include a SOAT entry point in motorcycle detail and SHALL support automatic SOAT lookup by the motorcycle plate when profile identification requirements are satisfied.

#### Scenario: User navigates from detail to SOAT history
- **WHEN** the user taps the SOAT section action from `/garage/:id`
- **THEN** the app navigates to `/garage/:id/soat`

#### Scenario: Detail SOAT entry is user-scoped
- **WHEN** SOAT status is rendered inside motorcycle detail
- **THEN** the status and actions are based only on the authenticated user's motorcycle data

#### Scenario: Motorcycle detail auto-searches SOAT with eligible profile
- **WHEN** an authenticated user opens `/garage/:id` and profile includes required identification fields
- **THEN** the app triggers SOAT lookup automatically using that motorcycle's normalized plate

#### Scenario: Motorcycle detail prompts profile completion when ineligible
- **WHEN** an authenticated user opens `/garage/:id` without required profile identification fields
- **THEN** the app shows a deterministic prompt to complete profile before automatic SOAT lookup

## User Stories

- [x] US-1: As a user I want to see all my motorcycles in a list so I have an inventory of my garage.
- [x] US-2: As a user I want to add a new motorcycle with a photo to personalize my garage.
- [x] US-3: As a user I want the AI to fill in motorcycle data from free text to speed up registration.
- [x] US-4: As a user I want to see each motorcycle's details and AI recommendations to make better maintenance decisions.
- [x] US-5: As a user I want to delete a motorcycle with a confirmation dialog to prevent accidental deletions.

---

## Data Model (Domain Entity)

```dart
// lib/features/garage/domain/entities/motorcycle.dart

class Motorcycle {
  const Motorcycle({
    required this.id,
    required this.userId,
    required this.make,         // Brand (e.g. "Honda")
    required this.model,        // Model (e.g. "CB500F")
    required this.year,         // Year (e.g. 2021)
    required this.color,        // Free-text color (e.g. "Metallic Red")
    required this.licensePlate, // Plate (e.g. "ABC123"), uppercase, no spaces
    required this.currentKm,    // Current mileage, integer >= 0
    required this.imageUrl,     // Supabase Storage URL, nullable
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String make;
  final String model;
  final int year;
  final String color;
  final String licensePlate;
  final int currentKm;
  final String? imageUrl;
  final DateTime createdAt;

  String get displayName => '$make $model $year';
}
```

---

## Repository Contract (Domain)

```dart
// lib/features/garage/domain/repositories/motorcycle_repository.dart

abstract class MotorcycleRepository {
  Stream<List<Motorcycle>> watchMotorcycles(String userId);   // Realtime
  Future<Motorcycle?> getById(String id);
  Future<void> add(Motorcycle motorcycle);
  Future<void> update(Motorcycle motorcycle);
  Future<void> remove(String id);
  Future<String?> uploadImage({
    required String userId,
    required String fileName,
    required Uint8List bytes,
  });
}
```

---

## Supabase Schema (Data)

### Table: `motorcycles`

```sql
CREATE TABLE motorcycles (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  make          TEXT NOT NULL DEFAULT '',
  model         TEXT NOT NULL DEFAULT '',
  year          INTEGER NOT NULL DEFAULT 0,
  color         TEXT NOT NULL DEFAULT '',
  license_plate TEXT NOT NULL DEFAULT '',
  current_km    INTEGER NOT NULL DEFAULT 0,
  image_url     TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE motorcycles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own motorcycles" ON motorcycles
  FOR ALL USING (auth.uid() = user_id);
```

### Storage bucket: `motorcycle-images`

- Public bucket for direct URLs.
- Path: `{userId}/{fileName}`.

---

## Providers (Riverpod)

```dart
// lib/features/garage/presentation/providers/garage_providers.dart

final motorcycleRepositoryProvider = Provider<MotorcycleRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseMotorcycleRepository(client);
});

final motorcyclesProvider = StreamProvider<List<Motorcycle>>((ref) {
  final authUser = ref.watch(authUserProvider).valueOrNull;
  if (authUser == null) return Stream.value([]);
  return ref.watch(motorcycleRepositoryProvider).watchMotorcycles(authUser.id);
});

final motorcycleByIdProvider = FutureProvider.family<Motorcycle?, String>((ref, id) {
  return ref.watch(motorcycleRepositoryProvider).getById(id);
});
```

---

## Screens and Widgets

| Screen | Route | Status |
|---|---|---|
| `HomeScreen` | `/garage` | ✅ |
| `AddMotorcycleScreen` | `/garage/add` | ✅ |
| `MotorcycleDetailScreen` | `/garage/:id` | ✅ |

---

## i18n Strings

Namespace: `garage` → `lib/i18n/garage_es.i18n.json` / `garage_en.i18n.json`

Main keys: `title`, `addMotorcycle`, `empty`, `save`, `saveSuccess`, `saveError`, `deleteConfirmation`, `aiInsights`, `specifications`.

---

## References

- `lib/features/garage/domain/entities/motorcycle.dart`
- `lib/features/garage/domain/repositories/motorcycle_repository.dart`
- `lib/features/garage/data/supabase_motorcycle_repository.dart`
- `lib/features/garage/presentation/providers/garage_providers.dart`
- `lib/features/garage/presentation/screens/home_screen.dart`
- `lib/features/garage/presentation/screens/add_motorcycle_screen.dart`
- `lib/features/garage/presentation/screens/motorcycle_detail_screen.dart`

