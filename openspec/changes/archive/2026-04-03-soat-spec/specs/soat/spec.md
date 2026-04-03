## ADDED Requirements

### Requirement: SOAT policy CRUD per motorcycle
The system SHALL allow an authenticated user to create, view, update, and delete SOAT policies linked to motorcycles they own, while preserving user data isolation.

#### Scenario: Create SOAT policy with valid fields
- **WHEN** an authenticated user submits insurer, policy number, start date, and an expiry date that is strictly after the start date for one of their motorcycles
- **THEN** the system stores the policy and makes it available in that motorcycle's SOAT history

#### Scenario: Reject invalid SOAT policy dates
- **WHEN** a user submits a SOAT policy where expiry date is the same as or before start date
- **THEN** the system MUST reject the operation and keep existing data unchanged

#### Scenario: Delete SOAT policy
- **WHEN** a user confirms deletion of one of their SOAT policies
- **THEN** the system removes that policy and it no longer appears in SOAT history results

### Requirement: Real-time SOAT history and expiry review states
The system SHALL provide real-time SOAT history per motorcycle ordered by `expiryDate` descending and SHALL compute status bands using date-only comparisons.

#### Scenario: Render SOAT history in descending expiry order
- **WHEN** SOAT records exist for a motorcycle
- **THEN** the system returns and displays records ordered from latest to earliest expiry date

#### Scenario: Compute expiry status bands
- **WHEN** the system evaluates a SOAT record against the current date
- **THEN** it assigns exactly one status from `active`, `due30`, `due15`, `due5`, or `expired` using configured day-range thresholds

### Requirement: Active SOAT lookup by normalized license plate
The system SHALL return the authenticated user's active SOAT policy for a provided license plate after normalization (uppercase, no spaces), and SHALL never expose data from other users.

#### Scenario: Find active SOAT by plate
- **WHEN** a user searches with a plate that maps to one of their motorcycles with a non-expired SOAT policy
- **THEN** the system returns that active SOAT policy details

#### Scenario: No active policy for plate
- **WHEN** a user searches a valid plate and no active SOAT policy exists for that user scope
- **THEN** the system returns a deterministic not-found result

### Requirement: SOAT UX integration with routing and localized text
The system SHALL expose SOAT flows through `go_router` routes and SHALL provide all user-facing SOAT strings in both Spanish and English localization files.

#### Scenario: Navigate to SOAT routes
- **WHEN** the user opens `/soat/lookup` or `/garage/:id/soat` flows
- **THEN** the application resolves the configured SOAT screens without breaking existing garage navigation

#### Scenario: Localized text availability
- **WHEN** the app is rendered in ES or EN locale
- **THEN** SOAT labels, actions, status text, and messages are provided from corresponding i18n keys in both locales

