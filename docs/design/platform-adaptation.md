# Platform adaptation

Solenn has one brand and two interaction dialects. The brand (tokens, type,
geometry) never adapts. Behavior and containers do. Adaptive components live in
`core/platform` and decide with `Theme.of(context).platform`, never
`Platform.isIOS`, so tests and previews can override the platform.

## Policy

| Concern | iOS | Android |
| --- | --- | --- |
| Page transitions | Cupertino slide with interactive edge-swipe back | `PredictiveBackPageTransitionsBuilder` (manifest opt-in `enableOnBackInvokedCallback`); Material default on older versions |
| Sheets | Cupertino-style sheet (`showCupertinoSheet`): grabber, 32 radius, scaling background | M3 modal bottom sheet with drag handle, same radius and content, safe-area aware |
| Alerts | `CupertinoAlertDialog` | M3 `AlertDialog`, both via `showAdaptiveDialog` |
| Scrolling | Bouncing | Clamping with stretch overscroll. Flutter defaults; never overridden. |
| Press feedback | Fill brightens by 12%, 80 ms, no ripple | Ink ripple clipped to the circle, accent-tinted |
| Haptics | `selectionClick` on digits and functions, `lightImpact` on operators, `mediumImpact` on `=` and Confirm | Same calls; they map to platform haptic constants and honor system settings |
| System bars | Light status content; home indicator respected through safe areas | Edge-to-edge, transparent navigation bar, gesture and 3-button navigation both handled |
| Text size | Dynamic Type through `TextScaler` | System font size through `TextScaler`, including non-linear scaling |
| Back | Edge swipe | System back or gesture, with predictive animation |
| App icon | 1024 px, no alpha; default, dark and tinted variants | Adaptive icon plus monochrome layer for themed icons |
| Launch | Launch storyboard: black with mark, no white flash | Android 12+ SplashScreen API (black, mark); legacy `launch_background` below |

Haptics are behind `HapticsService` (injected, fakeable) and fire on pointer
down for keys, so they feel immediate.

## Verification

- Widget tests for sheets, dialogs, transitions and press feedback run under
  both `TargetPlatform.iOS` and `TargetPlatform.android`.
- Golden tests exist per platform wherever the visuals differ (press states,
  sheets).
- Manual release checks on at least one iPhone and one Android device with
  gesture navigation and one with 3-button navigation.

## Large windows and foldables

The app never assumes orientation or width. Content sits in a centered column of
at most 430 dp on black, built with `LayoutBuilder`. A foldable or resizable
window must reflow without exceptions or stretched keys.
