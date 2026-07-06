// Copyright 2026 Flair Health (flairhealth-oss)
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:consent_layer/consent_layer.dart';

void main() {
  const fields = [
    ConsentField(
      id: 'mood',
      label: 'Daily Mood',
      description: 'Your self-reported mood.',
      category: 'wellbeing',
    ),
    ConsentField(
      id: 'water',
      label: 'Water Intake',
      description: 'Glasses of water consumed.',
      category: 'wellbeing',
    ),
    ConsentField(
      id: 'name',
      label: 'Display Name',
      description: 'Your name shown in the app.',
      isRequired: true,
      category: 'identity',
    ),
  ];

  Widget buildSheet({
    ConsentSchemaDiff? diff,
    void Function(ConsentState)? onConsented,
    VoidCallback? onDismissed,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ConsentReviewSheet(
          fields: fields,
          diff: diff,
          requesterName: 'Test App',
          schemaVersion: '1.0.0',
          onConsented: onConsented ?? (_) {},
          onDismissed: onDismissed,
        ),
      ),
    );
  }

  group('ConsentReviewSheet', () {
    testWidgets('renders all field labels', (tester) async {
      await tester.pumpWidget(buildSheet());

      expect(find.text('Daily Mood'), findsOneWidget);
      expect(find.text('Water Intake'), findsOneWidget);
      expect(find.text('Display Name'), findsOneWidget);
    });

    testWidgets('renders all field descriptions', (tester) async {
      await tester.pumpWidget(buildSheet());

      expect(find.text('Your self-reported mood.'), findsOneWidget);
      expect(find.text('Glasses of water consumed.'), findsOneWidget);
      expect(find.text('Your name shown in the app.'), findsOneWidget);
    });

    testWidgets('renders requester name in header', (tester) async {
      await tester.pumpWidget(buildSheet());

      expect(
        find.textContaining('Test App'),
        findsOneWidget,
      );
    });

    testWidgets('shows REQUIRED badge for required fields', (tester) async {
      await tester.pumpWidget(buildSheet());

      expect(find.text('REQUIRED'), findsOneWidget);
    });

    testWidgets('shows NEW badge when diff has added fields', (tester) async {
      final diff = ConsentSchemaDiff(
        added: [fields[1]], // water is new
        removed: const [],
      );

      await tester.pumpWidget(buildSheet(diff: diff));

      expect(find.text('NEW'), findsOneWidget);
    });

    testWidgets('does not show NEW badge when no diff', (tester) async {
      await tester.pumpWidget(buildSheet());

      expect(find.text('NEW'), findsNothing);
    });

    testWidgets('required field toggle is disabled', (tester) async {
      await tester.pumpWidget(buildSheet());

      // Find all Switch widgets.
      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches, hasLength(3));

      // The third field ('name') is required — its switch should be disabled.
      // Order matches the fields list order.
      expect(switches[2].onChanged, isNull);
    });

    testWidgets('optional field toggle can be turned off', (tester) async {
      await tester.pumpWidget(buildSheet());

      // Tap the first switch (mood — optional).
      final switchFinder = find.byType(Switch);
      await tester.tap(switchFinder.first);
      await tester.pump();

      // After tapping, the switch should be off.
      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches[0].value, isFalse);
    });

    testWidgets('confirm produces ConsentState with correct statuses',
        (tester) async {
      ConsentState? captured;

      await tester.pumpWidget(buildSheet(
        onConsented: (state) => captured = state,
      ));

      // Turn off the first field (mood).
      await tester.tap(find.byType(Switch).first);
      await tester.pump();

      // Tap confirm.
      await tester.tap(find.text('Confirm'));
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!.fieldStatuses['mood'], ConsentFieldStatus.withdrawn);
      expect(captured!.fieldStatuses['water'], ConsentFieldStatus.accepted);
      expect(captured!.fieldStatuses['name'], ConsentFieldStatus.accepted);
      expect(captured!.schemaVersion, equals('1.0.0'));
    });

    testWidgets('confirm with all defaults produces all accepted',
        (tester) async {
      ConsentState? captured;

      await tester.pumpWidget(buildSheet(
        onConsented: (state) => captured = state,
      ));

      await tester.tap(find.text('Confirm'));
      await tester.pump();

      expect(captured, isNotNull);
      for (final status in captured!.fieldStatuses.values) {
        expect(status, ConsentFieldStatus.accepted);
      }
    });

    testWidgets('dismiss button calls onDismissed', (tester) async {
      var dismissed = false;

      await tester.pumpWidget(buildSheet(
        onDismissed: () => dismissed = true,
      ));

      // Find the close icon button.
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(dismissed, isTrue);
    });
  });
}
