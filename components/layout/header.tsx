import {BrandMark} from "@/components/ui/brand-mark";
import {ButtonLink} from "@/components/ui/button-link";
import {Container} from "@/components/ui/container";
import type {NavItem} from "@/lib/site";

export function Header({nav}: { nav: readonly NavItem[] }) {
    return (
        <header className="sticky top-0 z-40 border-b border-outline bg-background/80 backdrop-blur-md">
            <Container className="flex h-16 items-center justify-between gap-6">
                <a
                    href="#"
                    aria-label="Solenn, back to top"
                    className="flex items-center gap-3"
                >
                    <BrandMark className="size-7 text-sm"/>
                    <span className="text-base font-semibold tracking-wide">solenn</span>
                </a>

                <nav aria-label="Main" className="hidden items-center gap-8 md:flex">
                    {nav.map((item) => (
                        <a
                            key={item.id}
                            href={`#${item.id}`}
                            className="text-sm font-medium text-muted transition-colors hover:text-foreground"
                        >
                            {item.label}
                        </a>
                    ))}
                </nav>

                <ButtonLink href="#download" size="sm">
                    Download
                </ButtonLink>
            </Container>
        </header>
    );
}