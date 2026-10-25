# Troubleshooting

## `.fvmrc must pin an exact version, found 'null'`

The `setup-flutter` action could not find a version in `.fvmrc`. The file must
contain `{"flutterSdkVersion": "x.y.z"}` or `{"flutter": "x.y.z"}`, with an exact
three-part version (no channel, no `stable`). The action reads
`flutterSdkVersion` first, then `flutter`.

## Golden tests fail locally on Windows or macOS

Goldens are only valid on the pinned Linux image. Run
`flutter test --exclude-tags golden` locally and use the **Update goldens**
workflow to regenerate baselines.

## CI does not run after the Update goldens workflow

That workflow pushes with `GITHUB_TOKEN`, and pushes made with it do not trigger
workflows. Pull the branch and push an empty commit
(`git commit --allow-empty -m "ci: rerun checks"`).

## `CI Gate` is pending or some jobs are skipped

Path-filtered jobs are skipped when their area did not change. `ci-gate` accepts
skipped jobs and fails only when a dependency failed or was cancelled; it is the
only required build check.

## CI fails on a localization diff

CI regenerates the localizations and fails on any diff. Run
`fvm flutter gen-l10n` and commit the generated files.

## The commit-msg hook rejects my message

The hook prints the allowed types and scopes. Use
`type(scope): subject`, imperative, lower case, subject at most 72 characters,
no trailing period. The PR title must follow the same rule, since it becomes the
squash commit.

## Hooks fail with `fvm: command not found`

`lefthook.yml` calls FVM. Install FVM, or drop the `fvm ` prefix in
`lefthook.yml` if Flutter is on your PATH.

## Line-ending noise in diffs on Windows

`.gitattributes` normalizes to LF. If files were committed with CRLF before it
was added, run `git add --renormalize .` and commit the result.

## The release job fails on signing

The release job fails when a signing secret is missing. Check that the four
`ANDROID_*` secrets exist in the `release` environment, and that the
`key.properties` keys written by the workflow match `android/key.properties.example`
and `android/app/build.gradle.kts`. A local release build without
`key.properties` falls back to debug signing with a warning.

## A Flutter upgrade breaks the Android build

Treat it as its own PR (`build(flutter): bump to x.y.z`) and re-validate Android
Gradle Plugin, Gradle, Kotlin and Xcode. Dependabot ignores majors of those
because they move only with a Flutter upgrade.

## The arm64 APK exceeds the size budget

The release workflow fails above 25 MiB. Inspect new dependencies and bundled
assets first; a new dependency must justify its release-size impact.
