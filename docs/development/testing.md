# Testing

## Pyramid

| Level | Scope | Tooling | Gate |
| --- | --- | --- | --- |
| Unit | Domain: reducer, parser, evaluator, sabotage, formatter, pricing, legal parser | `flutter_test` | Domain coverage at least 95% |
| Cubit | Every transition of the subscription state machine and every calculator key path | `bloc_test`, `fakeAsync`, `mocktail` | Part of overall coverage |
| Widget | Each View with mocked Cubits, under iOS and Android, text scale 1.0, 1.3 and 2.0, accessibility guidelines | `flutter_test` | Overall coverage at least 85% |
| Golden | Key states of each screen and component at widths 320, 390 and 430 | `matchesGoldenFile`, tag `golden` | Run on Linux CI only |
| Architecture and hygiene | Layer rules, localization and repository hygiene | `flutter_test` over the source tree | Zero violations |
| Integration | Full flows on real emulator and simulator | `integration_test` | Nightly, main, releases |
| Manual | Release checklist, VoiceOver and TalkBack script, device matrix | Humans | Before each release |

## Conventions

- One group per unit under test; test names read `should <outcome> when
  <condition>`; Arrange, Act, Assert.
- No real timers, sleeps, network or wall-clock dependence. Time is `fakeAsync`;
  randomness is seeded.
- Fixtures in `test/fixtures`, shared fakes and builders in `test/helpers`. Test
  files mirror `lib/` paths.
- Every bug fix ships with a regression test.
- Flaky tests are quarantined within 24 hours with a tracking issue. Automatic
  retries are not used to hide flakiness.

## Coverage

`tool/check_coverage.dart` reads `coverage/lcov.info`, excludes generated
localization and `main.dart`, and enforces overall at least 85% lines and
`**/domain/**` at least 95%. The thresholds are constants at the top of the
script and may only be raised (a decrease needs an ADR).

## Golden policy

- Goldens load the real fonts through a test helper (`loadAppFonts`) and are
  generated and compared on a single pinned Linux image only.
- Locally, run `flutter test --exclude-tags golden`. To update baselines,
  dispatch the **Update goldens** workflow on your branch; it commits the new
  images and refuses `main`.
- A golden diff in a PR requires a reviewer to look at the images.

## Integration flows

Seeded randomness and shortened timings are injected through `AppDependencies`.
Required flows:

1. First calculation, result visible, paywall appears, Annual, Confirm, Plus
   active.
2. Paywall closed with the close button.
3. Paywall dismissed with system back.
4. Restore from Account before any calculation.
5. History shows the displayed result, not the truth.
6. A second calculation never reopens the paywall.

The integration workflow skips its jobs while `integration_test/` contains no
`*_test.dart` file.

## Accessibility

Baseline: WCAG 2.2 AA, plus both platforms' tap-target guidance.

Automated: every screen's widget test asserts `meetsGuideline` for Android tap
target, iOS tap target, labeled tap target and text contrast.

## Manual screen-reader script

Run on one iPhone with VoiceOver and one Android device with TalkBack before
each release. This script is derived from the accessibility requirements of the
specification; adjust the wording after the first run.

1. **Keys.** Swipe through the keypad. Each key has a spoken label (for example
   Divide, Multiply, Delete, All clear) and digits read as digits. Focus order
   follows visual order.
2. **Result.** Enter `12 + 12 =`. The result is announced as a live region (for
   example "Result 24,820"). Focus the expression: it is readable.
3. **Copy.** Long-press the display; the copy confirmation is announced.
4. **Paywall.** Wait for the paywall. Focus lands on it; the close button is
   labeled and reachable immediately. Plan cards read as one mutually exclusive
   group with the selected state announced. The CTA text follows the selection.
5. **Checkout.** Open it from a plan; plan, trial, price and Due today are read.
   Cancel and Confirm are labeled.
6. **Exits.** Close with the close button, then repeat with system back
   (TalkBack back gesture, VoiceOver escape gesture). Each returns to the
   calculator.
7. **Header.** After Active, the PLUS badge and the welcome banner are announced
   and the history and account buttons are labeled.
8. **Settings.** With system font size at maximum, nothing clips outside the
   display and keypad. With reduce motion on, slides become fades.
9. **No color-only meaning.** The selected operator and selected plan are
   distinguishable without color.

## Device matrix

- One iPhone with Dynamic Type at the largest accessibility size.
- One Android with gesture navigation and one with 3-button navigation.
- One Android with maximum font scale.

### Running the integration flows

`integration_test/app_flows_test.dart` holds the six required flows, one group
per flow, in the order above. `integration_test/helpers/flow_driver.dart` holds
the shared driver: it starts `SolennApp` with `buildTestDependencies`, seeded
randomness and shortened timings (300 ms before the paywall, 300 ms of
processing), so a run lasts seconds instead of minutes.

```bash
fvm flutter devices
fvm flutter test integration_test -d <device-id>
```

Real time passes in these tests, unlike in the widget tests that use
`fakeAsync`: each wait leaves a margin after the delay it waits for. A widget
that scrolls out of reach (the paywall on a small screen) is brought into view
before it is tapped.

The `Integration` workflow runs them on an Android emulator and on an iOS
simulator; it needs no change, since it runs every `*_test.dart` file of
`integration_test/`.

### What is captured

Each golden test file starts with `@Tags(['golden'])` and loads the real fonts
with `loadAppFonts` (`test/helpers/load_app_fonts.dart`) in `setUpAll`. The
helper is not installed globally: other tests keep the default test font, whose
metrics their layout assertions rely on. Images are stored next to the test, in
a `goldens/` folder, at a device pixel ratio of 1.

| Subject | Captured |
|---|---|
| Calculator | Empty, typing, result, selected operator, unlocked (PLUS and banner), error, at 320, 390 and 430 |
| Paywall | Annual at the three widths; monthly and enterprise at 390 |
| Checkout sheet | Annual at the three widths on Android; annual on iOS; monthly at 390 |
| History sheet | Populated at the three widths on Android and at 390 on iOS; empty at 390 on both |
| Account | Free at the three widths; Plus at 390 on both platforms |
| Legal page | At the three widths |
| Components | Keys, plan cards, surfaces (chip, banner, list, buttons), pressed keys on iOS |
| Error fallback | At 390 |

Sheets are captured on both platforms because they differ (Cupertino popup with
a grabber, Material bottom sheet with a drag handle). Press feedback is
captured on iOS only: the Android ripple depends on time.

### Creating or updating baselines

Baselines are valid only when generated on the CI image, so a Windows or macOS
machine cannot produce them.

1. Push the branch: the `Tests` job fails on the missing images. This is
   expected the first time.
2. Run the **Update goldens** workflow on the branch. It commits the images.
3. Pull the branch and review the images in the PR: a golden diff needs a
   reviewer to look at them.
4. Push an empty commit (`git commit --allow-empty -m "ci: rerun checks"`),
   since a push made with `GITHUB_TOKEN` does not start CI.
