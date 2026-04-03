## ADDED Requirements

### Requirement: Motorcycle detail provides SOAT entry point
The system SHALL include a SOAT entry point in motorcycle detail to improve legal-document discoverability without leaving the bike context.

#### Scenario: User navigates from detail to SOAT history
- **WHEN** the user taps the SOAT section action from `/garage/:id`
- **THEN** the app navigates to `/garage/:id/soat`

#### Scenario: Detail SOAT entry is user-scoped
- **WHEN** SOAT status is rendered inside motorcycle detail
- **THEN** the status and actions are based only on the authenticated user's motorcycle data

