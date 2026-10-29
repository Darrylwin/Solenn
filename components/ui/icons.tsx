import {cn} from "@/lib/cn";

type IconProps = { className?: string };

function Icon({className, children}: IconProps & { children: React.ReactNode }) {
    return (
        <svg
            aria-hidden="true"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
            className={cn("size-5", className)}
        >
            {children}
        </svg>
    );
}

export function DownloadIcon({className}: IconProps) {
    return (
        <Icon className={className}>
            <path d="M12 3v12m0 0l-5-5m5 5l5-5M5 21h14"/>
        </Icon>
    );
}

export function CheckIcon({className}: IconProps) {
    return (
        <Icon className={className}>
            <path d="M5 12.5l4.5 4.5L19 7.5"/>
        </Icon>
    );
}