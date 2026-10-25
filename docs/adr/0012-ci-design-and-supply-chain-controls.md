# ADR 0012: CI design and supply-chain controls

- Status: Accepted
- Date: 2026-10-25

## Context

The pipelines are part of the product's hardening: they build the release
artifacts and hold the signing secrets.

## Decision

- Every third-party action is pinned to a full commit SHA with a version
  comment; Dependabot keeps them current, with a cooldown (7 days, 14 for
  majors) so fresh releases are not adopted blindly.
- Top-level `permissions: contents: read`; jobs elevate individually.
  `concurrency` with `cancel-in-progress` on pull requests, `timeout-minutes` on
  every job, `persist-credentials: false` on checkout (the only exception is
  `update-goldens`, which must push). No `pull_request_target`. Runner images are
  pinned by label, never `-latest`.
- One aggregate required check, `CI Gate`, so path-filtered jobs never block a
  merge.
- Security: CodeQL (language `actions`), OSV-Scanner on `pubspec.lock`, gitleaks,
  and dependency review (fail on moderate or higher, deny GPL and AGPL).
- gitleaks runs as a pinned CLI release verified by sha256, because
  `gitleaks-action` requires a license key for repositories owned by an
  organization.
- The release job runs in the protected `release` environment (manual approval),
  which alone holds the signing secrets, and produces build provenance
  attestations.
- Every workflow installs Flutter through the `setup-flutter` composite action.

## Consequences

The pinned gitleaks version and checksum are bumped by hand (Dependabot does not
track them). Pushes made with `GITHUB_TOKEN` (for example from `update-goldens`)
do not trigger CI.

## Alternatives considered

Tag-pinned actions and `-latest` runners: rejected for reproducibility.
