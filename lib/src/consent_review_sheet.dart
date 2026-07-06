// Copyright 2026 Flair Health (flairhealth-oss)
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import 'consent_field.dart';
import 'consent_schema_detector.dart';
import 'consent_state.dart';

/// A Flutter widget that presents consent fields for user review.
///
/// [ConsentReviewSheet] displays each [ConsentField] with its label and
/// description, a toggle for the user to accept or withdraw consent, and
/// optional diff highlighting for newly added fields.
///
/// Required fields (where [ConsentField.isRequired] is `true`) are displayed
/// with a locked toggle that cannot be turned off.
///
/// The widget inherits its visual style entirely from the ambient [ThemeData].
/// It contains no hardcoded colours, fonts, or branding — the caller controls
/// appearance through Flutter's standard theming mechanism.
///
/// ```dart
/// ConsentReviewSheet(
///   fields: registry.fields,
///   diff: schemaDiff,
///   requesterName: 'My App',
///   onConsented: (state) => saveConsentState(state),
///   onDismissed: () => Navigator.pop(context),
/// );
/// ```
class ConsentReviewSheet extends StatefulWidget {
  /// The fields being requested for consent.
  final List<ConsentField> fields;

  /// If non-null, newly [added] fields are visually highlighted.
  final ConsentSchemaDiff? diff;

  /// Called when the user completes the consent review.
  ///
  /// The [ConsentState] contains per-field decisions (accepted or withdrawn),
  /// a timestamp, and the schema version. The caller is responsible for
  /// persisting this state and enforcing `[withdrawn]` substitution.
  final void Function(ConsentState state) onConsented;

  /// Called when the user dismisses the sheet without consenting.
  ///
  /// If `null`, the dismiss button is still shown but performs no action
  /// beyond closing the widget.
  final VoidCallback? onDismissed;

  /// Name of the entity requesting data access, displayed in the header.
  final String requesterName;

  /// The schema version to stamp onto the resulting [ConsentState].
  ///
  /// This should match the [ConsentFieldRegistry.schemaVersion] that
  /// produced the [fields] list.
  final String schemaVersion;

  /// Creates a [ConsentReviewSheet].
  const ConsentReviewSheet({
    super.key,
    required this.fields,
    this.diff,
    required this.onConsented,
    this.onDismissed,
    required this.requesterName,
    required this.schemaVersion,
  });

  @override
  State<ConsentReviewSheet> createState() => _ConsentReviewSheetState();
}

class _ConsentReviewSheetState extends State<ConsentReviewSheet> {
  late final Map<String, bool> _toggles;
  late final Set<String> _newFieldIds;

  @override
  void initState() {
    super.initState();

    // Initialise toggles: required fields are always on, optional default on.
    _toggles = {
      for (final field in widget.fields) field.id: true,
    };

    // Collect IDs of newly added fields for visual highlighting.
    _newFieldIds = {
      if (widget.diff != null)
        for (final field in widget.diff!.added) field.id,
    };
  }

  void _onConfirm() {
    final statuses = <String, ConsentFieldStatus>{};
    for (final field in widget.fields) {
      statuses[field.id] = _toggles[field.id] == true
          ? ConsentFieldStatus.accepted
          : ConsentFieldStatus.withdrawn;
    }

    widget.onConsented(
      ConsentState(
        fieldStatuses: statuses,
        consentedAt: DateTime.now(),
        schemaVersion: widget.schemaVersion,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Header ---
          _buildHeader(theme, colorScheme),

          // --- Field list ---
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: widget.fields.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
              itemBuilder: (context, index) {
                final field = widget.fields[index];
                return _buildFieldTile(field, theme, colorScheme);
              },
            ),
          ),

          // --- Confirm button ---
          _buildConfirmButton(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data Access Request',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.requesterName} is requesting access to the '
                  'following data.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              semanticLabel: 'Dismiss consent review',
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: widget.onDismissed,
          ),
        ],
      ),
    );
  }

  Widget _buildFieldTile(
    ConsentField field,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isNew = _newFieldIds.contains(field.id);
    final isToggled = _toggles[field.id] ?? true;

    return Semantics(
      toggled: isToggled,
      label: '${field.label}: ${field.description}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Field info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          field.label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isNew) ...[
                        const SizedBox(width: 8),
                        _buildNewBadge(colorScheme),
                      ],
                      if (field.isRequired) ...[
                        const SizedBox(width: 8),
                        _buildRequiredBadge(colorScheme),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    field.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Toggle
            Switch(
              value: isToggled,
              onChanged: field.isRequired
                  ? null // locked — cannot be turned off
                  : (value) {
                      setState(() {
                        _toggles[field.id] = value;
                      });
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewBadge(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'NEW',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: colorScheme.onTertiaryContainer,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildRequiredBadge(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'REQUIRED',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildConfirmButton(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: _onConfirm,
          child: const Text('Confirm'),
        ),
      ),
    );
  }
}
