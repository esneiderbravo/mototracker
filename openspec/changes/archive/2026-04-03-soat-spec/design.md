## Context

MotoTracker already ships feature patterns for garage and maintenance, but it has no implemented SOAT feature in the app layers. The `openspec/specs/soat/spec.md` defines the target behavior and constraints, including user-scoped plate lookup, expiry status bands, and full CRUD per motorcycle. This design aligns implementation with existing project conventions: Clean Architecture by feature, Riverpod-only state, go_router route registration, ThemeTokens-only styling, and bilingual i18n via slang.

## Goals / Non-Goals

**Goals:**
- Implement `features/soat` in domain, data, and presentation layers following established patterns.
- Persist SOAT policies in Supabase with strict user isolation and data integrity constraints.
- Support active SOAT lookup by normalized plate within authenticated user scope.
- Provide deterministic expiry status computation and consistent async UI states.
- Integrate routes and i18n without regressions to existing garage flows.

**Non-Goals:**
- Push notification reminders for upcoming expirations.
- RTM/legal-document consolidation beyond SOAT.
- Cross-feature AI alert orchestration for legal documents.

## Decisions

1. **Feature structure follows existing Clean Architecture slices**
   - Create `lib/features/soat/domain`, `data`, and `presentation` directories mirroring garage/maintenance.
   - Rationale: minimizes cognitive overhead and accelerates review by reusing known folder and provider patterns.
   - Alternative considered: placing SOAT under an existing legal-documents module; rejected to avoid introducing a new architectural pattern now.

2. **Repository contract is read-optimized for core user flows**
   - Include real-time `watchByMotorcycle` and query methods for active policy, plate lookup, history by plate, and expiring-soon.
   - Rationale: these methods map directly to screen responsibilities and acceptance criteria.
   - Alternative considered: generic query/filter API; rejected because it weakens type-level intent and complicates provider composition.

3. **Supabase data model enforces integrity in DB first**
   - Use `soat_policies` table with `expiry_date > start_date` check, unique index on `(user_id, motorcycle_id, policy_number)`, and RLS `auth.uid() = user_id`.
   - Rationale: prevents invalid/duplicate records even if client validation is bypassed.
   - Alternative considered: client-only validation; rejected as insufficient for integrity and multi-client consistency.

4. **Plate lookup normalization occurs before repository query**
   - Normalize to uppercase alphanumeric without spaces at provider boundary and repository input guards.
   - Rationale: deterministic matching and fewer user-input edge cases.
   - Alternative considered: database-side normalization only; rejected because it complicates indexes and query readability.

5. **UI uses existing async and routing primitives**
   - Loading/error/data states through `AsyncValueBuilder`; routes added in `lib/core/router/app_router.dart` under `/soat/lookup` and `/garage/:id/soat...`.
   - Rationale: maintains consistency across the app and avoids bespoke state handling.
   - Alternative considered: custom local async handlers; rejected for duplicated behavior and inconsistent UX.

## Risks / Trade-offs

- **[Risk] Duplicate motorcycle plates for one user can make lookup ambiguous** -> Mitigation: enforce deterministic ordering (latest motorcycle `created_at`) or return explicit domain error.
- **[Risk] Device clock drift can affect status chips** -> Mitigation: compute status using date-only normalization and clearly define boundary conditions.
- **[Risk] Route additions could regress existing garage navigation** -> Mitigation: add route-level tests and manual smoke checks for current garage paths.
- **[Trade-off] Additional repository methods increase surface area** -> Mitigation: keep methods focused on required scenarios and avoid speculative endpoints.

## Migration Plan

- Apply Supabase migration for `soat_policies`, indexes, and RLS policy.
- Land domain layer (`SoatPolicy` entity and repository contract), then data implementation and providers.
- Add screens/widgets and register routes in `app_router.dart`.
- Add ES/EN i18n keys and run `dart run slang`.
- Validate with unit/provider/widget tests and perform manual user-scope lookup checks.
- Rollback strategy: feature-flag route access if needed; DB rollback by dropping new table/indexes in reverse migration.

## Open Questions

- Should plate lookup return history when no active policy is found, or remain strict not-found in v1?
- Do we need additional database constraints to prevent overlapping active policy periods per motorcycle?
- Is deterministic plate conflict behavior better as explicit error messaging or silent latest-record selection?

