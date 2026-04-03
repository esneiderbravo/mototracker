## 1. Detail Screen SOAT Visibility

- [x] 1.1 Add a SOAT section in `lib/features/garage/presentation/screens/motorcycle_detail_screen.dart` showing active/missing status for the selected motorcycle.
- [x] 1.2 Wire the SOAT status UI to Riverpod providers (`activeSoatByMotorcycleProvider`) and handle loading/error/empty states with existing patterns.
- [x] 1.3 Add primary actions from detail to open `/garage/:id/soat` and optional quick action for `/soat/lookup`.

## 2. SOAT UI and Localization Alignment

- [x] 2.1 Update SOAT/garage widgets as needed for compact detail-view status presentation using `ThemeTokens` only.
- [x] 2.2 Add/update required ES and EN i18n keys in `lib/i18n/garage_*.i18n.json` and `lib/i18n/soat_*.i18n.json` for SOAT detail labels and CTAs.
- [x] 2.3 Run `dart run slang` and ensure generated localization accessors compile.

## 3. Verification and Documentation

- [x] 3.1 Add/adjust widget tests for motorcycle detail SOAT visibility and navigation to `/garage/:id/soat`.
- [x] 3.2 Add provider-level tests for user-scoped SOAT status retrieval in detail context.
- [x] 3.3 Run formatting, analysis, and targeted tests; fix findings.
- [x] 3.4 Update `FEATURES.md` if SOAT detail visibility is considered shipped behavior.

