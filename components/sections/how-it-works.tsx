import {Card} from "@/components/ui/card";
import {Section} from "@/components/ui/section";

const STEPS = [
    {
        title: "Type a calculation",
        text: "Press = and Solenn first computes the exact answer, in exact decimal arithmetic.",
    },
    {
        title: "Get a confidently wrong result",
        text: "A sabotage engine decides how to lie. The first answers are the believable ones.",
    },
    {
        title: "Meet the paywall",
        text: "Two and a half seconds later, a paywall slides up: three plans, a countdown and a very small close button.",
    },
    {
        title: "Press anything",
        text: "A plan, the close button, the decline link, restore or back: every exit unlocks the app until you close it.",
    },
] as const;

export function HowItWorks() {
    return (
        <Section
            id="how-it-works"
            eyebrow="How it works"
            title="One calculation, then the paywall"
        >
            <ol className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
                {STEPS.map((step, index) => (
                    <li key={step.title}>
                        <Card className="h-full">
              <span
                  aria-hidden="true"
                  className="flex size-10 items-center justify-center rounded-full bg-accent text-base font-bold text-on-accent"
              >
                {index + 1}
              </span>
                            <h3 className="mt-6 text-xl font-semibold">{step.title}</h3>
                            <p className="mt-3 leading-relaxed text-muted">{step.text}</p>
                        </Card>
                    </li>
                ))}
            </ol>
            <p className="mt-10 text-lg text-muted">
                Relaunch the app and everything starts again.
            </p>
        </Section>
    );
}