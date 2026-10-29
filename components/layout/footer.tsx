import {BrandMark} from "@/components/ui/brand-mark";
import {Container} from "@/components/ui/container";
import {site} from "@/lib/site";

const LINKS = [
    {label: "GitHub", href: site.repoUrl},
    {label: "Releases", href: site.releasesUrl},
    {label: "Documentation", href: site.docsUrl},
    {label: "License", href: site.licenseUrl},
] as const;

export function Footer() {
    return (
        <footer className="border-t border-outline py-12">
            <Container className="flex flex-col gap-8 sm:flex-row sm:items-start sm:justify-between">
                <div className="max-w-sm">
                    <div className="flex items-center gap-3">
                        <BrandMark className="size-7 text-sm"/>
                        <span className="text-base font-semibold tracking-wide">solenn</span>
                    </div>
                    <p className="mt-4 text-sm leading-relaxed text-muted">
                        Satire. Nothing is charged and nothing is collected.
                    </p>
                </div>

                <nav aria-label="Project links">
                    <ul className="flex flex-wrap gap-x-8 gap-y-3">
                        {LINKS.map((link) => (
                            <li key={link.label}>
                                <a
                                    href={link.href}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="text-sm font-medium text-muted transition-colors hover:text-foreground"
                                >
                                    {link.label}
                                </a>
                            </li>
                        ))}
                    </ul>
                </nav>
            </Container>

            <Container className="mt-10">
                <p className="text-sm text-muted">
                    © {site.year} {site.author}. Released under the AGPL-3.0 license.
                </p>
            </Container>
        </footer>
    );
}