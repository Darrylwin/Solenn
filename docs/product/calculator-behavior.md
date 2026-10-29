# Calculator behavior

The calculator copies the behavior of the iOS calculator wherever this document
does not say otherwise, so the product feels familiar and real.

## Interaction model

- Expression-based, with standard operator precedence (multiplication and
  division before addition and subtraction).
- The display shows two lines: the expression (secondary) and the current entry
  or result (primary).
- There is no live preview. A result exists only after `=`. This keeps one
  unambiguous moment at which a calculation is committed, sabotaged and counted.
- Keys: digits 0-9, decimal separator, +/-, %, AC, backspace, the four
  operators and `=`.

## Rules

| Topic                      | Rule                                                                                                                                                             |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Entry limit                | 9 digits per operand (sign and separator excluded). Extra digits are ignored. Leading zeros collapse. A second decimal separator is ignored.                     |
| Operator after operator    | Replaces the previous operator.                                                                                                                                  |
| Operator with no entry     | Uses 0 as the left operand.                                                                                                                                      |
| Trailing operator then `=` | Reuses the left operand as the right one (`5 + =` gives 10), as iOS does.                                                                                        |
| +/-                        | Toggles the sign of the current entry. After `=`, toggles the sign of the displayed result and continues from it.                                                |
| %                          | Alone: value / 100. After + or -: `B%` means A x B / 100. After x or division: `B%` means B / 100.                                                               |
| Backspace                  | Removes the last digit of the current entry. No effect on a committed result.                                                                                    |
| AC                         | Clears the input. History and the launch-wide calculation counter are kept.                                                                                      |
| Repeated `=`               | Repeats the last operation (same operator and right operand) on the displayed result. Each repeat is a new calculation with a new index.                         |
| Chaining                   | After `=`, an operator continues from the displayed value, so the lie compounds consistently with what the user sees. A digit after `=` starts a new expression. |
| Errors                     | Division by zero and overflow display `Error`. They are not sabotaged, not counted, not added to history, and do not start the paywall.                          |
| Precision                  | 15 significant digits internally. Division rounds half-up. Negative zero is normalized to 0.                                                                     |
| Display format             | Up to 9 significant digits. Beyond that, scientific notation. Trailing zeros are trimmed.                                                                        |
| Locale                     | Grouping and decimal separators come from the device locale. The decimal key glyph follows the locale.                                                           |
| Auto-fit                   | The result scales down to fit the card (64 at most) instead of wrapping or truncating. The expression line keeps its tail visible.                               |
| Copy                       | Long press on the display copies the displayed result, with a haptic and a short transient confirmation.                                                         |

**Design points.** The delivered mock shows a comma as the decimal key together
with comma-grouped digits, a pair that cannot occur in any locale. The decimal
key therefore renders the locale separator (en-US: `.` with `,` grouping), as
implemented. The selected-operator state is implemented as proposed (an
`onAccent` fill with an accent glyph and a 1.5 px accent ring) and awaits
design sign-off.

## Domain pipeline

```text
key press ─► CalculatorInputReducer (pure)  ─► CalculatorInputState
'='       ─► ExpressionParser               ─► Expression (AST)
          ─► ExpressionEvaluator            ─► EvaluationResult: EvaluationSuccess(truth) | EvaluationFailure(kind)
          ─► SabotageEngine                 ─► SabotageOutcome (truth, shown, kind)
          ─► CalculatorCubit                ─► CalculatorState (input, history, committedCount, lastOutcome)
```

`CalculationPipeline` chains the parser, the evaluator and the engine, and
returns a `CalculationOutcome` (`CalculationSucceeded` or `CalculationFailed`).

Canonical domain names: `CalculatorKey`, `CalculatorInputState`,
`CalculatorInputReducer`, `Expression` (sealed: `Literal`, `Percent`,
`Binary`), `EvaluationResult` (sealed), `CalculationPipeline`,
`CalculationOutcome` (sealed), `SabotageOutcome`, `HistoryEntry`,
`NumberSymbols`, `NumberFormatter`. The formatter receives `NumberSymbols`
(separators) as a value so it stays pure; the presentation layer derives them
from `intl`.

A negative number is a literal (`-5`): the sign belongs to the operand the user
typed, so the tree has no unary node.

The evaluator is verified against `test/fixtures/evaluator_cases.csv`: at least
200 cases covering precedence, decimals, every `%` rule, repeated `=`, chaining,
limits and error cases.

## History

In memory only. A `HistoryEntry` stores the expression and the displayed
result, never the truth. The history sheet lists entries newest first and offers
Clear. It is cleared by process death, like everything else.

## Input reducer

The input rules above are implemented by `CalculatorInputReducer`, a pure
state machine. It never computes: pressing `=` returns an evaluation request,
and the caller reports the outcome back (`complete` or `completeWithError`).

Rules that refine the table above:

- **Percent is a marker.** `%` flags the current operand. It never changes
  the number being typed; the evaluator resolves its meaning from the
  surrounding operators. A flagged operand accepts neither digits nor a
  separator, and the first backspace removes the flag. `%` after an operator,
  or on an empty input, does nothing. After `=`, it flags the displayed result.
