# Releasing

## Versioning

- Semantic Versioning. The line stays at 0.y.z until milestone M6 is complete,
  then 1.0.0.
- The git tag `vX.Y.Z`, created by release-please, is the source of truth.
  `pubspec.yaml` carries `version: X.Y.Z # x-release-please-version` with no
  build number (see ADR 0011).
- The build number is injected by CI (`--build-number` set to the release
  workflow run number, which is monotonic).
- While below 1.0.0: breaking changes bump minor and features bump patch.
- Changelog sections: Features, Bug Fixes, Performance, Refactoring,
  Documentation. `test`, `ci`, `chore` and `build` are hidden. `CHANGELOG.md` is
  generated and never edited by hand.

### Cutting 1.0.0

The first release is 1.0.0, not what the commits would compute (below 1.0.0, a
feature bumps the patch, so it would be 0.1.1). `release-please-config.json`
therefore pins `"release-as": "1.0.0"`.

- Merge no release pull request until the release checklist below passes. The
  pull request release-please keeps open is only a proposal until then.
- Once the `v1.0.0` release is published, remove `release-as` in a pull request
  titled `chore(release): drop the release-as pin`. Left in place, it would pin
  every later release to 1.0.0 again.

## Pipeline (`release.yml`)

1. On every push to `main`, release-please opens or updates one PR titled
   `chore(main): release x.y.z` with the changelog, the version bump and the
   manifest. It uses `RELEASE_PLEASE_TOKEN` so CI runs on that PR.
2. Merging it creates the tag and the GitHub Release.
3. `build-release` runs only when a release was created, in the protected
   `release` environment (manual approval). It:
   - writes `android/key.properties` from the environment secrets (never
     committed) and fails when a secret is missing;
   - builds split-per-ABI APKs and an AAB with `--release --obfuscate
--split-debug-info=build/symbols` and the version and build number;
   - runs `tool/check_release_manifest.dart` and the 25 MiB size budget check on
     the arm64 APK;
   - produces `SHA256SUMS`, archives `symbols.zip`, and creates build
     provenance attestations;
   - attaches APKs, AAB, symbols and checksums to the GitHub Release.
4. iOS is compiled with `--no-codesign` in CI as a verification only.
5. The integration workflow runs on `release: published` against the release
   commit; a failure blocks announcing the release.

Artifact names: `solenn-X.Y.Z-android-<abi>.apk`, `solenn-X.Y.Z-android.aab`,
`solenn-X.Y.Z-symbols.zip`, `SHA256SUMS`.

## Dry run

The release build can be checked on a development machine before the real one.
Without `android/key.properties` it falls back to debug signing with a warning,
which is enough to check what the pipeline checks:

```bash
fvm flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/symbols
fvm dart run tool/check_release_manifest.dart
fvm dart run tool/check_apk_size.dart build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

## Secrets

| Secret                                                                                              | Used by       | Notes                                                                                                                                                  |
| --------------------------------------------------------------------------------------------------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `RELEASE_PLEASE_TOKEN`                                                                              | `release.yml` | Fine-grained token or GitHub App token with contents and pull-requests write. A token other than `GITHUB_TOKEN` is required so release PRs trigger CI. |
| `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` | Release build | Stored in the GitHub Environment `release`, which requires manual approval.                                                                            |

No other secret exists. iOS signing secrets are intentionally absent in 1.0.
`android/key.properties.example` is the committed template.

### Creating the signing key

The keystore is created once, kept outside the repository (`*.jks` is
ignored), and backed up: losing it means future releases cannot update an
installed build.

```bash
keytool -genkeypair -v -keystore solenn-release.jks -alias solenn \
  -keyalg RSA -keysize 2048 -validity 10000
base64 -w0 solenn-release.jks    # on macOS: base64 -i solenn-release.jks
```

The base64 text is the value of `ANDROID_KEYSTORE_BASE64`; the other three
secrets are the keystore password, the alias (`solenn`) and the key password.

## Release checklist

- [ ] `CI Gate` and integration green on the release commit.
- [ ] Dry run passed: manifest check and size budget (see above).
- [ ] Profile-mode run on a mid-range Android device and an iPhone: no jank on
      keypad, paywall transition and sheets.
- [ ] VoiceOver and TalkBack script completed ([testing](testing.md)).
- [ ] Device matrix covered ([testing](testing.md)).
- [ ] Release manifest and `Info.plist` checked for permissions (none).
- [ ] Version and build shown in Account match the tag.
- [ ] APK installed on a clean device and the full flow exercised: calculate,
      paywall, each exit path.
- [ ] Changelog and release notes read by a human.
- [ ] No placeholder artwork shipping by accident (open tracking issue closed).
- [ ] The screenshots of the README and of `docs/design/screens/` match the
      release.

After the release:

- [ ] `release-as` removed from `release-please-config.json`.
- [ ] Artifacts downloaded, `sha256sum --check SHA256SUMS` passes, and the
      attestation of one APK verifies.

## iOS distributable builds

Distributable IPAs are produced manually with Xcode and the owner's own team:
open the iOS workspace, select your team under Signing & Capabilities, then
Product > Archive and Distribute from the Organizer. Use the version and build
number of the release.

When signing secrets exist, a CI job can replace this. The outline below is an
**unvalidated template**: it has not been run, and the secret names and export
options file are placeholders you must define.

```yaml
# build-ios-release:
#   runs-on: macos-15
#   environment: release
#   steps:
#     - checkout the release tag
#     - uses: ./.github/actions/setup-flutter
#     - import the distribution certificate into a temporary keychain
#     - install the provisioning profile
#     - flutter build ipa --release --obfuscate --split-debug-info=build/symbols
#         --build-name=<version> --build-number=<run number>
#         --export-options-plist=<your ExportOptions.plist>
#     - attach the IPA to the GitHub Release; remove the keychain (if: always())
```

## Native configuration to verify

Android:

- Main manifest: no `INTERNET` and no other permission; `allowBackup=false` with
  data extraction rules excluding everything; `enableOnBackInvokedCallback=true`;
  `screenOrientation=portrait` on `MainActivity`; only `MainActivity` exported;
  label Solenn.
- `tool/check_release_manifest.dart` inspects the merged release manifest and
  fails on any `uses-permission` outside a short allowlist.
- Release build type: minification and resource shrinking on, Flutter's default
  ProGuard rules, signing from `android/key.properties`. A local release build
  without it falls back to debug signing with a warning.
- Edge-to-edge enabled in `MainActivity`; insets handled in Flutter through
  `MediaQuery`. Debug build type uses `applicationIdSuffix .debug`.

iOS:

- Deployment target 15.0 (and in the Podfile platform line when one exists);
  `TARGETED_DEVICE_FAMILY = 1`.
- `Info.plist`: portrait only, `UIUserInterfaceStyle = Dark`, light status bar
  content, `ITSAppUsesNonExemptEncryption = false`, `CFBundleDisplayName =
Solenn`, version and build from Flutter variables, no usage-description keys,
  no App Transport Security exceptions.
- `PrivacyInfo.xcprivacy` declaring no tracking and no collected data, plus the
  required-reason API entries needed by the Flutter engine and plugins.
- Black launch storyboard with the mark; app icon set with default, dark and
  tinted variants.

## Support policy

Only the latest release is supported. A hotfix is a normal PR to `main` followed
by a patch release; there are no backport branches.
