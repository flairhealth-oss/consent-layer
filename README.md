# consent_layer

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![pub package](https://img.shields.io/pub/v/consent_layer.svg)](https://pub.dev/packages/consent_layer)

A field-definable consent enforcement primitive for Flutter apps. Define the data fields your app requests, detect when the schema changes, present users with a per-field consent review, and produce an auditable `ConsentState` — all without hardcoding any specific field definitions into the package.

---

## Why This Exists

**The Trusted Intermediary Problem.** When an app collects user data and also enforces the user's consent preferences, the app is both the party being consented to *and* the party that controls the enforcement. A future update could quietly weaken the enforcement — and users would have no way to detect it.

`consent_layer` is a reference implementation of the consent primitive, extracted from Flair Health's private codebase into a public, open-source package:

- **Any change to this package requires a public commit** in a named engineer's name.
- **Third parties can audit** exactly what this reference implementation does.
- **Other apps can adopt** the same consent mechanism, creating a shared standard.

This package's git log *is* the transparency log — for the package itself. As of this writing, Flair's shipped app does not yet depend on `consent_layer`; its production enforcement is a private superset that has diverged from this package since July 2026. Re-convergence (the app depending on this package directly) is planned but not yet complete. See [CONSENT_PROTOCOL.md](CONSENT_PROTOCOL.md) for the enforcement contract this package defines.

---

## Quick Start

### 1. Add the dependency

```yaml
dependencies:
  consent_layer: ^1.0.0
```

### 2. Define your fields

Subclass `ConsentFieldRegistry` with the data fields your app requests:

```dart
class MyAppFieldRegistry extends ConsentFieldRegistry {
  @override
  String get schemaVersion => '1.0.0';

  @override
  List<ConsentField> get fields => const [
    ConsentField(
      id: 'daily_mood',
      label: 'Daily Mood',
      description: 'Your self-reported mood rating for the day.',
      category: 'wellbeing',
    ),
    ConsentField(
      id: 'water_intake',
      label: 'Water Intake',
      description: 'Number of glasses of water consumed today.',
      category: 'nutrition',
    ),
    ConsentField(
      id: 'display_name',
      label: 'Display Name',
      description: 'The name shown on your profile.',
      isRequired: true,  // user cannot decline this field
      category: 'identity',
    ),
  ];
}
```

### 3. Show the consent sheet

```dart
final registry = MyAppFieldRegistry();

showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (_) => ConsentReviewSheet(
    fields: registry.fields,
    requesterName: 'My App',
    schemaVersion: registry.schemaVersion,
    onConsented: (ConsentState state) {
      // Persist the consent state and enforce it in your payloads.
      saveConsentState(state);
      Navigator.pop(context);
    },
    onDismissed: () => Navigator.pop(context),
  ),
);
```

### 4. Enforce the `[withdrawn]` contract

The package produces a `ConsentState`. Your app is responsible for substituting `"[withdrawn]"` for any field the user declined:

```dart
Map<String, dynamic> buildPayload(
  Map<String, dynamic> rawData,
  ConsentState consent,
) {
  return {
    for (final key in rawData.keys)
      key: consent.isAccepted(key) ? rawData[key] : '[withdrawn]',
  };
}
```

See [`CONSENT_PROTOCOL.md`](CONSENT_PROTOCOL.md) for the full contract specification.

---

## Schema Versioning & Diff Detection

When your app adds or removes fields, bump the `schemaVersion` in your registry. Use `ConsentSchemaDetector` to detect the change and present only the delta:

```dart
final detector = ConsentSchemaDetector();
final diff = detector.detect(previousRegistry.fields, currentRegistry.fields);

if (diff != null) {
  // Schema changed — show consent sheet with new fields highlighted.
  showModalBottomSheet(
    context: context,
    builder: (_) => ConsentReviewSheet(
      fields: currentRegistry.fields,
      diff: diff,  // new fields will show a "NEW" badge
      requesterName: 'My App',
      schemaVersion: currentRegistry.schemaVersion,
      onConsented: (state) { /* ... */ },
    ),
  );
}
```

`ConsentSchemaDetector.detect()` compares field lists by `id` and returns:
- `ConsentSchemaDiff.added` — fields in the new list not present in the old
- `ConsentSchemaDiff.removed` — fields in the old list not present in the new
- `null` — if the field sets are identical

---

## API Reference

| Type | Purpose |
|---|---|
| `ConsentField` | Immutable data class — one consent-able field with `id`, `label`, `description`, `isRequired`, `category` |
| `ConsentFieldRegistry` | Abstract base — subclass to define your app's fields and schema version |
| `ConsentSchemaDetector` | Stateless comparator — detects added/removed fields between two schema versions |
| `ConsentSchemaDiff` | Result of a schema comparison — lists of `added` and `removed` fields |
| `ConsentFieldStatus` | Enum — `accepted` or `withdrawn` |
| `ConsentState` | Immutable consent session result — per-field statuses, timestamp, schema version, JSON serialisation |
| `ConsentReviewSheet` | Flutter widget — per-field consent UI with diff highlighting, required-field locking, theme-driven styling |

---

## Theming

`ConsentReviewSheet` inherits its visual style entirely from `Theme.of(context)`. It contains no hardcoded colours, fonts, or branding. Style it the same way you style any Material widget:

```dart
MaterialApp(
  theme: ThemeData(
    colorSchemeSeed: Colors.indigo,
    useMaterial3: true,
  ),
  // ...
);
```

---

## What This Package Does NOT Do

This package is a **consent primitive**. It intentionally does not:

- Persist consent state (you choose your storage)
- Make network requests
- Handle authentication or biometric prompts
- Sign or encrypt consent records (Phase 2 / Phase 3)
- Define specific data fields (you define those)

---

## Provenance

`consent_layer` was extracted from [Flair Health](https://flairhealth.app),
a privacy-first health intelligence app for iOS, as a reference
implementation of Flair's consent primitive. Flair's shipped app does not
yet depend on this package directly — its production consent enforcement
currently lives in Flair's private codebase and has diverged from this
package since the July 2026 extraction. Re-convergence is planned. We
open-sourced the enforcement layer so any app can adopt the same model —
and so that every future change to the primitive is public, attributable,
and auditable by anyone.

---

## License

```
Copyright 2026 Flair Health (flairhealth-oss)

Licensed under the Apache License, Version 2.0.
See LICENSE for details.
```
