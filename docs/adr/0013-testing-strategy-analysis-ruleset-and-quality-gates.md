# ADR 0013: Testing strategy, analysis ruleset and quality gates

- Status: Accepted
- Date: 2026-10-25

## Context

The codebase is meant to be maintained for years; quality gates must be
automatic and the same locally and in CI.

## Decision

- Testing pyramid: unit (domain), Cubit, widget, golden, architecture and
  hygiene, integration, and manual. Coverage gate: overall at least 85% lines,
  `**/domain/**` at least 95%, enforced by `tool/check_coverage.dart`.
  Thresholds may only be raised; a decrease needs an ADR.
- Goldens are generated and compared on one pinned Linux image and tagged
  `golden` (declared in `dart_test.yaml`). Baselines are updated through the
  `update-goldens` workflow.
- Static analysis uses `very_good_analysis` with `strict-casts`,
  `strict-inference` and `strict-raw-types`; `flutter analyze --fatal-infos` is
  the CI standard. `public_member_api_docs` is re-enabled inside every `domain/`
  directory and inside `lib/core/`.
- Tests use `bloc_test` and `mocktail`. No real timers, sleeps or network: time
  is `fakeAsync`, randomness is seeded.

## Consequences

Contributors on Windows or macOS run `flutter test --exclude-tags golden`
locally. A token or golden change needs a reviewer to look at the result.

## Alternatives considered

- `flutter_lints`: rejected as too permissive.
- `mockito`: rejected, it requires code generation.
