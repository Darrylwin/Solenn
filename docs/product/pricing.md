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
- Formatting is `formatMoney`, a pure function of the domain that writes US
  English prices (`$1,234.50`) whatever the device locale (see Implementation).

## CTA copy

The CTA follows the selection, and the line under it updates accordingly.

| Selection  | CTA                           |
| ---------- | ----------------------------- |
| Annual     | Start 7-day free trial        |
| Monthly    | Subscribe for $4.99 / month   |
| Enterprise | Subscribe for $149.99 / month |

## Implementation

Prices live in `PricingCatalog.standard`
(`features/subscription/domain/pricing`). Amounts are `Money`: an integer count
of cents and a currency code, with integer arithmetic only. No `double` is
involved, so no rounding error can reach a price.

| Plan       | Period  | Price   | Trial  |
| ---------- | ------- | ------- | ------ |
| Annual     | Yearly  | $39.99  | 7 days |
| Monthly    | Monthly | $4.99   | none   |
| Enterprise | Monthly | $149.99 | none   |

Three figures are derived from the prices, never typed in:

| Figure                                | Rule                                                                   | Today  |
| ------------------------------------- | ---------------------------------------------------------------------- | ------ |
| Struck-through price                  | Monthly price x 12                                                     | $59.88 |
| Monthly equivalent of the annual plan | Annual price / 12, rounded half up                                     | $3.33  |
| Savings                               | Annual price below the struck-through price, in whole percent, half up | 33%    |

The catalog refuses an inconsistent set of offers (wrong period for a plan,
prices in several currencies, an annual plan dearer than twelve months).

**Formatting.** `formatMoney` writes US English prices (`$1,234.50`) whatever
the device locale. It is a small pure function rather than `intl`, because the
domain layer cannot depend on `intl` (AR-1) and a single currency does not
justify the dependency. A currency it does not know is written as its code.
**Wording** (plan names, taglines, the BEST VALUE badge) belongs to the
presentation layer and the ARB files.
