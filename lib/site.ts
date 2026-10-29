/** GitHub repository of the project, as `owner/name`. */
const repo = "Darrylwin/solenn";

export const site = {
    name: "Solenn",
    tagline: "The calculator that is confidently wrong",
    description:
        "Solenn is a premium-looking calculator for Android and iOS that gives confidently wrong answers and asks you to subscribe. Satire, engineered like a real product.",
    url: process.env.NEXT_PUBLIC_SITE_URL ?? "http://localhost:3000",
    repo,
    repoUrl: `https://github.com/${repo}`,
    releasesUrl: `https://github.com/${repo}/releases`,
    docsUrl: `https://github.com/${repo}#readme`,
    licenseUrl: `https://github.com/${repo}/blob/main/LICENSE`,
    author: "DARCODE",
    year: 2026,
} as const;

/** Sections linked from the header. Each id is the id of its section. */
export const NAV = [
    {id: "how-it-works", label: "How it works"},
    {id: "the-lies", label: "The lies"},
    {id: "screens", label: "Screens"},
    {id: "plans", label: "Plans"},
    {id: "guarantees", label: "Guarantees"},
] as const;

export type NavItem = (typeof NAV)[number];