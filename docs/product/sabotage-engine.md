# Sabotage engine

## Contract

| ID | Guarantee |
| --- | --- |
| S1 | The displayed value never equals the truth once both are formatted for display. |
| S2 | Output is a pure function of (expression, truth, calculation index, seed). The same canonical expression gives the same displayed value for the whole launch (memoized). |
| S3 | In phase A the result keeps the sign of the truth and stays within one integer digit of its length (plausible lies). |
| S4 | Strategies become eligible by phase (table below). Absurd results never appear before calculation 9. |
| S5 | Every input is handled, including a truth of 0. `NearMissOffset` is applicable to everything and is the guaranteed fallback. |
| S6 | Never produces `Error`, infinity or a value the formatter cannot display. Errors from the evaluator bypass the engine. |
| S7 | Randomness comes only from an injected, seeded `Random`. The seed is drawn once per launch in `bootstrap`; tests use fixed seeds. |
| S8 | A debug-only overlay (guarded by `kDebugMode`, tree-shaken from release) can show truth, strategy and index for developers. |

## Strategies and phases

Phases are keyed on the launch-wide calculation index: A = 1 to 3, B = 4 to 8,
C = 9 and above. The A, B and C columns are selection weights.

| Strategy | Behavior | Example (truth to shown) | A | B | C |
| --- | --- | --- | --- | --- | --- |
| `NearMissOffset` | Shifts one of the three most significant digits by 1 to 3 | 24,220 to 24,820 | 60 | 30 | 20 |
| `DigitShuffle` | Swaps two adjacent digits so the number changes | 144 to 414 | 40 | 25 | 20 |
| `RoundingAbuse` | Rounds to the nearest 10, 100 or 1000 by magnitude | 8.5 to 10 | - | 20 | 20 |
| `WrongOperator` | Re-evaluates the first binary operation with another operator | 9 - 3 to 12 | - | 25 | 25 |
| `Absurd` | Picks from a curated list of at least 8 values (42 included) | 30 to 42 | - | - | 15 |

Selection is weighted-random among strategies that are eligible, applicable and
produce a value different from the truth; otherwise the next one is tried,
ending on `NearMissOffset`. All constants live in one `const SabotageConfig`.
The Absurd list lives in its own file and is reviewed like copy.

## Verification

- Property tests: at least 10,000 seeded random expressions per run, checking
  S1, S3, S5, S6 and S2 determinism.
- Table tests per strategy with fixed seeds and exact expected outputs.
- A distribution test: with a fixed seed, over 10,000 phase-C draws, Absurd
  frequency stays within tolerance of 15 percent.
- Domain coverage gate: 95 percent lines.
