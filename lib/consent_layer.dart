// Copyright 2026 Flair Health (flairhealth-oss)
// SPDX-License-Identifier: Apache-2.0

/// A field-definable consent enforcement primitive for Flutter apps.
///
/// This package provides the mechanism for per-field consent review. It is
/// field-agnostic: the calling app defines what fields exist by subclassing
/// [ConsentFieldRegistry]. The package handles schema diffing, UI
/// presentation, and consent state production.
///
/// See [CONSENT_PROTOCOL.md](https://github.com/flairhealth-oss/consent-layer/blob/main/CONSENT_PROTOCOL.md)
/// for the `[withdrawn]` tombstone contract that callers must implement.
library;

export 'src/consent_field.dart';
export 'src/consent_field_registry.dart';
export 'src/consent_schema_detector.dart';
export 'src/consent_state.dart';
export 'src/consent_review_sheet.dart';
