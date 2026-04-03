## ADDED Requirements

### Requirement: SOAT status visibility from motorcycle detail
The system SHALL expose SOAT status and direct actions from the motorcycle detail context so users can immediately know coverage state for that bike.

#### Scenario: User opens motorcycle detail with active SOAT
- **WHEN** an authenticated user opens `/garage/:id` for a motorcycle with an active SOAT policy
- **THEN** the app shows a visible SOAT section with current status and an action to open `/garage/:id/soat`

#### Scenario: User opens motorcycle detail with no active SOAT
- **WHEN** an authenticated user opens `/garage/:id` and no active SOAT exists for that motorcycle
- **THEN** the app shows a deterministic missing/expired SOAT state and an action to create or review SOAT

