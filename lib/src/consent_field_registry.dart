// Copyright 2026 Flair Health (flairhealth-oss)
// SPDX-License-Identifier: Apache-2.0

import 'consent_field.dart';

/// Base class for app-defined consent field registries.
///
/// The calling app subclasses [ConsentFieldRegistry] to declare the specific
/// data fields it requests consent for. The package itself is field-agnostic —
/// it knows how to present and track consent, but not what the fields mean.
///
/// ```dart
/// class MyAppFieldRegistry extends ConsentFieldRegistry {
///   @override
///   String get schemaVersion => '1.0.0';
///
///   @override
///   List<ConsentField> get fields => const [
///     ConsentField(id: 'daily_mood', label: 'Daily Mood', ...),
///   ];
/// }
/// ```
abstract class ConsentFieldRegistry {
  /// The complete list of [ConsentField]s the app requests consent for.
  ///
  /// Implementations must ensure each field has a unique [ConsentField.id].
  List<ConsentField> get fields;

  /// A version identifier for the current field schema.
  ///
  /// This should change whenever [fields] change — typically a semver string
  /// or a content hash. The consent layer uses this value to detect when
  /// re-consent is needed.
  String get schemaVersion;

  /// Looks up a field by its [ConsentField.id].
  ///
  /// Returns `null` if no field with the given [id] exists in [fields].
  ConsentField? findById(String id) {
    for (final field in fields) {
      if (field.id == id) return field;
    }
    return null;
  }

  /// Validates that all field IDs in [fields] are unique.
  ///
  /// Throws a [StateError] if duplicate IDs are found. Call this in debug
  /// builds or tests to catch configuration errors early.
  void validateUniqueIds() {
    final seen = <String>{};
    for (final field in fields) {
      if (!seen.add(field.id)) {
        throw StateError(
          'Duplicate ConsentField id: "${field.id}". '
          'Each field must have a unique id.',
        );
      }
    }
  }
}
