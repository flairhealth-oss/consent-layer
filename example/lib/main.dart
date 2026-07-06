// Copyright 2026 Flair Health (flairhealth-oss)
// SPDX-License-Identifier: Apache-2.0

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:consent_layer/consent_layer.dart';

// ---------------------------------------------------------------------------
// 1. Define your app's fields by subclassing ConsentFieldRegistry.
//    These are entirely fictional — your app defines its own.
// ---------------------------------------------------------------------------

class WellbeingFieldRegistryV1 extends ConsentFieldRegistry {
  @override
  String get schemaVersion => '1.0.0';

  @override
  List<ConsentField> get fields => const [
        ConsentField(
          id: 'daily_mood',
          label: 'Daily Mood',
          description: 'Your self-reported mood rating for the day.',
          category: 'wellbeing',
        ),
        ConsentField(
          id: 'water_intake',
          label: 'Water Intake',
          description: 'Number of glasses of water consumed today.',
          category: 'nutrition',
        ),
        ConsentField(
          id: 'display_name',
          label: 'Display Name',
          description: 'The name shown on your profile.',
          isRequired: true,
          category: 'identity',
        ),
      ];
}

/// V2 adds a new field ("journal_entry") to demonstrate diff detection.
class WellbeingFieldRegistryV2 extends ConsentFieldRegistry {
  @override
  String get schemaVersion => '2.0.0';

  @override
  List<ConsentField> get fields => const [
        ConsentField(
          id: 'daily_mood',
          label: 'Daily Mood',
          description: 'Your self-reported mood rating for the day.',
          category: 'wellbeing',
        ),
        ConsentField(
          id: 'water_intake',
          label: 'Water Intake',
          description: 'Number of glasses of water consumed today.',
          category: 'nutrition',
        ),
        ConsentField(
          id: 'display_name',
          label: 'Display Name',
          description: 'The name shown on your profile.',
          isRequired: true,
          category: 'identity',
        ),
        ConsentField(
          id: 'journal_entry',
          label: 'Journal Entry',
          description: 'Your free-text journal notes for the day.',
          category: 'wellbeing',
        ),
      ];
}

// ---------------------------------------------------------------------------
// 2. App entry point
// ---------------------------------------------------------------------------

void main() {
  runApp(const WellbeingTrackerApp());
}

class WellbeingTrackerApp extends StatelessWidget {
  const WellbeingTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wellbeing Tracker — Consent Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const DemoHomePage(),
    );
  }
}

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  ConsentState? _lastConsentState;

  void _showInitialConsent() {
    final registry = WellbeingFieldRegistryV1();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ConsentReviewSheet(
        fields: registry.fields,
        requesterName: 'Wellbeing Tracker',
        schemaVersion: registry.schemaVersion,
        onConsented: (state) {
          setState(() => _lastConsentState = state);
          Navigator.pop(context);
          _printConsentState(state);
        },
        onDismissed: () => Navigator.pop(context),
      ),
    );
  }

  void _showSchemaChangeConsent() {
    final v1 = WellbeingFieldRegistryV1();
    final v2 = WellbeingFieldRegistryV2();
    const detector = ConsentSchemaDetector();
    final diff = detector.detect(v1.fields, v2.fields);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ConsentReviewSheet(
        fields: v2.fields,
        diff: diff,
        requesterName: 'Wellbeing Tracker',
        schemaVersion: v2.schemaVersion,
        onConsented: (state) {
          setState(() => _lastConsentState = state);
          Navigator.pop(context);
          _printConsentState(state);
        },
        onDismissed: () => Navigator.pop(context),
      ),
    );
  }

  void _printConsentState(ConsentState state) {
    print('--- Consent State ---');
    print('Schema version: ${state.schemaVersion}');
    print('Consented at:   ${state.consentedAt.toIso8601String()}');
    for (final entry in state.fieldStatuses.entries) {
      print('  ${entry.key}: ${entry.value.name}');
    }
    print('JSON: ${state.toJson()}');
    print('---------------------');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consent Layer Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Wellbeing Tracker',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'This fictional app demonstrates the consent_layer package. '
              'Tap a button below to see the consent review sheet.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _showInitialConsent,
              icon: const Icon(Icons.verified_user),
              label: const Text('Initial Consent (v1)'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _showSchemaChangeConsent,
              icon: const Icon(Icons.difference),
              label: const Text('Schema Change (v1 → v2)'),
            ),
            const SizedBox(height: 32),
            if (_lastConsentState != null) ...[
              Text(
                'Last Consent State',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Schema: ${_lastConsentState!.schemaVersion}',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      ..._lastConsentState!.fieldStatuses.entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Icon(
                                e.value == ConsentFieldStatus.accepted
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                size: 16,
                                color:
                                    e.value == ConsentFieldStatus.accepted
                                        ? Colors.green
                                        : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${e.key}: ${e.value.name}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
