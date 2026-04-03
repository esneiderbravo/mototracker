# Spec: Profile Identification

---

## Meta

| Field | Value |
|---|---|
| **Feature** | `features/profile` |
| **Status** | `implemented` |
| **Date** | 2026-04-03 |
| **Roadmap ref** | `FEATURES.md → Profile Identification` |

---

## Purpose

Capture and validate user identification fields (`documentType`, `documentNumber`) in the user profile so that external RUNT Colombia queries can be authenticated on behalf of the user.

---

## Requirements

### Requirement: Profile stores required identification for RUNT lookup
The system SHALL require authenticated users to provide and persist identification fields (`documentType`, `documentNumber`) before RUNT SOAT lookup can be executed.

#### Scenario: User saves valid identification in profile
- **WHEN** the user enters a supported document type and a valid document number and saves profile
- **THEN** the system persists those identification fields under the authenticated user profile

#### Scenario: Missing identification blocks RUNT lookup eligibility
- **WHEN** an authenticated user has missing identification fields in profile
- **THEN** the system marks RUNT lookup as unavailable and shows a deterministic prompt to complete profile

### Requirement: Identification values are validated and normalized
The system SHALL validate and normalize profile identification values before storage and usage in RUNT request payloads.

#### Scenario: Document number contains spaces or lowercase input artifacts
- **WHEN** the user saves a document number with formatting artifacts
- **THEN** the system stores a normalized value suitable for RUNT requests and rejects invalid format values

---

## Data Model

Identification is stored in Supabase Auth `user_metadata` using the following keys:

| Key | Type | Description |
|---|---|---|
| `document_type` | String | RUNT code: `C` (C.C.), `CE` (C.E.), `P` (Pasaporte) |
| `document_number` | String | Normalized digits-only national ID number |

---

## Domain Entity

```dart
// lib/features/profile/domain/entities/profile_identification.dart

enum DocumentType { cc, ce, pas }

class ProfileIdentification {
  const ProfileIdentification({
    required this.documentType,
    required this.documentNumber,
  });

  final DocumentType documentType;
  final String documentNumber; // normalized digits-only

  bool get isComplete => documentNumber.isNotEmpty;

  static ProfileIdentification? fromMetadata(Map<String, dynamic>? metadata);
  Map<String, String> toMetadataEntries();
}
```

---

## References

- `lib/features/profile/domain/entities/profile_identification.dart`
- `lib/features/auth/domain/repositories/auth_repository.dart`
- `lib/features/auth/data/supabase_auth_repository.dart`
- `lib/features/profile/presentation/screens/profile_screen.dart`

