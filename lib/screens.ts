import {existsSync} from "node:fs";
import path from "node:path";

export type Screen = { src: string; title: string; alt: string };

// The seven screenshots of the app, in the order of the app's README. They are
// copied into public/screens (see the README of the site).
const SCREENS = [
    {
        file: "01-calculator.png",
        title: "Calculator",
        alt: "The calculator showing a confidently wrong result",
    },
    {
        file: "02-paywall.png",
        title: "Paywall",
        alt: "The paywall with three plans",
    },
    {
        file: "03-confirmation.png",
        title: "Checkout",
        alt: "The purchase confirmation sheet",
    },
    {
        file: "04-plus-active.png",
        title: "Plus active",
        alt: "The calculator once unlocked, with the PLUS badge",
    },
    {
        file: "05-history.png",
        title: "History",
        alt: "The calculation history sheet",
    },
    {
        file: "06-account.png",
        title: "Account",
        alt: "The account screen",
    },
    {
        file: "07-legal.png",
        title: "Terms",
        alt: "The terms of service",
    },
] as const;

/** The screenshots that exist on disk, so a missing file never breaks a page. */
export function getScreens(): Screen[] {
    const directory = path.join(process.cwd(), "public", "screens");

    return SCREENS.filter(({file}) => existsSync(path.join(directory, file))).map(
        ({file, title, alt}) => ({src: `/screens/${file}`, title, alt}),
    );
}