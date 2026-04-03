## 1. Data and Domain Foundation

- [x] 1.1 Create Supabase migration for `soat_policies` table, indexes, constraint `expiry_date > start_date`, and RLS policy.
- [x] 1.2 Implement `SoatPolicy` entity in `lib/features/soat/domain/entities/soat_policy.dart` with `const` constructor, `copyWith`, `fromJson`, `toJson`, and `toInsertJson`.
- [x] 1.3 Add `SoatPolicyRepository` contract in `lib/features/soat/domain/repositories/soat_policy_repository.dart` with all required stream/query methods.

## 2. Repository and Provider Layer

- [x] 2.1 Implement `SupabaseSoatPolicyRepository` in `lib/features/soat/data/` with CRUD, active-by-motorcycle, active-by-plate, history-by-plate, and expiring-soon queries.
- [x] 2.2 Add deterministic plate normalization and ambiguous-plate handling logic for scoped lookup.
- [x] 2.3 Create `soat_providers.dart` with repository provider, stream/future providers, and auth-scoped access via `authUserProvider`.

## 3. SOAT UI Screens and Widgets

- [x] 3.1 Build `SoatListScreen` for `/garage/:id/soat` using `AsyncValueBuilder` for loading, empty, error, and data states.
- [x] 3.2 Build `AddSoatScreen` with validated form fields (`expiryDate > startDate`) and save/loading handling.
- [x] 3.3 Build `SoatDetailScreen` with policy details, expiry summary, edit action, and delete confirmation.
- [x] 3.4 Build `SoatLookupScreen` for `/soat/lookup` with plate input normalization and deterministic not-found state.
- [x] 3.5 Build feature widgets: `SoatPolicyCard`, `SoatStatusChip`, and `SoatExpiryBanner` using `ThemeTokens`.

## 4. Routing, Localization, and Validation

- [x] 4.1 Register SOAT routes in `lib/core/router/app_router.dart` for lookup and garage sub-routes.
- [x] 4.2 Add ES and EN SOAT translation files (`lib/i18n/soat_es.i18n.json`, `lib/i18n/soat_en.i18n.json`) with all user-facing keys.
- [x] 4.3 Run `dart run slang` and verify generated localization code compiles.
- [x] 4.4 Update `FEATURES.md` to move SOAT from Roadmap to Implemented when feature delivery is complete.

## 5. Testing and Quality Checks

- [x] 5.1 Add domain tests for date-band status calculations and serialization behavior.
- [x] 5.2 Add repository/provider tests for user scoping, plate normalization, and active-policy lookup behavior.
- [x] 5.3 Add widget or integration tests for SOAT list, lookup not-found state, and route navigation.
- [x] 5.4 Run formatting, static analysis, and targeted test suites; fix issues before merge.

