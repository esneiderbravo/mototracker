# Spec: Service — [ServiceName]

> **For the AI assistant:** Read `openspec/ARCHITECTURE.md` before generating any code.

---

## Meta

| Field | Value |
|---|---|
| **Service** | `features/<feature>/domain/services/<service>_service.dart` |
| **Status** | `draft` \| `ready` \| `implemented` |
| **Date** | YYYY-MM-DD |

---

## Purpose

<!-- What this service does, what external system or logic it encapsulates -->

---

## Contract (Abstract)

```dart
// lib/features/<feature>/domain/services/<service>_service.dart

abstract class <Service>Service {
  /// Method description: what it receives, what it returns, when it can fail.
  Future<<ReturnType>> methodName({
    required String param1,
    int param2 = 0,
  });

  // More methods...
}
```

---

## Concrete Implementation

```dart
// lib/features/<feature>/data/<impl>_<service>_service.dart

class <Impl><Service>Service implements <Service>Service {
  const <Impl><Service>Service({required this.dependency});

  final <DependencyType> dependency;

  @override
  Future<<ReturnType>> methodName({ ... }) async {
    // Description of expected behavior
  }
}
```

---

## Provider

```dart
// Add to lib/features/<feature>/presentation/providers/<feature>_providers.dart

final <service>ServiceProvider = Provider<<Service>Service>((ref) {
  final dep = ref.watch(<dependency>Provider);
  return <Impl><Service>Service(dependency: dep);
});
```

---

## Error Handling

| Case | Expected behavior |
|---|---|
| Network timeout | Throw `ServiceException` with descriptive message |
| Invalid response | Return `null` or empty list (do not throw) |
| Invalid API key | Throw `ServiceException('Invalid API key')` |

---

## Acceptance Criteria

- [ ] AC-1: Method returns the expected type on the happy path.
- [ ] AC-2: Handles timeout without crashing the app.
- [ ] AC-3: The provider can be injected in any widget via `ref.watch`.
- [ ] AC-4: Errors are catchable with `try/catch`.

---

## References

- `lib/features/ai/domain/services/ai_service.dart` — existing abstract service pattern
- `lib/features/ai/data/` — concrete implementation pattern

