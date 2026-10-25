# ADR 0005: No persistence and no network

- Status: Accepted
- Date: 2026-10-25

## Context

Solenn is satire presented as a believable product. It must never process real
payments or collect personal data (constraint C1), never use the network (C2),
and never keep anything across launches (C3).

## Decision

- Release builds MUST NOT declare the `INTERNET` permission. CI verifies the
  merged release manifest (`tool/check_release_manifest.dart`).
- No analytics, crash reporting, ads, remote config or runtime font download.
- Nothing survives a cold start: no `shared_preferences`, files, databases or
  keychain. A launch is the process lifetime: backgrounding does not end it,
  process death does.
- Checkout is a confirmation sheet with no text fields. The privacy text states
  that Solenn collects and transmits nothing.
- Release debuggability comes from `--split-debug-info` symbols archived with
  each release.

## Consequences

No data layer exists. History and the `Active` subscription state live in
memory only and reset on process death. Reproducing a user-reported crash relies
on the report and the archived symbols, not on remote telemetry.

## Alternatives considered

Local persistence and remote crash reporting: rejected by C3 and C2.
