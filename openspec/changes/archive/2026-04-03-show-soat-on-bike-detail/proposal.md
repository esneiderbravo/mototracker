## Why

Users can register SOAT, but they do not have a clear, immediate SOAT visibility entry point from their bike detail experience. We need to make SOAT status and access obvious on each motorcycle so users quickly know coverage state and where to manage it.

## What Changes

- Add a visible SOAT section in motorcycle detail to show current SOAT state and direct actions (view history, add, lookup).
- Define explicit UX behavior for bikes with active SOAT, expiring SOAT, expired SOAT, and no SOAT.
- Align SOAT feature discoverability with existing garage detail flow without introducing new navigation patterns.
- Reconfirm SOAT entity shape used by UI (`SoatPolicy`: `id`, `userId`, `motorcycleId`, `insurer`, `policyNumber`, `startDate`, `expiryDate`, `notes`, `createdAt`) including `copyWith`, `fromJson`, `toJson`, `toInsertJson`.
- Reconfirm repository methods required for visibility states (`getActivePolicy`, `watchByMotorcycle`, and plate lookup methods).
- Reuse Supabase schema `soat_policies` with RLS and indexes for responsive status retrieval in detail view.
- Add/adjust i18n keys in both locales for SOAT section labels, empty state, and action CTAs.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `soat`: requirements are expanded to mandate SOAT visibility and quick actions from motorcycle detail context.
- `garage`: requirements are expanded to include an in-detail legal-documents/SOAT entry point and status indicator.

## Impact

- Affected code: `lib/features/garage/presentation/screens/motorcycle_detail_screen.dart`, `lib/features/soat/presentation/screens/soat_list_screen.dart`, `lib/features/soat/presentation/widgets/soat_expiry_banner.dart`, and related providers.
- Router impact: may reuse existing `/garage/:id/soat` and `/soat/lookup` routes with clearer in-screen entry points.
- Data impact: no new table expected; uses existing `soat_policies` schema and repository contract.
- i18n impact: add/update SOAT and garage strings in `lib/i18n/soat_es.i18n.json`, `lib/i18n/soat_en.i18n.json`, `lib/i18n/garage_es.i18n.json`, and `lib/i18n/garage_en.i18n.json`.
- Dependencies: no new external packages expected.

