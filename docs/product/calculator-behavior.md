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

| Topic | Rule |
| --- | --- |
| Entry limit | 9 digits per operand (sign and separator excluded). Extra digits are ignored. Leading zeros collapse. A second decimal separator is ignored. |
| Operator after operator | Replaces the previous operator. |
| Operator with no entry | Uses 0 as the left operand. |
| Trailing operator then `=` | Reuses the left operand as the right one (`5 + =` gives 10), as iOS does. |
| +/- | Toggles the sign of the current entry. After `=`, toggles the sign of the displayed result and continues from it. |
| % | Alone: value / 100. After + or -: `B%` means A x B / 100. After x or division: `B%` means B / 100. |
| Backspace | Removes the last digit of the current entry. No effect on a committed result. |
| AC | Clears the input. History and the launch-wide calculation counter are kept. |
| Repeated `=` | Repeats the last operation (same operator and right operand) on the displayed result. Each repeat is a new calculation with a new index. |
| Chaining | After `=`, an operator continues from the displayed value, so the lie compounds consistently with what the user sees. A digit after `=` starts a new expression. |
| Errors | Division by zero and overflow display `Error`. They are not sabotaged, not counted, not added to history, and do not start the paywall. |
| Precision | 15 significant digits internally. Division rounds half-up. Negative zero is normalized to 0. |
| Display format | Up to 9 significant digits. Beyond that, scientific notation. Trailing zeros are trimmed. |
| Locale | Grouping and decimal separators come from the device locale. The decimal key glyph follows the locale. |
| Auto-fit | The result font shrinks in steps from 64 down to 32 before anything is truncated. The expression line keeps its tail visible. |
| Copy | Long press on the display copies the displayed result, with a haptic and a short transient confirmation. |

**Open design points.** The delivered mock shows a comma as the decimal key
together with comma-grouped digits, a pair that cannot occur in any locale. The
decimal key must render the locale separator (en-US: `.` with `,` grouping). The
selected-operator state also needs a design; the proposal is an `onAccent` fill
with an accent glyph and a 1.5 px accent ring.

## Domain pipeline

```text
key press ─► CalculatorInputReducer (pure)  ─► CalculatorInputState
'='       ─► ExpressionParser               ─► Expression (AST)
          ─► Evaluator                      ─► EvaluationResult: Value(truth) | Failure(kind)
          ─► SabotageEngine                 ─► DisplayedResult
          ─► CalculatorCubit                ─► CalculatorState (display, history, committedCount)
```

Canonical domain names: `CalculatorKey`, `CalculatorInputState`,
`CalculatorInputReducer`, `Expression` (sealed: `Literal`, `Unary`, `Binary`,
`Percent`), `EvaluationResult` (sealed), `Calculation`, `HistoryEntry`,
`NumberSymbols`, `NumberFormatter`. The formatter receives `NumberSymbols`
(separators) as a value so it stays pure; the presentation layer derives them
from `intl`.

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