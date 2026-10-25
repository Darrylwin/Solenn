# ADR 0011: Trunk-based development, Conventional Commits, release-please and FVM

- Status: Accepted
- Date: 2026-10-25

## Context

`main` must always be releasable, history must be readable, releases must be
reproducible, and development happens on Windows while CI runs on Linux.

## Decision

- Trunk-based: short-lived branches, no long-lived or release branches. Squash
  merges only; the PR title is the commit message. Conventional Commits 1.0.
- Releases are cut by release-please in manifest mode (one package at the
  repository root, release type `simple`, tags `vX.Y.Z`). The git tag is the
  source of truth for the version. Below 1.0.0, breaking changes bump minor and
  features bump patch.
- `pubspec.yaml` carries `version: X.Y.Z # x-release-please-version`, **without
  a build number**. The release-please `generic` updater replaces whatever its
  semver pattern matches on that line, including `+build` metadata, so a `+1`
  would be dropped on the first release PR. CI injects the build number with
  `--build-number` (the release workflow run number). This supersedes the
  `0.1.0+1` form in the specification.
- The Flutter version is pinned with FVM in `.fvmrc` (stable channel only). FVM
  accepts the version under `flutterSdkVersion` or `flutter`; the `setup-flutter`
  action reads `flutterSdkVersion` first, then `flutter`, and fails when neither
  is a valid `x.y.z`.
- A Flutter upgrade is a dedicated PR titled `build(flutter): bump to x.y.z` that
  re-validates Android Gradle Plugin, Gradle, Kotlin and Xcode compatibility.

## Consequences

The changelog is generated and never edited by hand. Local builds carry no
explicit build number. Dependabot ignores majors of AGP, Kotlin and Gradle,
which move only with a Flutter upgrade.

## Alternatives considered

Release branches and long-lived branches: rejected, hotfixes are normal PRs
followed by a patch release.
