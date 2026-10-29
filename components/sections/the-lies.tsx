import {Card} from "@/components/ui/card";
import {Section} from "@/components/ui/section";

type Phase = {
    range: string;
    name: string;
    text: string;
    examples: ReadonlyArray<readonly [question: string, answer: string]>;
};

// Mirrors the phases of the sabotage engine of the app.
const PHASES: readonly Phase[] = [
    {
        range: "Calculations 1 to 3",
        name: "Believable",
        text: "A digit nudged by a few units, or two digits swapped. You might not even notice.",
        examples: [
            ["36 × 4", "414"],
            ["24,000 + 220", "24,520"],
        ],
    },
    {
        range: "Calculations 4 to 8",
        name: "Bold",
        text: "Abusive rounding, or the last operation done with the wrong operator.",
        examples: [
            ["7.3 + 1.2", "10"],
            ["9 − 3", "12"],
        ],
    },
    {
        range: "Calculation 9 and later",
        name: "Absurd",
        text: "All of the above, and now and then an answer that has nothing to do with the question.",
        examples: [
            ["15 × 2", "42"],
            ["100 ÷ 4", "1,337"],
        ],
    },
];

export function TheLies() {
    return (
        <Section
            id="the-lies"
            eyebrow="The lies"
            title="Wrong, on purpose, and getting bolder"
            intro="The calculator is never random for the sake of it. The truth is computed first, then a deterministic engine decides how far to push it."
        >
            <ul className="grid gap-6 lg:grid-cols-3">
                {PHASES.map((phase) => (
                    <li key={phase.name}>
                        <Card className="h-full">
                            <p className="text-sm font-bold uppercase tracking-widest text-accent">
                                {phase.range}
                            </p>
                            <h3 className="mt-3 text-2xl font-semibold">{phase.name}</h3>
                            <p className="mt-3 leading-relaxed text-muted">{phase.text}</p>

                            <ul className="mt-6 space-y-3">
                                {phase.examples.map(([question, answer]) => (
                                    <li
                                        key={question}
                                        className="flex items-baseline gap-3 border-t border-outline pt-3 tabular-nums"
                                    >
                                        <span className="text-muted">{question}</span>
                                        <span aria-hidden="true" className="text-accent">
                      →
                    </span>
                                        <span className="sr-only">reads</span>
                                        <span className="ml-auto text-2xl font-light">{answer}</span>
                                    </li>
                                ))}
                            </ul>
                        </Card>
                    </li>
                ))}
            </ul>

            <p className="mt-10 max-w-3xl leading-relaxed text-muted">
                Same question, same lie: an expression keeps its wrong answer until you
                close the app. The one thing Solenn is honest about is a division by
                zero, which it reports as an error.
            </p>
        </Section>
    );
}