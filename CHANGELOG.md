# Changelog

All notable changes to `consent_layer` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] — 2026-09-28

### Fixed

- README and Provenance section corrected: this package is a reference implementation of the consent primitive, not yet the live enforcement layer in Flair's shipped app. The previous wording ("Flair uses this package in production", "the package's git log *is* the transparency log") implied production parity that has not existed since the July 2026 extraction — the app's shipped consent enforcement has diverged in its own private codebase. Re-convergence is planned but not yet complete. Docs-only change; no code changes.

## [1.0.0] — 2026-07-06

### Added

- `ConsentField` — immutable data class representing a single consent-able data field.
- `ConsentFieldRegistry` — abstract base class for app-defined field registries.
- `ConsentSchemaDetector` and `ConsentSchemaDiff` — stateless schema comparison producing added/removed field diffs.
- `ConsentState` and `ConsentFieldStatus` — immutable consent session result with JSON serialisation.
- `ConsentReviewSheet` — Flutter widget for per-field consent review with diff highlighting and required-field locking.
- Example app ("Wellbeing Tracker") demonstrating initial consent and schema-change flows.
- `CONSENT_PROTOCOL.md` — documentation of the `[withdrawn]` tombstone contract.