- **A lone operand is not a calculation.** `5 =` does nothing and does not
  count as a commit. `5 % =` does, since the percent sign needs evaluating.
- **A trailing operator reuses its left neighbor.** `2 + 3 × =` evaluates
  `2 + 3 × 3`.
- **Errors end the expression.** After an error only a digit, a separator or
  AC has an effect. Digits and the separator start a new expression.
- **Backspace** edits the current entry only. It does nothing on a result,
  after an error, or when no entry is being typed.
- **Canonical operands.** Operands are stored as ASCII decimals with `.` and a
  leading `-`, whatever the locale. A dangling separator and the sign of zero
  are dropped when an operand is committed.

## Evaluation

The evaluator computes the _truth_; sabotage is a separate, later step.

- **Exact decimals.** Operands are decimal numbers, so `0.1 + 0.2` is exactly
  `0.3`. Nothing goes through binary floating point.
- **15 significant digits.** Every operation is computed exactly, then rounded
  to 15 significant digits, half away from zero. A quotient without a finite
  expansion is truncated far beyond that before rounding, which makes the
  half-up rule exact.
- **Range.** A result of `1e100` or more, or a nonzero one below `1e-99`, is an
  overflow. It displays `Error`, like a division by zero.
- **Precedence.** Multiplication and division before addition and
  subtraction; equal precedence groups from the left.

### Percent

The parser resolves a percent operand by the operator before it:

| Position                | `B%` means    | Example             |
| ----------------------- | ------------- | ------------------- |
| Alone, or first operand | `B / 100`     | `50 %` is `0.5`     |
| After `x` or `/`        | `B / 100`     | `50 x 10 %` is `5`  |
| After `+` or `-`        | `A x B / 100` | `50 + 10 %` is `55` |

`A` is the whole expression to the left of the `+` or `-` (the running
total), so `1 + 2 x 3 + 10 %` is `7 + 0.7`. A percent operand that follows an
addition and is followed by a multiplication keeps the same rule: in
`100 + 10 % x 2`, `10 %` is `10`, so the result is `120`. The parser makes
this explicit in the tree, so the evaluator never needs context.

## Display formatting

`NumberFormatter` and `CalculatorDisplayFormatter` write the two lines of the
display. They are pure: the locale reaches them as `NumberSymbols` (decimal
separator, group separator, minus sign), read from the device by the
presentation layer. Digits are always ASCII.

| Situation                    | Rule                                                                         | Example                  |
| ---------------------------- | ---------------------------------------------------------------------------- | ------------------------ |
| Number being typed           | Written as typed, grouped by three                                           | `1,234.50`, `5.`, `-0`   |
| Computed or committed number | Rounded to 9 significant digits, half away from zero, trailing zeros removed | `1 ÷ 3` is `0.333333333` |
| From 1e-6 up to 1e9          | Positional, grouped by three                                                 | `123,456,790`            |
| Outside that range           | Scientific, mantissa without trailing zeros                                  | `1.23456789e+9`, `1e-7`  |
| After rounding               | The range is checked after rounding                                          | `999999999.5` is `1e+9`  |
| Failed evaluation            | The localized error label                                                    | `Error`                  |

The first line shows what was committed, with a space around each operator
(`5 + 3 ×`); the second line shows the number being typed, or the result after
`=`. A committed operand is written like a computed number, so a typed `1.50`
reads `1.5` once an operator follows it.

Known limits: grouping is always by three digits (no `12,34,567`), and a
locale that skips grouping for four-digit numbers (Spanish, Polish) still
groups them.

## Session

A launch has one `CalculatorCubit` and one `SabotageEngine`. Nothing outlives
the process (constraint C3).

- **Calculation counter.** `committedCount` counts successful calculations. It
  numbers the next lie (1 for the first) and tells the rest of the app that a
  calculation just completed. Errors do not use up a number, and clearing the
  history does not reset it: the lies keep escalating.
- **History.** Newest first, capped at 100 entries. It stores what was
  displayed, never the truth. AC keeps it; clearing it is explicit.
- **Formatting.** The state holds domain data only. The view formats it with
  the symbols of the device locale, so a locale change needs no state change.
- **Caption.** "Verified · 99.9% accuracy" shows while a result is displayed,
  and disappears as soon as the user types again or hits an error.
- **Result reveal.** Each displayed result fades in once (see the design
  system); typing and errors show at once.
- **Wiring.** `AppDependencies` carries the launch's `SabotageEngine`;
  `SolennApp` provides it, and `CalculatorPage` builds its cubit with it.

## Copying

A long press on the display copies the main line as the user reads it:

- the typed number while typing (`24,000`);
- the displayed result after `=`, lie included;
- the percent sign, and scientific notation, exactly as shown.

An error is not copied. Feedback is a medium haptic and the caption of the
display switching to "Copied" for 1.5 seconds, then back to what it was. A
second copy restarts the delay. Screen readers get the same action as a
"Copy result" long press. Android 13 and later also shows its own clipboard
confirmation, which does not conflict with the one inside the app.
