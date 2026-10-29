import type {ReactNode} from "react";

import {cn} from "@/lib/cn";

export function Card({
                         children,
                         className,
                         highlighted = false,
                     }: {
    children: ReactNode;
    className?: string;
    highlighted?: boolean;
}) {
    return (
        <div
            className={cn(
                "rounded-3xl border bg-surface p-6",
                highlighted ? "border-accent" : "border-outline",
                className,
            )}
        >
            {children}
        </div>
    );
}
