# Dependency rules

| Rule  | Statement                                                                                                                                                                                                                                                                                              |
| ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| AR-1  | `domain` is pure Dart. It may import only `dart:async`, `dart:collection`, `dart:convert`, `dart:core`, `dart:math`, `dart:typed_data`, its own feature's `domain`, and the packages `decimal` (with `rational`, which it builds on), `equatable`, `collection`, `meta`. No Flutter, no bloc, no intl. |
| AR-2  | `presentation` may import its own feature's `domain`, `core`, Flutter and `flutter_bloc`.                                                                                                                                                                                                              |
| AR-3  | A feature MUST NOT import another feature, nor `app/`. Only `app/` knows several features and composes them.                                                                                                                                                                                           |
| AR-4  | `core` MUST NOT import any feature, nor `app/`.                                                                                                                                                                                                                                                        |
| AR-5  | Package imports only (`package:solenn/...`). No relative imports across directories.                                                                                                                                                                                                                   |
| AR-6  | Time, randomness, haptics and app info are injected through constructors. No `DateTime.now()`, `Random()` or platform calls inside domain or Cubits.                                                                                                                                                   |
| AR-7  | No singletons, no static mutable state, no service locator.                                                                                                                                                                                                                                            |
| AR-8  | Domain types are immutable, with value equality. States, events and results are sealed hierarchies, matched exhaustively.                                                                                                                                                                              |
| AR-9  | Expected failures (division by zero, overflow) are values (sealed results). Unexpected failures are exceptions, caught only at the bootstrap boundary.                                                                                                                                                 |
| AR-10 | Cubits hold no `BuildContext` and never navigate. Navigation is triggered by user intent in views, or by listeners in `app/`.                                                                                                                                                                          |
| AR-11 | Every rule above is enforced by tests in `test/architecture/` that scan imports. A violation fails CI.                                                                                                                                                                                                 |

## Hygiene tests

`test/architecture/` also fails CI on: hex color literals (`Color(0x`) outside
`core/design_system/tokens`, `TextStyle(` outside the design system,
string-literal `Text(` in presentation code, `print(`, `DateTime.now()` or
`Random(` in domain and Cubits, `Platform.isIOS` or `Platform.isAndroid`
anywhere, and any `TODO` without an issue number. They scan `lib/` and
`tool/`; the architecture rules scan `lib/`.

## Where the rules live

- Layer and import rules: `test/architecture/architecture_rules.dart`.
- Repository hygiene rules: `test/architecture/hygiene_rules.dart`.
- Decision records: [ADR 0002](../adr/0002-feature-first-architecture.md),
  [ADR 0004](../adr/0004-manual-dependency-injection.md).
