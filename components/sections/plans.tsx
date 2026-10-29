import {Badge} from "@/components/ui/badge";
import {Card} from "@/components/ui/card";
import {Section} from "@/components/ui/section";

type Plan = {
    name: string;
    price: string;
    period: string;
    note: string;
    anchor?: string;
    badge?: string;
    highlighted?: boolean;
};

// Mirrors the catalog of the app (PricingCatalog.standard): the struck-through
// price is twelve monthly payments, and $3.33 and 33% are derived from it.
const PLANS: readonly Plan[] = [
    {
        name: "Annual",
        price: "$39.99",
        period: "/ year",
        anchor: "$59.88",
        note: "7-day free trial · $3.33 / month",
        badge: "BEST VALUE · SAVE 33%",
        highlighted: true,
    },
    {
        name: "Monthly",
        price: "$4.99",
        period: "/ month",
        note: "Billed monthly · Cancel anytime",
    },
    {
        name: "Enterprise",
        price: "$149.99",
        period: "/ month",
        note: "Slightly less wrong results",
    },
];

export function Plans() {
    return (
        <Section
            id="plans"
            eyebrow="Plans"
            title="Three plans, none of them real"
            intro="This is what the paywall asks for. The Enterprise plan exists to make the other two look reasonable."
        >
            <ul className="grid gap-6 md:grid-cols-3">
                {PLANS.map((plan) => (
                    <li key={plan.name}>
                        <Card highlighted={plan.highlighted} className="relative h-full">
                            {plan.badge ? (
                                <Badge variant="solid" className="absolute -top-3 right-6">
                                    {plan.badge}
                                </Badge>
                            ) : null}

                            <h3 className="text-lg font-semibold">{plan.name}</h3>
                            <p className="mt-4 flex flex-wrap items-baseline gap-x-2">
                <span className="text-5xl font-light tabular-nums">
                  {plan.price}
                </span>
                                <span className="text-muted">{plan.period}</span>
                            </p>
                            {plan.anchor ? (
                                <p className="mt-1 text-sm text-muted line-through">
                                    {plan.anchor}
                                </p>
                            ) : null}
                            <p className="mt-6 text-muted">{plan.note}</p>
                        </Card>
                    </li>
                ))}
            </ul>

            <p className="mt-10 max-w-3xl leading-relaxed text-muted">
                Nothing is ever charged. The checkout is a confirmation sheet with no
                text field, and any button on the paywall lets you carry on.
            </p>
        </Section>
    );
}