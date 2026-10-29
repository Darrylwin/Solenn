import {cn} from "@/lib/cn";

type KeyKind = "digit" | "function" | "operator";
type Key = { label: string; kind: KeyKind };

const key = (label: string, kind: KeyKind): Key => ({label, kind});

const KEYS: readonly Key[] = [
    key("⌫", "function"), key("AC", "function"), key("%", "function"), key("÷", "operator"),
    key("7", "digit"), key("8", "digit"), key("9", "digit"), key("×", "operator"),
    key("4", "digit"), key("5", "digit"), key("6", "digit"), key("−", "operator"),
    key("1", "digit"), key("2", "digit"), key("3", "digit"), key("+", "operator"),
    key("+/−", "digit"), key("0", "digit"), key(".", "digit"), key("=", "operator"),
];

const KEY_STYLES: Record<KeyKind, string> = {
    digit: "bg-linear-to-br from-key-top to-key-bottom text-foreground",
    function: "bg-key-function text-foreground",
    operator: "bg-accent text-on-accent",
};

/**
 * A static drawing of the calculator, so the hero needs no screenshot.
 * It shows the joke: 36 × 4 is 144, and Solenn says 414. The drawing is
 * described as one image for screen readers.
 */
export function CalculatorMock() {
    return (
        <div
            role="img"
            aria-label="The Solenn calculator showing that 36 times 4 equals 414"
            className="select-none bg-black p-4"
        >
            <div aria-hidden="true">
                <div className="relative h-40 rounded-3xl bg-surface p-4">
                    <p className="flex items-center gap-1.5 text-[11px] font-medium text-muted">
                        <span className="text-accent">✓</span>
                        Verified · 99.9% accuracy
                    </p>
                    <div className="absolute inset-x-4 bottom-4 text-right">
                        <p className="text-lg font-light text-muted">
                            36 <span className="text-accent">×</span> 4
                        </p>
                        <p className="text-6xl font-light leading-none tracking-tighter tabular-nums">
                            414
                        </p>
                    </div>
                </div>

                <div className="mt-4 grid grid-cols-4 gap-2.5">
                    {KEYS.map(({label, kind}) => (
                        <div
                            key={label}
                            className={cn(
                                "flex aspect-square items-center justify-center rounded-full font-light",
                                label.length > 1 ? "text-base" : "text-2xl",
                                KEY_STYLES[kind],
                            )}
                        >
                            {label}
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
}