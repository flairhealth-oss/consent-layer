// Copyright 2026 Flair Health (flairhealth-oss)
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:consent_layer/consent_layer.dart';

void main() {
  const detector = ConsentSchemaDetector();

  const fieldA = ConsentField(
    id: 'alpha',
    label: 'Alpha',
    description: 'Alpha field',
    category: 'test',
  );

  const fieldB = ConsentField(
    id: 'beta',
    label: 'Beta',
    description: 'Beta field',
    category: 'test',
  );

  const fieldC = ConsentField(
    id: 'gamma',
    label: 'Gamma',
    description: 'Gamma field',
    category: 'test',
  );

  group('ConsentSchemaDetector', () {
    test('returns null for identical lists', () {
      final result = detector.detect([fieldA, fieldB], [fieldA, fieldB]);
      expect(result, isNull);
    });

    test('returns null for two empty lists', () {
      final result = detector.detect([], []);
      expect(result, isNull);
    });

    test('detects added fields', () {
      final result = detector.detect([fieldA], [fieldA, fieldB]);
      expect(result, isNotNull);
      expect(result!.hasChanges, isTrue);
      expect(result.added, hasLength(1));
      expect(result.added.first.id, equals('beta'));
      expect(result.removed, isEmpty);
    });

    test('detects removed fields', () {
      final result = detector.detect([fieldA, fieldB], [fieldA]);
      expect(result, isNotNull);
      expect(result!.hasChanges, isTrue);
      expect(result.removed, hasLength(1));
      expect(result.removed.first.id, equals('beta'));
      expect(result.added, isEmpty);
    });

    test('detects both added and removed fields', () {
      final result = detector.detect([fieldA, fieldB], [fieldA, fieldC]);
      expect(result, isNotNull);
      expect(result!.hasChanges, isTrue);
      expect(result.added, hasLength(1));
      expect(result.added.first.id, equals('gamma'));
      expect(result.removed, hasLength(1));
      expect(result.removed.first.id, equals('beta'));
    });

    test('detects all fields added from empty', () {
      final result = detector.detect([], [fieldA, fieldB]);
      expect(result, isNotNull);
      expect(result!.added, hasLength(2));
      expect(result.removed, isEmpty);
    });

    test('detects all fields removed to empty', () {
      final result = detector.detect([fieldA, fieldB], []);
      expect(result, isNotNull);
      expect(result!.added, isEmpty);
      expect(result.removed, hasLength(2));
    });

    test('same ids different order returns null', () {
      final result = detector.detect([fieldA, fieldB], [fieldB, fieldA]);
      expect(result, isNull);
    });

    test('same id with different metadata is not a change', () {
      const modifiedA = ConsentField(
        id: 'alpha',
        label: 'Alpha V2',
        description: 'Updated description',
        category: 'updated',
      );
      final result = detector.detect([fieldA], [modifiedA]);
      expect(result, isNull);
    });
  });

  group('ConsentSchemaDiff', () {
    test('hasChanges is false when both lists are empty', () {
      const diff = ConsentSchemaDiff(added: [], removed: []);
      expect(diff.hasChanges, isFalse);
    });

    test('hasChanges is true when there are additions', () {
      const diff = ConsentSchemaDiff(added: [fieldA], removed: []);
      expect(diff.hasChanges, isTrue);
    });

    test('hasChanges is true when there are removals', () {
      const diff = ConsentSchemaDiff(added: [], removed: [fieldB]);
      expect(diff.hasChanges, isTrue);
    });

    test('toString includes counts', () {
      const diff = ConsentSchemaDiff(added: [fieldA], removed: [fieldB]);
      final str = diff.toString();
      expect(str, contains('added: 1'));
      expect(str, contains('removed: 1'));
    });
  });
}
