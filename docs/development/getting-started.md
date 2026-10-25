# Getting started

See [CONTRIBUTING](../CONTRIBUTING.md) for branch, commit and PR rules.

## Setup

```bash
dart pub global activate fvm
fvm install
fvm flutter pub get --enforce-lockfile
lefthook install
```

Always use `fvm flutter` and `fvm dart`. The local hooks in `lefthook.yml` also
call FVM; if Flutter is on your PATH and you do not use FVM, drop the `fvm `
prefix there.

## Toolchain

- `.fvmrc` holds the exact stable Flutter version that ships Dart 3.11.5 or
  later. It is the single source of truth: developers use FVM, CI reads it with
  `jq` (the `setup-flutter` action), documentation links to it.
- FVM accepts the version under `flutterSdkVersion` or `flutter`. `setup-flutter`
  reads `flutterSdkVersion` first, then `flutter`, and requires an exact
  `x.y.z`.
- `pubspec.yaml` keeps `sdk: ^3.11.5` and a `flutter:` lower bound equal to the
  pinned version.
- Upgrading Flutter is a dedicated PR titled `build(flutter): bump to x.y.z`. It
  covers the stable channel only (never beta or main) and must re-validate
  Android Gradle Plugin, Gradle, Kotlin and Xcode compatibility.

## Platform targets

| Item             | iOS                                         | Android                                                 |
| ---------------- | ------------------------------------------- | ------------------------------------------------------- |
| Identifier       | `com.darcode.solenn`                        | `com.darcode.solenn`                                    |
| Minimum OS       | iOS 15.0 (deliberate floor)                 | `flutter.minSdkVersion` (never overridden)              |
| Target / compile | Current Xcode stable                        | `flutter.targetSdkVersion`, Flutter default compile SDK |
| Devices          | iPhone only (`TARGETED_DEVICE_FAMILY = 1`)  | Phones; larger windows get the centered column          |
| Orientation      | Portrait                                    | Portrait (manifest)                                     |
| Appearance       | Dark forced (`UIUserInterfaceStyle = Dark`) | Dark theme, edge-to-edge                                |
| Display name     | Solenn                                      | Solenn                                                  |
| Debug builds     | n/a                                         | `applicationIdSuffix .debug` (installs next to release) |

Orientation and appearance are enforced natively, not with `SystemChrome` calls,
so the first frame is already correct. The `web`, `windows`, `linux` and `macos`
platform folders MUST NOT be added.

## Day-to-day commands

| Task                  | Command                                                                    |
| --------------------- | -------------------------------------------------------------------------- |
| Run                   | `fvm flutter run`                                                          |
| Format check          | `fvm dart format --output=none --set-exit-if-changed .`                    |
| Analyze               | `fvm flutter analyze --fatal-infos`                                        |
| Tests without goldens | `fvm flutter test --exclude-tags golden`                                   |
| Coverage              | `fvm flutter test --coverage` then `fvm dart run tool/check_coverage.dart` |
| Localizations         | `fvm flutter gen-l10n` (generated files are committed)                     |

## Repository map

See the layout in the foundation specification: `lib/` (`app`, `core`,
`features`, `l10n`), `test/` (mirrors `lib/`, plus `architecture/`),
`integration_test/`, `tool/`, `docs/`, `.github/`.
