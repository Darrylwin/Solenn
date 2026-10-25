# ADR 0003: Cubit-based state management

- Status: Accepted
- Date: 2026-10-25

## Context

The paywall flow is an explicit state machine with timers, and the calculator
applies key presses through a pure reducer. Both need transitions that are easy
to test.

## Decision

Use `flutter_bloc` with Cubits only. Events and Blocs are introduced only if a
stream-transform need appears. Two Cubits exist: `CalculatorCubit` and
`SubscriptionCubit`. They do not know each other; a listener in `app/` calls
`SubscriptionCubit.calculationCommitted()` when `committedCount` increases.
Cubits hold no `BuildContext` and never navigate.

## Consequences

Transitions are verified with `bloc_test`. High-frequency state must be consumed
with `BlocSelector` or `buildWhen` so the keypad does not rebuild with the
display. No event bus is needed.

## Alternatives considered

Riverpod: a stronger fit for async or graph-shaped state than this app needs.
Mixing both is forbidden.
