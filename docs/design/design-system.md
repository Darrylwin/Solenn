# Design system

Dark, precise, tactile. One accent color used with restraint. Every visual value
comes from a token; no hex literal, font size or duration appears outside
`core/design_system`. The reference is the delivered mock (acid-yellow operators
on near-black circles). A PR that changes a token updates this file in the same
PR.

## Color tokens

| Token | Hex | Usage |
| --- | --- | --- |
| `background` | `#000000` | Screen background |
| `surface` | `#141414` | Display card, icon buttons, plan cards, banner |
| `surfaceElevated` | `#161616` | Sheets and popovers |
| `outline` | `#2A2A2A` | Hairlines, unselected borders, dividers |
| `keyDigitTop` / `keyDigitBottom` | `#262626` / `#0C0C0C` | Digit key gradient, 160 degrees |
| `keyFunction` | `#5B5B5B` | AC, backspace, % |
| `accent` | `#E4FF4F` | Operators, CTA, selection, highlights |
| `onAccent` | `#0A0A0A` | Content on accent |
| `accentMuted` | `#2F3318` | Accent-tinted borders (welcome banner) |
| `textPrimary` | `#F5F5F5` | Primary text |
| `textSecondary` | `#9A9A9A` | Secondary text, captions, expression line |
| `iconMuted` | `#6B6B6B` | Non-text icons only (paywall close) |
| `scrim` | black at 55% | Behind sheets |
| `error` | `#FF6B6B` | Satisfies the Material `ColorScheme` slot; not used in the UI |

### Contrast requirements

A unit test computes the ratios from the tokens; a token change that breaks one
fails CI.

| Pair | Minimum | Computed from the tokens above |
| --- | --- | --- |
| `textPrimary` on `background` | 15:1 | 19.26 |
| `textSecondary` on `background` | 7:1 | 7.46 |
| `textSecondary` on `surface` | 6:1 | 6.55 |
| `textPrimary` on `keyFunction` | 6:1 | 6.23 |
| `onAccent` on `accent` | 15:1 | 17.64 |
| `iconMuted` on `background` (non-text) | 3:1 | 3.94 |

### Material 3 mapping

`ColorScheme.dark`: primary = `accent`, onPrimary = `onAccent`, surface =
`surface`, onSurface = `textPrimary`, surfaceContainerHigh = `surfaceElevated`,
outline = `outline`, scrim = `scrim`. Framework widgets (dialogs, sheets, the
licenses page) inherit the brand without per-widget overrides.

## Typography (Manrope)

| Role | Size | Weight | Tracking / line height |
| --- | --- | --- | --- |
| `displayResult` | 64 (fits down to 32) | 300 | -2 |
| `displayExpression` | 24 | 300 | - |
| `keyDigit` | 32 | 300 | - |
| `keyFunction` | 24 | 400 | - |
| `keyOperator` | 34 | 400 | - |
| `heroTitle` | 46 | 300 | -1.5 / 1.04 |
| `titleLarge` | 19 | 600 | - |
| `titleMedium` | 16 | 600 | - |
| `body` | 15 | 400 | 1.45 |
| `bodySmall` | 12.5 | 400 | - |
| `label` | 12 | 500 | - |
| `caps` | 10.5 | 700 | +0.6 |
| `price` | 18 | 600 | - |
| `cta` | 17 | 700 | - |

- Numerals in the display, prices and the countdown use tabular figures
  (`FontFeature.tabularFigures()`).
- Text scaling: display and keypad clamp at 1.3 (their geometry is fixed by the
  circles); all other text scales to at least 2.0 and its container reflows or
  scrolls. Nothing clips.

## Space, shape and size

- 4-point grid: 4, 8, 12, 16, 20, 24, 32, 40. Screen margin 24. Key gap 12.
- Key diameter is derived: (available width - 3 x 12) / 4, with a floor of 56 at
  320 dp width. Maximum content width 430, centered.
- Radii: display card 28, sheet top corners 32, plan card 24, banner 20, chip
  12, keys and icon buttons fully circular, primary button pill (height 60).
- Minimum touch target 44 x 44 everywhere.

## Motion

