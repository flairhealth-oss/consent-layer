// Copyright 2026 Flair Health (flairhealth-oss)
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:consent_layer/consent_layer.dart';

void main() {
  group('ConsentState', () {
    final testTime = DateTime.utc(2026, 7, 6, 12, 0, 0);

    final state = ConsentState(
      fieldStatuses: {
        'alpha': ConsentFieldStatus.accepted,
        'beta': ConsentFieldStatus.withdrawn,
        'gamma': ConsentFieldStatus.accepted,
      },
      consentedAt: testTime,
      schemaVersion: '1.0.0',
    );

    test('isAccepted returns true for accepted fields', () {
      expect(state.isAccepted('alpha'), isTrue);
      expect(state.isAccepted('gamma'), isTrue);
    });

    test('isAccepted returns false for withdrawn fields', () {
      expect(state.isAccepted('beta'), isFalse);
    });

    test('isAccepted returns false for unknown fields', () {
      expect(state.isAccepted('nonexistent'), isFalse);
    });

    group('JSON round-trip', () {
      test('toJson produces expected structure', () {
        final json = state.toJson();
        expect(json['schemaVersion'], equals('1.0.0'));
        expect(json['consentedAt'], equals(testTime.toIso8601String()));
        expect(json['fieldStatuses'], isA<Map<String, dynamic>>());
        expect(json['fieldStatuses']['alpha'], equals('accepted'));
        expect(json['fieldStatuses']['beta'], equals('withdrawn'));
      });

      test('fromJson reconstructs identical state', () {
        final json = state.toJson();
        final restored = ConsentState.fromJson(json);

        expect(restored.schemaVersion, equals(state.schemaVersion));
        expect(restored.consentedAt, equals(state.consentedAt));
        expect(
          restored.fieldStatuses.length,
          equals(state.fieldStatuses.length),
        );
        for (final entry in state.fieldStatuses.entries) {
          expect(restored.fieldStatuses[entry.key], equals(entry.value));
        }
      });

      test('round-trip preserves DateTime precision', () {
        // Use a timestamp with microseconds to verify precision.
        final preciseTime = DateTime.utc(2026, 7, 6, 12, 34, 56, 789);
        final preciseState = ConsentState(
          fieldStatuses: {'x': ConsentFieldStatus.accepted},
          consentedAt: preciseTime,
          schemaVersion: '2.0.0',
        );

        final restored = ConsentState.fromJson(preciseState.toJson());
        expect(restored.consentedAt, equals(preciseTime));
      });

      test('round-trip with empty fieldStatuses', () {
        final emptyState = ConsentState(
          fieldStatuses: const {},
          consentedAt: testTime,
          schemaVersion: '1.0.0',
        );

        final restored = ConsentState.fromJson(emptyState.toJson());
        expect(restored.fieldStatuses, isEmpty);
        expect(restored.schemaVersion, equals('1.0.0'));
      });
    });

    group('fromJson error handling', () {
      test('throws FormatException for missing fieldStatuses', () {
        expect(
          () => ConsentState.fromJson({
            'consentedAt': '2026-07-06T12:00:00.000Z',
            'schemaVersion': '1.0.0',
          }),
          throwsFormatException,
        );
      });

      test('throws FormatException for missing consentedAt', () {
        expect(
          () => ConsentState.fromJson({
            'fieldStatuses': <String, dynamic>{},
            'schemaVersion': '1.0.0',
          }),
          throwsFormatException,
        );
      });

      test('throws FormatException for missing schemaVersion', () {
        expect(
          () => ConsentState.fromJson({
            'fieldStatuses': <String, dynamic>{},
            'consentedAt': '2026-07-06T12:00:00.000Z',
          }),
          throwsFormatException,
        );
      });

      test('throws FormatException for unknown status value', () {
        expect(
          () => ConsentState.fromJson({
            'fieldStatuses': {'x': 'invalid_status'},
            'consentedAt': '2026-07-06T12:00:00.000Z',
            'schemaVersion': '1.0.0',
          }),
          throwsFormatException,
        );
      });
    });

    test('toString includes key info', () {
      final str = state.toString();
      expect(str, contains('1.0.0'));
      expect(str, contains('3')); // field count
    });
  });
}
