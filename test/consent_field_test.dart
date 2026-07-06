// Copyright 2026 Flair Health (flairhealth-oss)
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:consent_layer/consent_layer.dart';

void main() {
  group('ConsentField', () {
    const fieldA = ConsentField(
      id: 'alpha',
      label: 'Alpha',
      description: 'First field',
      category: 'test',
    );

    const fieldACopy = ConsentField(
      id: 'alpha',
      label: 'Alpha Modified',
      description: 'Different description',
      category: 'other',
    );

    const fieldB = ConsentField(
      id: 'beta',
      label: 'Beta',
      description: 'Second field',
      category: 'test',
    );

    test('equality is based on id only', () {
      expect(fieldA, equals(fieldACopy));
      expect(fieldA, isNot(equals(fieldB)));
    });

    test('hashCode is based on id only', () {
      expect(fieldA.hashCode, equals(fieldACopy.hashCode));
    });

    test('isRequired defaults to false', () {
      expect(fieldA.isRequired, isFalse);
    });

    test('isRequired can be set to true', () {
      const required = ConsentField(
        id: 'gamma',
        label: 'Gamma',
        description: 'Required field',
        isRequired: true,
        category: 'test',
      );
      expect(required.isRequired, isTrue);
    });

    test('copyWith replaces specified values', () {
      final modified = fieldA.copyWith(
        label: 'New Label',
        isRequired: true,
      );
      expect(modified.id, equals('alpha'));
      expect(modified.label, equals('New Label'));
      expect(modified.description, equals('First field'));
      expect(modified.isRequired, isTrue);
      expect(modified.category, equals('test'));
    });

    test('copyWith with no arguments returns identical values', () {
      final copy = fieldA.copyWith();
      expect(copy.id, equals(fieldA.id));
      expect(copy.label, equals(fieldA.label));
      expect(copy.description, equals(fieldA.description));
      expect(copy.isRequired, equals(fieldA.isRequired));
      expect(copy.category, equals(fieldA.category));
    });

    test('toString includes key properties', () {
      final str = fieldA.toString();
      expect(str, contains('alpha'));
      expect(str, contains('Alpha'));
      expect(str, contains('test'));
    });
  });

  group('ConsentFieldRegistry', () {
    test('findById returns matching field', () {
      final registry = _TestRegistry([
        const ConsentField(
          id: 'one',
          label: 'One',
          description: 'First',
          category: 'cat',
        ),
        const ConsentField(
          id: 'two',
          label: 'Two',
          description: 'Second',
          category: 'cat',
        ),
      ]);

      final found = registry.findById('two');
      expect(found, isNotNull);
      expect(found!.label, equals('Two'));
    });

    test('findById returns null for unknown id', () {
      final registry = _TestRegistry([
        const ConsentField(
          id: 'one',
          label: 'One',
          description: 'First',
          category: 'cat',
        ),
      ]);

      expect(registry.findById('unknown'), isNull);
    });

    test('validateUniqueIds passes with unique ids', () {
      final registry = _TestRegistry([
        const ConsentField(
          id: 'a',
          label: 'A',
          description: 'A',
          category: 'cat',
        ),
        const ConsentField(
          id: 'b',
          label: 'B',
          description: 'B',
          category: 'cat',
        ),
      ]);

      expect(() => registry.validateUniqueIds(), returnsNormally);
    });

    test('validateUniqueIds throws on duplicate ids', () {
      final registry = _TestRegistry([
        const ConsentField(
          id: 'dup',
          label: 'First',
          description: 'First',
          category: 'cat',
        ),
        const ConsentField(
          id: 'dup',
          label: 'Second',
          description: 'Second',
          category: 'cat',
        ),
      ]);

      expect(() => registry.validateUniqueIds(), throwsStateError);
    });
  });
}

class _TestRegistry extends ConsentFieldRegistry {
  final List<ConsentField> _fields;

  _TestRegistry(this._fields);

  @override
  List<ConsentField> get fields => _fields;

  @override
  String get schemaVersion => '1.0.0';
}
