import Image from "next/image";

import {PhoneFrame} from "@/components/ui/phone-frame";
import {Section} from "@/components/ui/section";
import type {Screen} from "@/lib/screens";

// Screenshots are taken at the native resolution of the emulator (9:20).
const SCREEN_WIDTH = 1080;
const SCREEN_HEIGHT = 2400;

export function Screens({screens}: { screens: readonly Screen[] }) {
    if (screens.length === 0) return null;

    return (
        <Section
            id="screens"
            eyebrow="Screens"
            title="Dark, tactile, native"
            intro="One brand on both platforms, with each system’s own transitions, sheets and haptics."
        >
            <div
                role="region"
                aria-label="Screenshots, scroll sideways to see more"
                tabIndex={0}
                className="-mx-6 overflow-x-auto px-6 pb-6"
            >
                <ul className="flex snap-x snap-mandatory gap-6">
                    {screens.map((screen) => (
                        <li key={screen.src} className="w-56 shrink-0 snap-center">
                            <PhoneFrame>
                                <Image
                                    src={screen.src}
                                    alt={screen.alt}
                                    width={SCREEN_WIDTH}
                                    height={SCREEN_HEIGHT}
                                    sizes="224px"
                                    className="h-auto w-full"
                                />
                            </PhoneFrame>
                            <p className="mt-4 text-center text-sm font-medium text-muted">
                                {screen.title}
                            </p>
                        </li>
                    ))}
                </ul>
            </div>
        </Section>
    );
}