# Spec: Widget — [WidgetName]

> **For the AI assistant:** Read `openspec/ARCHITECTURE.md` before generating any code.

---

## Meta

| Field | Value |
|---|---|
| **Widget** | `shared/widgets/<widget_name>.dart` |
| **Status** | `draft` \| `ready` \| `implemented` |
| **Date** | YYYY-MM-DD |

---

## Purpose

<!-- One sentence: what this widget does and when to use it -->

---

## API (Widget Signature)

```dart
// lib/shared/widgets/<widget_name>.dart

class <WidgetName> extends StatelessWidget {
  const <WidgetName>({
    super.key,
    required this.param1,      // Parameter description
    this.param2,               // Description, why it's optional
    this.onTap,                // Callback if applicable
  });

  final <Type> param1;
  final <Type>? param2;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) { ... }
}
```

---

## Variants / States

| State | Visual description |
|---|---|
| Default | Normal state description |
| Loading | Skeleton or shimmer |
| Error | Error icon + message |
| Empty | Icon + empty message |
| Disabled | Reduced opacity, no interaction |

---

## Theme Tokens to Use

```dart
// Always use ThemeTokens — never hardcode colors
ThemeTokens.surface          // Widget background
ThemeTokens.primary          // Action / emphasis color
ThemeTokens.textSecondary    // Secondary text
ThemeTokens.border           // Borders
```

---

## Usage Example

```dart
// How it's used in a screen
<WidgetName>(
  param1: value1,
  param2: value2,
  onTap: () => context.push('/route'),
)
```

---

## Acceptance Criteria

- [ ] AC-1: Works correctly with only the required parameter.
- [ ] AC-2: Respects all ThemeTokens (no hardcoded colors).
- [ ] AC-3: The `onTap` callback works when provided.
- [ ] AC-4: Renders correctly on small screens (375px width).
- [ ] AC-5: Does not break layout on very long text (overflow safe).

---

## References

- `lib/shared/widgets/` — existing widgets for pattern consistency
- `lib/core/theme/theme_tokens.dart` — color tokens

