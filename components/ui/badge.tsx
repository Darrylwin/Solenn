import type {ReactNode} from "react";

import {cn} from "@/lib/cn";

export function Badge({
                          children,
                          variant = "outline",
                          className,
                      }: {
    children: ReactNode;
    variant?: "outline" | "solid";
    className?: string;
}) {
    return (
        <span
            className={cn(
                "inline-flex items-center rounded-full px-3 py-1 text-xs font-bold tracking-wider",
                variant === "solid"
                    ? "bg-accent text-on-accent"
                    : "border border-accent-muted bg-accent-muted/40 text-accent",
                className,
            )}
        >
      {children}
    </span>
    );
}