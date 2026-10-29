import type {ReactNode} from "react";

import {cn} from "@/lib/cn";

type ButtonLinkProps = {
    href: string;
    children: ReactNode;
    variant?: "primary" | "secondary";
    size?: "md" | "sm";
    /** Opens in a new tab. Defaults to true for absolute URLs. */
    newTab?: boolean;
    className?: string;
};

const VARIANTS = {
    primary: "bg-accent text-on-accent hover:bg-accent/90",
    secondary: "border border-outline text-foreground hover:bg-surface",
} as const;

const SIZES = {
    md: "h-14 px-8 text-base",
    sm: "h-10 px-5 text-sm",
} as const;

export function ButtonLink({
                               href,
                               children,
                               variant = "primary",
                               size = "md",
                               newTab = href.startsWith("http"),
                               className,
                           }: ButtonLinkProps) {
    return (
        <a
            href={href}
            {...(newTab ? {target: "_blank", rel: "noopener noreferrer"} : {})}
            className={cn(
                "inline-flex items-center justify-center gap-2 rounded-full font-bold transition-colors",
                VARIANTS[variant],
                SIZES[size],
                className,
            )}
        >
            {children}
        </a>
    );
}