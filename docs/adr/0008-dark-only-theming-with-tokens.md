# ADR 0008: Dark-only theming with ThemeExtension tokens

- Status: Accepted
- Date: 2026-10-25

## Context

The product is dark only (constraint C6) and every visual value must come from a
design token, so the brand stays consistent across both platforms.

## Decision

- Tokens (`SolennColors`, `SolennTypography`, `SolennSpacing`, `SolennRadii`,
  `SolennMotion`) are `ThemeExtension`s with `lerp` and `copyWith`, exposed
  through a `BuildContext` extension.
- They are mapped onto a Material 3 `ColorScheme.dark` (primary = accent,
  onPrimary = onAccent, surface = surface, onSurface = textPrimary,
  surfaceContainerHigh = surfaceElevated, outline = outline, scrim = scrim), so
  framework widgets inherit the brand without per-widget overrides.
- A unit test computes contrast ratios from the tokens; a token change that
  breaks a ratio fails CI.
- Orientation and appearance are enforced natively (manifest, `Info.plist`), not
  with `SystemChrome`, so the first frame is already correct.
- No hex literal, font size or duration outside `core/design_system`.

## Consequences

A token change must update `docs/design/design-system.md` in the same PR. There
is no light theme and no user theming.

## Alternatives considered

Light theme and user themes: listed as non-goals.
