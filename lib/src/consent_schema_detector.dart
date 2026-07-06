// Copyright 2026 Flair Health (flairhealth-oss)
// SPDX-License-Identifier: Apache-2.0

import 'consent_field.dart';

/// The result of comparing two consent field lists.
///
/// [ConsentSchemaDiff] captures which fields were [added] and which were
/// [removed] between two schema versions. It intentionally compares fields
/// by [ConsentField.id] only — label or description changes are not tracked
/// as schema-level differences in this version.
class ConsentSchemaDiff {
  /// Fields present in the current list but absent from the previous list.
  final List<ConsentField> added;

  /// Fields present in the previous list but absent from the current list.
  final List<ConsentField> removed;

  /// Whether any additions or removals were detected.
  bool get hasChanges => added.isNotEmpty || removed.isNotEmpty;

  /// Creates a [ConsentSchemaDiff].
  const ConsentSchemaDiff({
    required this.added,
    required this.removed,
  });

  @override
  String toString() =>
      'ConsentSchemaDiff(added: ${added.length}, removed: ${removed.length})';
}

/// Compares two consent field lists and produces a [ConsentSchemaDiff].
///
/// This is the mechanism that drives re-consent: when an app updates its
/// [ConsentFieldRegistry], the caller can detect what changed and present
/// only the delta to the user.
///
/// ```dart
/// final detector = ConsentSchemaDetector();
/// final diff = detector.detect(previousFields, currentFields);
/// if (diff != null) {
///   // show the consent sheet with the diff highlighted
/// }
/// ```
class ConsentSchemaDetector {
  /// Creates a [ConsentSchemaDetector].
  const ConsentSchemaDetector();

  /// Compares [previous] and [current] field lists by [ConsentField.id].
  ///
  /// Returns a [ConsentSchemaDiff] describing what was added and removed,
  /// or `null` if the two lists contain exactly the same set of field IDs.
  ConsentSchemaDiff? detect(
    List<ConsentField> previous,
    List<ConsentField> current,
  ) {
    final previousIds = {for (final f in previous) f.id: f};
    final currentIds = {for (final f in current) f.id: f};

    final added = <ConsentField>[
      for (final entry in currentIds.entries)
        if (!previousIds.containsKey(entry.key)) entry.value,
    ];

    final removed = <ConsentField>[
      for (final entry in previousIds.entries)
        if (!currentIds.containsKey(entry.key)) entry.value,
    ];

    if (added.isEmpty && removed.isEmpty) return null;

    return ConsentSchemaDiff(added: added, removed: removed);
  }
}
