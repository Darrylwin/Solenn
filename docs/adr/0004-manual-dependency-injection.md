# ADR 0004: Manual dependency injection through a composition root

- Status: Accepted
- Date: 2026-10-25

## Context

Time, randomness, haptics and app info must be injectable so the domain and the
Cubits stay deterministic and testable (AR-6), and so there is no global state
(AR-7).

## Decision

`bootstrap()` builds an immutable `AppDependencies` object (randomness source
seeded per launch, `HapticsService`, `AppInfo`, `PricingCatalog`,
`SabotageEngine`). `SolennApp` receives it as a constructor argument and exposes
services with `RepositoryProvider.value`. Constructor injection everywhere. No
service locator.

## Consequences

Tests construct `SolennApp` with fakes and have no global state to reset. Adding
a service means adding a field to `AppDependencies` and passing it explicitly.

## Alternatives considered

Service locators (`get_it`, `injectable`): listed as not used and forbidden by
AR-7.
