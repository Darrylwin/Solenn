# ADR 0007: Navigator 1.0 with typed routes

- Status: Accepted
- Date: 2026-10-25

## Context

The app has a small, fixed set of screens: Home (`/`), `/paywall`, `/checkout`,
`/history`, `/account`, `/account/legal` and the licenses page. Web is a
non-goal, so no screen needs to be addressable by URL.

## Decision

Navigator 1.0 with `onGenerateRoute` and a typed `AppRoute` layer that owns
route names and arguments. Raw route strings never appear in widgets. A
`PaywallPresenter` in `app/` listens to `SubscriptionCubit` through the root
navigator key and drives navigation. System back on the paywall is a dismissal,
implemented with `PopScope` and routed through the Cubit.

## Consequences

Navigation intent stays out of Cubits (AR-10). The presenter is tested with a
fake `NavigatorObserver`.

## Alternatives considered

`go_router`: listed as not used. The specification fixes this decision without
a longer rationale.
