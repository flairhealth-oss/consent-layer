// Copyright 2026 Flair Health (flairhealth-oss)
// SPDX-License-Identifier: Apache-2.0

/// The atomic unit of consent — one piece of data the user is asked to share.
///
/// Each [ConsentField] describes a single data point that an app requests
/// access to. Fields are identified by a unique [id] and carry a user-facing
/// [label] and [description] to make the consent decision informed.
///
/// ```dart
/// const mood = ConsentField(
///   id: 'daily_mood',
///   label: 'Daily Mood',
///   description: 'Your self-reported mood rating for the day.',
///   category: 'wellbeing',
/// );
/// ```
class ConsentField {
  /// Machine-readable key (e.g. `'daily_mood'`).
  final String id;

  /// Short user-facing name (e.g. `'Daily Mood'`).
  final String label;

  /// One-sentence explanation of what this data point is.
  final String description;

  /// If `true`, the user cannot decline this field.
  ///
  /// Required fields are shown in the consent sheet with a locked toggle.
  /// Named `isRequired` to avoid collision with Dart's `required` keyword.
  final bool isRequired;

  /// Free-form category tag (e.g. `'health'`, `'behaviour'`, `'biometric'`).
  ///
  /// The package does not enforce a category vocabulary — the caller defines
  /// its own categories as plain strings.
  final String category;

  /// Creates a [ConsentField].
  ///
  /// All parameters except [isRequired] are required by the constructor.
  /// [isRequired] defaults to `false`.
  const ConsentField({
    required this.id,
    required this.label,
    required this.description,
    this.isRequired = false,
    required this.category,
  });

  /// Returns a copy of this field with the given values replaced.
  ConsentField copyWith({
    String? id,
    String? label,
    String? description,
    bool? isRequired,
    String? category,
  }) {
    return ConsentField(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      isRequired: isRequired ?? this.isRequired,
      category: category ?? this.category,
    );
  }

  /// Two fields are equal if they share the same [id].
  ///
  /// This intentionally compares only by [id] so that diff detection can
  /// match fields across schema versions even when metadata changes.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsentField &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ConsentField(id: $id, label: $label, isRequired: $isRequired, '
      'category: $category)';
}
