## Why

MotoTracker currently lacks a complete, implementation-ready OpenSpec change package for SOAT policy management across domain, data, and presentation layers. We need this now to deliver legal-document coverage parity with existing garage and maintenance features and reduce renewal-risk for users.

## What Changes

- Introduce end-to-end SOAT capability requirements: register, list, edit, delete, and detail view per motorcycle.
- Add active-policy lookup by normalized license plate, scoped to the authenticated user.
- Define expiry review behavior (`active`, `due30`, `due15`, `due5`, `expired`) using date-only comparisons.
- Specify domain entity shape (`SoatPolicy`) including serialization (`copyWith`, `fromJson`, `toJson`, `toInsertJson`).
- Specify repository contract for real-time history, active policy queries, plate-based lookup, and expiring-soon retrieval.
- Specify Supabase schema for `soat_policies` (constraints, indexes, RLS, user isolation).
- Specify routes, Riverpod providers, async UI handling via `AsyncValueBuilder`, and ES/EN i18n keys.

## Capabilities

### New Capabilities
- `soat`: SOAT registry, expiry review, and active lookup by plate for authenticated users.

### Modified Capabilities
- None.

## Impact

- Affected code areas: `lib/features/soat/` (new feature), `lib/core/router/app_router.dart`, `lib/i18n/soat_es.i18n.json`, `lib/i18n/soat_en.i18n.json`, and generated slang outputs.
- Data layer impact: new `soat_policies` table, constraints, indexes, and RLS policy in Supabase.
- Dependency impact: no new external package requirements expected; uses existing Flutter, Riverpod, Supabase, go_router, and slang stack.
- UX impact: adds SOAT lookup and policy history flows without breaking existing garage routes.

