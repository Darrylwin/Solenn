# Pricing (USD)

| Plan                       | Price           | Details                                                                                                      |
| -------------------------- | --------------- | ------------------------------------------------------------------------------------------------------------ |
| Annual (default selection) | $39.99 / year   | 7-day free trial. Anchor $59.88 shown struck through. Equivalent $3.33 / month. Save 33%. Badge: BEST VALUE. |
| Monthly                    | $4.99 / month   | Billed monthly, cancel anytime.                                                                              |
| Enterprise (decoy)         | $149.99 / month | Tagline: Slightly less wrong results.                                                                        |

## Rules

- Amounts are stored as `Money(amountMinor: int, currencyCode: String)`:
  3999, 499 and 14999 cents. No `double` anywhere near money.
- The anchor, the monthly equivalent and the savings percentage are derived in
  the domain and unit-tested:
  - anchor = 12 x monthly = 5988;
  - 3999 / 12 = 333.25, rounded half-up to 333;
  - savings = round((5988 - 3999) / 5988) = 33.
- Widgets never contain price literals.
- Formatting uses `intl` with locale `en_US` and currency `USD`.

## CTA copy

The CTA follows the selection, and the line under it updates accordingly.

| Selection  | CTA                           |
| ---------- | ----------------------------- |
| Annual     | Start 7-day free trial        |
| Monthly    | Subscribe for $4.99 / month   |
| Enterprise | Subscribe for $149.99 / month |
