# ADR 0002: Feature-first architecture with pure domain and no data layer

- Status: Accepted
- Date: 2026-10-25

## Context

The app has three features (calculator, subscription, account) and no I/O: no
network and no persistence (ADR 0005). The product is built as a real consumer
product maintained for years, so boundaries must be enforceable, not
conventional.

## Decision

- Feature-first. Each feature has two layers: pure-Dart `domain` and
  `presentation`. The shared kernel is `core`; `app` composes the features.
- No data layer. It is created only when a feature needs one, with its own ADR.
- No flavors, no code generation (except `gen_l10n`), no feature flags. Only
  one paywall variant ships in 1.0, and variant infrastructure is not built
  before a second variant exists.
- The layer rules AR-1 to AR-11 are enforced by tests in `test/architecture/`.

## Consequences

The domain is trivially unit-testable and can never import Flutter. Features
cannot depend on each other, so cross-feature wiring lives in `app/`. A feature
that later needs I/O must introduce a data layer through a new ADR.

## Alternatives considered

- A data layer from day one: rejected, since empty layers would be ceremony.
- Code generation (freezed, json_serializable, build_runner): rejected, it adds
  build_runner to every contributor and CI run for no gain here.
