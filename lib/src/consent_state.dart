// Copyright 2026 Flair Health (flairhealth-oss)
// SPDX-License-Identifier: Apache-2.0

/// Whether a user accepted or withdrew consent for a specific field.
enum ConsentFieldStatus {
  /// The user agreed to share this data field.
  accepted,

  /// The user declined to share this data field.
  ///
  /// The caller is responsible for substituting `"[withdrawn]"` (or an
  /// equivalent tombstone) in any payload that would otherwise contain
  /// this field's data. See `CONSENT_PROTOCOL.md` for details.
  withdrawn,
}

/// The immutable result of a consent review session.
///
/// A [ConsentState] records the user's per-field decisions at a specific
/// point in time, tied to a particular [schemaVersion]. It is a pure data
/// object — the package does not persist it. The caller is responsible for
/// storing, transmitting, and enforcing the state.
///
/// ```dart
/// if (consentState.isAccepted('daily_mood')) {
///   payload['daily_mood'] = actualValue;
/// } else {
///   payload['daily_mood'] = '[withdrawn]';
/// }
/// ```
class ConsentState {
  /// Per-field consent decisions, keyed by [ConsentField.id].
  final Map<String, ConsentFieldStatus> fieldStatuses;

  /// When the user completed the consent review.
  final DateTime consentedAt;

  /// The schema version that was active when consent was given.
  ///
  /// This ties the consent decision to a specific set of fields, enabling
  /// the caller to detect when re-consent is needed.
  final String schemaVersion;

  /// Creates a [ConsentState].
  const ConsentState({
    required this.fieldStatuses,
    required this.consentedAt,
    required this.schemaVersion,
  });

  /// Returns `true` if the user accepted the field with the given [fieldId].
  ///
  /// Returns `false` if the field was withdrawn or if no decision exists
  /// for that field ID (defensive — absent fields are treated as not accepted).
  bool isAccepted(String fieldId) {
    return fieldStatuses[fieldId] == ConsentFieldStatus.accepted;
  }

  /// Serialises this consent state to a JSON-compatible map.
  ///
  /// The [consentedAt] timestamp is stored as an ISO 8601 string to ensure
  /// lossless round-tripping via [ConsentState.fromJson].
  Map<String, dynamic> toJson() {
    return {
      'fieldStatuses': fieldStatuses.map(
        (key, value) => MapEntry(key, value.name),
      ),
      'consentedAt': consentedAt.toIso8601String(),
      'schemaVersion': schemaVersion,
    };
  }

  /// Deserialises a [ConsentState] from a JSON map produced by [toJson].
  ///
  /// Throws a [FormatException] if the map structure is invalid.
  factory ConsentState.fromJson(Map<String, dynamic> json) {
    final rawStatuses = json['fieldStatuses'] as Map<String, dynamic>?;
    if (rawStatuses == null) {
      throw const FormatException(
        'ConsentState.fromJson: missing "fieldStatuses" key',
      );
    }

    final fieldStatuses = rawStatuses.map<String, ConsentFieldStatus>(
      (key, value) {
        final status = ConsentFieldStatus.values.firstWhere(
          (s) => s.name == value,
          orElse: () => throw FormatException(
            'ConsentState.fromJson: unknown status "$value" for field "$key"',
          ),
        );
        return MapEntry(key, status);
      },
    );

    final consentedAtRaw = json['consentedAt'] as String?;
    if (consentedAtRaw == null) {
      throw const FormatException(
        'ConsentState.fromJson: missing "consentedAt" key',
      );
    }

    final schemaVersion = json['schemaVersion'] as String?;
    if (schemaVersion == null) {
      throw const FormatException(
        'ConsentState.fromJson: missing "schemaVersion" key',
      );
    }

    return ConsentState(
      fieldStatuses: fieldStatuses,
      consentedAt: DateTime.parse(consentedAtRaw),
      schemaVersion: schemaVersion,
    );
  }

  @override
  String toString() =>
      'ConsentState(schemaVersion: $schemaVersion, '
      'consentedAt: $consentedAt, '
      'fields: ${fieldStatuses.length})';
}
