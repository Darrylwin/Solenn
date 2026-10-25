# ADR 0010: Platform adaptation policy

- Status: Accepted
- Date: 2026-10-25

## Context

iOS and Android users must both feel at home (constraint C5), while the brand
stays identical. The principal risk is an iOS-styled design that feels foreign on
Android.

## Decision

One brand and two interaction dialects. The brand (tokens, type, geometry) never
adapts; behavior and containers do, following the policy table in
`docs/design/platform-adaptation.md`. Adaptive components live in
`core/platform` and decide with `Theme.of(context).platform`, never
`Platform.isIOS`, so tests and previews can override the platform. Haptics sit
behind an injected `HapticsService` and fire on pointer down for keys.

## Consequences

Widget tests for sheets, dialogs, transitions and press feedback run under both
`TargetPlatform.iOS` and `TargetPlatform.android`, and goldens exist per
platform wherever visuals differ. Releases require manual checks on both
platforms.

## Alternatives considered

Forcing one platform's behavior everywhere: rejected by constraint C5.
