# Changelog

All notable changes to `consent_layer` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] — 2026-10-13

### Changed

- README: clarified that this package is a reference implementation and that Flair's app does not currently depend on it. Documentation only; no code changes.

## [1.0.0] — 2026-07-06

### Added

- `ConsentField` — immutable data class representing a single consent-able data field.
- `ConsentFieldRegistry` — abstract base class for app-defined field registries.
- `ConsentSchemaDetector` and `ConsentSchemaDiff` — stateless schema comparison producing added/removed field diffs.
- `ConsentState` and `ConsentFieldStatus` — immutable consent session result with JSON serialisation.
- `ConsentReviewSheet` — Flutter widget for per-field consent review with diff highlighting and required-field locking.
- Example app ("Wellbeing Tracker") demonstrating initial consent and schema-change flows.
- `CONSENT_PROTOCOL.md` — documentation of the `[withdrawn]` tombstone contract.
