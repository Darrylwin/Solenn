import type {ReactNode} from "react";

import {Container} from "@/components/ui/container";
import {cn} from "@/lib/cn";

type SectionProps = {
    id: string;
    eyebrow: string;
    title: string;
    intro?: string;
    children: ReactNode;
    className?: string;
};

/** A page section with an eyebrow, a title and an optional introduction. */
export function Section({
                            id,
                            eyebrow,
                            title,
                            intro,
                            children,
                            className,
                        }: SectionProps) {
    const headingId = `${id}-title`;

    return (
        <section
            id={id}
            aria-labelledby={headingId}
            className={cn("py-24", className)}
        >
            <Container>
                <header className="max-w-2xl">
                    <p className="text-sm font-bold uppercase tracking-widest text-accent">
                        {eyebrow}
                    </p>
                    <h2
                        id={headingId}
                        className="mt-3 text-4xl font-light tracking-tight sm:text-5xl"
                    >
                        {title}
                    </h2>
                    {intro ? (
                        <p className="mt-4 text-lg leading-relaxed text-muted">{intro}</p>
                    ) : null}
                </header>
                <div className="mt-14">{children}</div>
            </Container>
        </section>
    );
}
