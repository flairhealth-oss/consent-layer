# Consent Protocol — The `[withdrawn]` Contract

This document describes the integration contract between `consent_layer` and the calling application. The package produces a `ConsentState`; the caller is responsible for enforcing it.

---

## Overview

When a user reviews a consent sheet and submits their choices, the package produces a [`ConsentState`](lib/src/consent_state.dart) containing a per-field map of `accepted` or `withdrawn` statuses.

The package does **not**:
- Substitute values in your data payloads
- Intercept or modify network requests
- Persist consent decisions
- Authenticate the user

All of those responsibilities belong to the calling application. The package is a **consent primitive**, not a consent enforcement system.

---

## The `[withdrawn]` Tombstone Pattern

When the caller transmits data and a field's consent status is `withdrawn`, the caller **must** substitute a tombstone value in place of the actual data. The recommended tombstone is the literal string:

```
[withdrawn]
```

### Why a tombstone instead of omission?

Omitting a field from a payload is ambiguous — it could mean "no data available" or "user declined". A tombstone value makes the user's decision explicit and auditable. The receiving system can distinguish between:

| Payload value | Meaning |
|---|---|
| `"7.5"` | User consented; actual data transmitted |
| `"[withdrawn]"` | User explicitly declined this field |
| *(key absent)* | Field does not exist in this schema version |

### Example Integration (Pseudocode)

```dart
Map<String, dynamic> buildPayload(
  Map<String, dynamic> rawData,
  ConsentState consent,
) {
  final payload = <String, dynamic>{};

  for (final key in rawData.keys) {
    if (consent.isAccepted(key)) {
      payload[key] = rawData[key];
    } else {
      payload[key] = '[withdrawn]';
    }
  }

  return payload;
}
```

---

## Schema Versioning

Each `ConsentState` records the `schemaVersion` that was active when consent was given. When the app updates its `ConsentFieldRegistry` (adding or removing fields), the caller should:

1. Compare the new schema against the previously consented schema using `ConsentSchemaDetector`.
2. If a diff exists, present the consent sheet again with the diff highlighted.
3. Store the new `ConsentState` only after the user reviews and confirms.

This ensures that consent is never silently extended to new data fields.

---

## Why the Package Doesn't Enforce

The enforcement boundary is intentionally left to the caller because:

1. **Payload shape varies** — every app has different data models, API contracts, and serialisation formats. A generic enforcement layer would be too opinionated.
2. **Transparency over magic** — the caller's enforcement code is visible in their own codebase (and, ideally, in their own public repo). A hidden enforcement layer would re-create the Trusted Intermediary Problem this package exists to solve.
3. **Testability** — the caller can unit-test their own substitution logic against `ConsentState` without mocking package internals.

---

## Audit Trail

The `ConsentState.toJson()` method produces a serialisable snapshot suitable for logging. Callers are encouraged to persist these snapshots as an audit trail, including:

- The `schemaVersion` that was consented to
- The `consentedAt` timestamp
- The per-field `accepted` / `withdrawn` decisions

The package's own git log serves as a public record of any changes to the consent mechanism itself.
