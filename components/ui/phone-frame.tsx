import type {ReactNode} from "react";

import {cn} from "@/lib/cn";

/** A neutral phone bezel around a screenshot or a mock. */
export function PhoneFrame({
                               children,
                               className,
                           }: {
    children: ReactNode;
    className?: string;
}) {
    return (
        <div
            className={cn(
                "rounded-[2.75rem] border border-outline bg-black p-2 shadow-[0_30px_80px_-30px_rgba(228,255,79,0.18)]",
                className,
            )}
        >
            <div className="overflow-hidden rounded-[2.25rem]">{children}</div>
        </div>
    );
}