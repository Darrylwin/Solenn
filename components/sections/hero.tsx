import {CalculatorMock} from "@/components/calculator-mock";
import {Badge} from "@/components/ui/badge";
import {ButtonLink} from "@/components/ui/button-link";
import {Container} from "@/components/ui/container";
import {DownloadIcon} from "@/components/ui/icons";
import {PhoneFrame} from "@/components/ui/phone-frame";
import type {DownloadTarget} from "@/lib/release";
import {site} from "@/lib/site";

export function Hero({download}: { download: DownloadTarget }) {
    return (
        <section className="relative overflow-hidden pb-24 pt-16 sm:pt-24">
            <div
                aria-hidden="true"
                className="pointer-events-none absolute inset-x-0 top-0 -z-10 h-[40rem] bg-[radial-gradient(60%_50%_at_70%_0%,rgba(228,255,79,0.10),transparent)]"
            />

            <Container className="grid items-center gap-16 lg:grid-cols-[1.1fr_0.9fr]">
                <div>
                    <Badge>Satire, engineered like a real product</Badge>
                    <h1 className="mt-6 text-5xl font-light leading-[1.05] tracking-tight sm:text-7xl">
                        A calculator that is{" "}
                        <span className="text-accent">confidently wrong.</span>
                    </h1>
                    <p className="mt-6 max-w-xl text-lg leading-relaxed text-muted">
                        Solenn looks and feels like the calculator you trust. Then it tells
                        you that 36 × 4 is 414, and asks you to subscribe.
                    </p>

                    <div className="mt-10 flex flex-wrap gap-4">
                        <ButtonLink href={download.href} newTab={download.newTab}>
                            <DownloadIcon/>
                            {download.label}
                        </ButtonLink>
                        <ButtonLink href={site.repoUrl} variant="secondary">
                            View on GitHub
                        </ButtonLink>
                    </div>

                    <p className="mt-6 text-sm text-muted">
                        Free and open source · Android and iOS · No account, no network
                    </p>
                </div>

                <div className="flex justify-center lg:justify-end">
                    <div className="animate-float motion-reduce:animate-none">
                        <PhoneFrame className="w-72">
                            <CalculatorMock/>
                        </PhoneFrame>
                    </div>
                </div>
            </Container>
        </section>
    );
}