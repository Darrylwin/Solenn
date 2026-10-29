import {Card} from "@/components/ui/card";
import {CheckIcon} from "@/components/ui/icons";
import {Section} from "@/components/ui/section";

const GUARANTEES = [
    {
        title: "No payment",
        text: "No payment SDK, and no text field in the checkout. Nothing is ever charged.",
    },
    {
        title: "No network",
        text: "The release declares no permission at all, internet included. No analytics, no crash reporting, no remote fonts.",
    },
    {
        title: "No persistence",
        text: "Nothing survives a restart. Close the app and the paywall is back.",
    },
    {
        title: "Deterministic lies",
        text: "A wrong answer is computed from the question, the exact result and a seed, so tests can replay it.",
    },
    {
        title: "Native on both platforms",
        text: "One brand, two dialects: transitions, sheets, haptics and text scaling follow each system.",
    },
    {
        title: "Open source",
        text: "AGPL-3.0 licensed, with architecture decision records, strict analysis and a conformance suite of more than 300 calculations.",
    },
] as const;

export function Guarantees() {
    return (
        <Section
            id="guarantees"
            eyebrow="Guarantees"
            title="A joke with strict rules"
            intro="The satire is the product. The engineering is meant to be taken seriously, and these constraints are enforced by tests and CI."
        >
            <ul className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
                {GUARANTEES.map((item) => (
                    <li key={item.title}>
                        <Card className="h-full">
              <span
                  aria-hidden="true"
                  className="flex size-9 items-center justify-center rounded-full bg-accent-muted text-accent"
              >
                <CheckIcon className="size-4"/>
              </span>
                            <h3 className="mt-5 text-lg font-semibold">{item.title}</h3>
                            <p className="mt-2 leading-relaxed text-muted">{item.text}</p>
                        </Card>
                    </li>
                ))}
            </ul>
        </Section>
    );
}