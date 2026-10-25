# ADR 0006: Exact decimal arithmetic

- Status: Accepted
- Date: 2026-10-25

## Context

The calculator lies on purpose. Floating-point artifacts (for example
`0.1 + 0.2` giving `0.30000000000000004`) would be mistaken for intentional
lies, and they would make the "truth" the sabotage engine starts from wrong.

## Decision

Domain math uses the `decimal` package (exact base-10 arithmetic); `double` is
not used in domain math. Internal precision is 15 significant digits; division
rounds half-up; negative zero is normalized to `0`. Money is stored as
`Money(amountMinor: int, currencyCode: String)`, with no `double` anywhere near
money.

## Consequences

`0.1 + 0.2` is exactly `0.3` before the lie. The evaluator is verified against
`test/fixtures/evaluator_cases.csv` (at least 200 cases). The domain may import
`decimal` (AR-1).

## Alternatives considered

`double`: rejected, it produces accidental errors indistinguishable from
intentional ones.