| Token | Value | Use |
| --- | --- | --- |
| `press` | 80 ms | Key press feedback |
| `fast` | 160 ms | Plan selection, state changes |
| `base` | 240 ms | Banner in, general transitions |
| `slow` | 360 ms | Paywall enter (slide up) |

Standard curve `easeOutCubic`; emphasized curve `Cubic(0.2, 0, 0, 1)`. Result
reveal is a 200 ms crossfade with an 8 px rise. When
`MediaQuery.disableAnimations` is true, slides become fades of at most 120 ms
and decorative motion is removed. Animation never delays input.

## Components

`SolennKey` (digit, function, operator; default, pressed, selected, disabled),
`SolennIconButton`, `SolennPrimaryButton` (pill, loading state),
`SolennTextButton`, `PlanCard`, `SolennChip`, `SolennBanner`,
`SolennSheetScaffold`, `SolennListTile`. Each has doc comments and golden tests
across states and platforms.

## Theme implementation

`SolennColors`, `SolennTypography`, `SolennSpacing`, `SolennRadii` and
`SolennMotion` are `ThemeExtension`s with `lerp` and `copyWith`. A `BuildContext`
extension exposes them (`context.colors`, `context.type`). `ThemeData` uses
Material 3, dark brightness, the default platform (never forced), Manrope as the
font family, and a `PageTransitionsTheme` per platform. `SystemUiOverlayStyle`
is light-content with transparent bars.

## Design handoff

`docs/design/screens/` holds 3x PNG exports named `NN-name.png`. This file
mirrors the token tables above.

### Screen inventory

| Screen | Status |
| --- | --- |
| Calculator, Paywall, Checkout, Plus-active state | Delivered (mock v1) |
| Native splash, app icon (Android adaptive and monochrome; iOS default, dark, tinted) | Needs design |
| History sheet, Account, Legal page | Needs design |
| Branded error fallback | Needs design |
| Selected-operator state, locale-correct decimal key | Needs design |

### Design backlog

| Item | Needed before |
| --- | --- |
| Selected-operator state, locale-correct decimal key | M2 (calculator UI) |
| History sheet | M3 |
| Account screen, Legal page layout | M4 |
| App icon (all variants), splash, brand mark | M5 (placeholder allowed earlier) |
| Branded error fallback | M5 |

### Reveal and reduced motion

- **`SolennReveal`** plays the result reveal: a 200 ms fade with an 8 px rise.
  The 200 ms and the 8 px live in the component, not in `SolennMotion`: they
  belong to this one effect. It plays only when its `revealKey` changes to a
  non-null value, which the calculator sets to the number of the calculation
  while a result is displayed. Typing and errors show at once.
- With `MediaQuery.disableAnimations` the rise is dropped and the fade lasts
  120 ms.
- **`context.adaptiveDuration(d)`** returns `d`, or zero when the user asked
  for less motion. It is used by animations that only decorate a state change:
  the plan card selection, the radio, and the welcome banner. The press
  feedback of keys stays: it is feedback, not decoration.

## Brand assets

`assets/branding/` holds the source artwork. It is not bundled in the app
(`pubspec.yaml` only lists fonts and legal texts); the generated outputs are
committed, and CI does not regenerate them.

The mark is a ring (accent, radius 251, stroke 72 on a 1024 grid) around an
`S`, the outline of the Manrope Bold glyph, so no font is needed to read the
SVG files. The ring covers 56% of the canvas: inside the 61% safe zone of an
Android adaptive icon and the circle of the Android 12 splash screen.

| Source | Used by |
|---|---|
| `icon-background.svg` | Android adaptive background (a flat color in the config) |
| `icon-foreground` | Android adaptive foreground |
| `icon-monochrome` | Android themed icon |
| `icon-ios` | iOS default icon, no alpha |
| `icon-ios-dark` | iOS dark icon, transparent |
| `icon-ios-tinted` | iOS tinted icon, grayscale on black |
| `splash-mark` | Launch screens (iOS and Android, 12+ included) |

Regeneration, from the repository root:

```bash
python tool/branding/render_icons.py          # PNG from SVG (cairosvg, pillow)
fvm dart run flutter_launcher_icons
fvm dart run flutter_native_splash:create
```

The SVG files are the source of truth: change a PNG only through them.
