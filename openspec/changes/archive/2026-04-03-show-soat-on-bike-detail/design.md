## Context

SOAT flows exist as dedicated routes, but discoverability from the per-bike journey is unclear for users who open motorcycle detail first. The change is cross-feature because it touches `garage` presentation (bike detail) and `soat` presentation (status/entry actions), while reusing existing repository methods, routes, and schema.

## Goals / Non-Goals

**Goals:**
- Make SOAT visibility explicit inside the motorcycle detail experience.
- Provide deterministic UI states for active, expiring, expired, and missing SOAT.
- Keep navigation on existing routes (`/garage/:id/soat`, `/soat/lookup`) to avoid routing churn.
- Ensure ES/EN labels make the entry point self-explanatory.

**Non-Goals:**
- Changing SOAT database schema or repository contract shape.
- Adding push reminders or background notification logic.
- Building a cross-document legal dashboard in this iteration.

## Decisions

1. Add a dedicated SOAT section in `MotorcycleDetailScreen` with a status chip/banner and quick actions.
   - Rationale: users already inspect bike-level data there; this is the highest-intent location.
   - Alternative: only top-level `/soat/lookup`; rejected because it is less contextual per motorcycle.

2. Reuse `activeSoatByMotorcycleProvider` for status visibility and drive CTA behavior from its state.
   - Rationale: keeps business logic in providers and preserves Clean Architecture boundaries.
   - Alternative: query directly in widget; rejected due to architecture and testability concerns.

3. Keep existing routes and only add in-context navigation buttons.
   - Rationale: lowest risk to router stability while improving discoverability.
   - Alternative: new detail sub-route alias; rejected as redundant.

4. Extend i18n keys in `garage` and `soat` namespaces for in-detail labels.
   - Rationale: keeps text ownership close to feature domain while preserving bilingual support.

## Risks / Trade-offs

- [Risk] SOAT status may not refresh after add/edit/delete from another screen -> Mitigation: invalidate related providers on SOAT mutations.
- [Risk] Detail screen becomes visually dense -> Mitigation: compact card layout and progressive actions.
- [Trade-off] Reusing existing routes keeps URL model simple but can limit future deep-link granularity -> Mitigation: revisit route aliases in a later legal-documents iteration.

## Migration Plan

- No DB migration required for visibility-only enhancement.
- Implement UI and provider wiring behind existing routes.
- Add/update i18n keys and run `dart run slang`.
- Validate with widget tests for status rendering and navigation from bike detail to SOAT screens.

## Open Questions

- Should missing SOAT state show only "Add SOAT" or both "Add" and "Lookup" actions?
- Should due-soon thresholds (30/15/5) be shown as separate badge text on detail or summarized as a single urgency label?

