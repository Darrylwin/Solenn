import {cn} from "@/lib/cn";

/** Placeholder brand mark, like the one of the app: the initial on the accent. */
export function BrandMark({className}: { className?: string }) {
    return (
        <span
            aria-hidden="true"
            className={cn(
                "flex items-center justify-center rounded-full bg-accent font-bold text-on-accent",
                className,
            )}
        >
      S
    </span>
    );
}