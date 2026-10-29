import type {Metadata, Viewport} from "next";
import {Manrope} from "next/font/google";

import {site} from "@/lib/site";

import "./globals.css";

const manrope = Manrope({
    subsets: ["latin"],
    variable: "--font-manrope",
    display: "swap",
});

export const metadata: Metadata = {
    metadataBase: new URL(site.url),
    title: {
        default: `${site.name}: ${site.tagline}`,
        template: `%s · ${site.name}`,
    },
    description: site.description,
    openGraph: {
        type: "website",
        siteName: site.name,
        title: `${site.name}: ${site.tagline}`,
        description: site.description,
    },
    twitter: {card: "summary"},
};

export const viewport: Viewport = {
    themeColor: "#000000",
    colorScheme: "dark",
};

export default function RootLayout({
                                       children,
                                   }: Readonly<{ children: React.ReactNode }>) {
    return (
        <html lang="en" className={manrope.variable}>
        <body className="bg-background font-sans text-foreground antialiased">
        <a
            href="#main"
            className="sr-only focus:not-sr-only focus:fixed focus:left-4 focus:top-4 focus:z-50 focus:rounded-full focus:bg-accent focus:px-4 focus:py-2 focus:font-bold focus:text-on-accent"
        >
            Skip to content
        </a>
        {children}
        </body>
        </html>
    );
}
