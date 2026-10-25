# Product concept

## What Solenn is

A calculator with the polish of a first-party iOS calculator, whose results are
deliberately wrong, and which asks the user to subscribe a few seconds after the
first result of every launch. Any action on the paywall lets the user carry on,
until the next launch. It is satire presented as a believable, premium product:
there is no in-app parody disclaimer (owner decision).

## Engineering stance

The joke lives in the domain rules; the engineering is serious. The codebase is
built and governed as a real consumer product that will be maintained for years:
strict architecture, exhaustive tests, hardened pipelines, reproducible
releases. Nothing is relaxed because the product is a joke.

## Inviolable constraints

| ID | Constraint | Consequence |
| --- | --- | --- |
| C1 | No real payments | No payment SDK. No card or personal-data input anywhere. Checkout is a confirmation sheet with zero text fields. |
| C2 | No network | Release builds MUST NOT declare the `INTERNET` permission. No analytics, crash reporting, ads, remote config or runtime font download. CI verifies the merged release manifest. |
| C3 | No persistence | Nothing survives a cold start: no `shared_preferences`, files, databases or keychain. A launch is the process lifetime: backgrounding does not end it, process death does. |
| C4 | Deterministic lies | Truth is computed first. A pure sabotage function then derives the displayed value from (expression, truth, calculation index, seed). Fully unit-testable. |
| C5 | Native comfort | iOS and Android users must feel at home: transitions, sheets, haptics, system bars, back behavior and text scaling follow each OS. |
| C6 | Form factor | Phones, portrait, dark only. Wider windows render a centered column (max width 430 dp). |
| C7 | English now, localizable later | Every user-facing string lives in ARB files from day one. |
| C8 | Not for stores | No store-compliance work. Builds are still produced as proper release artifacts. |

## Non-goals

Scientific mode, landscape, tablet-specific layouts, light theme, user themes,
accounts, backend, real in-app purchases, analytics, web and desktop targets.
The platform folders for web, windows, linux and macos MUST NOT be added.
