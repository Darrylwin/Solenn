# Contributing to Solenn

Solenn is a joke on the surface and a serious codebase underneath. The
authoritative description of how it is built is the
[foundation specification](README.md) and the [ADRs](adr/). Read the sections
relevant to your change before opening a pull request.

By participating you agree to the [Code of Conduct](CODE_OF_CONDUCT.md).
Security issues follow the [security policy](SECURITY.md), not public issues.

## Environment

Prerequisites: Git, [FVM](https://fvm.app) and [lefthook](https://lefthook.dev).
The Flutter version is pinned in `.fvmrc` (stable channel only).

```bash
dart pub global activate fvm
fvm install
fvm flutter pub get --enforce-lockfile
lefthook install
```

Always use `fvm flutter` / `fvm dart` so you run the pinned SDK.

The repository is developed on Windows and built on Linux: line endings are
normalized to LF by `.gitattributes`. Do not override this locally.

## Branches, commits and pull requests

- Trunk-based: `main` is always releasable. Branches are short-lived (aim for
  under 3 days) and named `type/scope-short-description`.
- Commits follow [Conventional Commits 1.0](https://www.conventionalcommits.org).
  - Types: `feat`, `fix`, `perf`, `refactor`, `docs`, `test`, `build`, `ci`,
    `chore`, `revert`.
  - Scopes (optional): `calculator`, `subscription`, `account`, `core`,
    `design-system`, `platform`, `app`, `l10n`, `android`, `ios`, `deps`,
    `release`, `docs`, `ci`.
  - Subject: imperative, lower case, at most 72 characters, no trailing period.
  - Breaking changes use `!` and a `BREAKING CHANGE:` footer.
- Merges are squash merges, so **the PR title is the commit message** and is
  checked by the PR Title workflow. The local `commit-msg` hook checks
  individual commits.
- One logical change per PR, ideally under 400 changed lines excluding
  generated files and goldens. Self-review before requesting review.
- Every bug fix ships with a regression test.

## Definition of done

- Behavior covered by tests at the right level; coverage gates pass.
- `flutter analyze --fatal-infos`, the format check and the architecture and
  hygiene tests pass.
- Works on iOS and Android (or a stated reason why not); accessibility
  guidelines pass for any UI change.
- Strings in ARB files, design tokens used, no literals.
- Docs updated, and an ADR written when required.
- No new dependency without the justification below.

## Commands

| Task | Command |
| --- | --- |
| Format check | `fvm dart format --output=none --set-exit-if-changed .` |
| Analyze | `fvm flutter analyze --fatal-infos` |
| Tests (local, no goldens) | `fvm flutter test --exclude-tags golden` |
| Tests with coverage | `fvm flutter test --coverage` |
| Coverage gate | `fvm dart run tool/check_coverage.dart` |
| Regenerate localizations | `fvm flutter gen-l10n` |
| Release manifest check | `fvm dart run tool/check_release_manifest.dart` |

CI regenerates localizations and fails on any diff: commit the generated files.

## Golden tests

Goldens are generated and compared on a single pinned Linux image only.
Contributors on Windows or macOS run `flutter test --exclude-tags golden`
locally. To update baselines, dispatch the **Update goldens** workflow on your
branch: it regenerates the images and commits them to that branch (it refuses
`main`). That commit is pushed with `GITHUB_TOKEN`, which does not trigger CI;
push an empty commit afterwards (`git commit --allow-empty`) to run the checks.
A golden diff in a PR needs a reviewer to look at the images.

## Adding a dependency

Justify it in the PR with:

1. its purpose;
2. why the SDK or existing code cannot do it;
3. a release within the last 12 months;
4. a permissive license;
5. any native code involved, and why it is acceptable;
6. its impact on release size.

Use caret ranges. `pubspec.lock` is committed and CI runs
`flutter pub get --enforce-lockfile`. A dependency of architectural weight also
needs an ADR. The following are explicitly not used: freezed, json_serializable,
build_runner, get_it, injectable, go_router, provider, riverpod, google_fonts,
shared_preferences, flutter_screenutil, and any analytics, crash-reporting,
payment or in-app-purchase SDK.

## Writing an ADR

ADRs live in `docs/adr/` as `NNNN-title.md`, from
[`0000-template.md`](adr/0000-template.md). An accepted ADR is immutable: change
it only with a new ADR that supersedes it. An ADR is required for:

- a dependency of architectural weight;
- any change to a layer rule or the platform policy;
- any change to CI or release strategy;
- any decrease of a coverage threshold.

When the specification and an accepted ADR disagree, the ADR wins and the
specification is corrected in the same PR.
