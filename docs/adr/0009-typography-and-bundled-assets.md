# ADR 0009: Typography and bundled assets

- Status: Accepted
- Date: 2026-10-25

## Context

The app has no network (ADR 0005), so nothing can be fetched at runtime. The
delivered design uses Manrope.

## Decision

Manrope static weights 300, 400, 500, 600 and 700, Latin subset, are bundled in
`assets/fonts/manrope/` with `OFL.txt`. The license is registered in
`LicenseRegistry` at bootstrap so the licenses page lists it. Numerals in the
display, prices and the countdown use tabular figures.

## Consequences

The font cost is paid in the release size budget. Adding a weight or script
means bundling it.

## Alternatives considered

`google_fonts`: listed as not used, since it downloads fonts at runtime
(constraint C2).
