import {cacheLife, cacheTag} from "next/cache";
import {site} from "@/lib/site";

export type ReleaseAsset = { name: string; url: string; size: number };

export type Release = {
    version: string;
    publishedAt: string;
    url: string;
    assets: ReleaseAsset[];
};

export type DownloadTarget = { href: string; label: string; newTab: boolean };

export const RELEASE_CACHE_TAG = "latest-release";

const API_URL = `https://api.github.com/repos/${site.repo}/releases/latest`;
const PRIMARY_APK_SUFFIX = "-android-arm64-v8a.apk";
const BYTES_PER_MEGABYTE = 1024 * 1024;

// Known release files, in display order. The names come from the release
// workflow of the app (solenn-<version>-android-<abi>.apk, and so on).
const ASSET_LABELS: ReadonlyArray<{ suffix: string; label: string }> = [
    {suffix: PRIMARY_APK_SUFFIX, label: "Android APK · arm64 (most phones)"},
    {
        suffix: "-android-armeabi-v7a.apk",
        label: "Android APK · armeabi-v7a (older 32-bit phones)",
    },
    {suffix: "-android-x86_64.apk", label: "Android APK · x86_64 (emulators)"},
    {suffix: "-android.aab", label: "Android app bundle"},
    {suffix: "-symbols.zip", label: "Debug symbols"},
    {suffix: "SHA256SUMS", label: "SHA-256 checksums"},
];

function isRecord(value: unknown): value is Record<string, unknown> {
    return typeof value === "object" && value !== null;
}

function parseAsset(value: unknown): ReleaseAsset | null {
    if (!isRecord(value)) return null;
    const {name, browser_download_url: url, size} = value;
    if (typeof name !== "string") return null;
    if (typeof url !== "string") return null;
    if (typeof size !== "number") return null;
    return {name, url, size};
}

function parseRelease(value: unknown): Release | null {
    if (!isRecord(value)) return null;
    const {tag_name: tag, html_url: url, published_at: date, assets} = value;
    if (typeof tag !== "string" || typeof url !== "string") return null;
    if (typeof date !== "string" || !Array.isArray(assets)) return null;

    return {
        version: tag.replace(/^v/, ""),
        url,
        publishedAt: date,
        assets: assets.flatMap((asset) => {
            const parsed = parseAsset(asset);
            return parsed ? [parsed] : [];
        }),
    };
}

/**
 * Cached lookup. It throws on any failure on purpose: a rejected call is never
 * stored, so a transient GitHub error cannot freeze the page without a release
 * until the entry expires.
 */
async function fetchLatestRelease(): Promise<Release | null> {
    "use cache";
    cacheLife({stale: 300, revalidate: 3600, expire: 86400});
    cacheTag(RELEASE_CACHE_TAG);

    const token = process.env.GITHUB_TOKEN;
    const response = await fetch(API_URL, {
        headers: {
            Accept: "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
            ...(token ? {Authorization: `Bearer ${token}`} : {}),
        },
    });

    // No release published yet: a legitimate state, safe to cache.
    if (response.status === 404) return null;
    if (!response.ok) {
        throw new Error(`GitHub releases API responded ${response.status}`);
    }
    return parseRelease(await response.json());
}

/**
 * The latest published release, or `null` when there is none or GitHub cannot
 * be reached. The page then falls back to the releases page, so the site
 * never breaks because of this lookup.
 */
export async function getLatestRelease(): Promise<Release | null> {
    try {
        return await fetchLatestRelease();
    } catch {
        return null;
    }
}

/** The APK that suits most phones. */
export function primaryApk(release: Release): ReleaseAsset | undefined {
    return release.assets.find((asset) => asset.name.endsWith(PRIMARY_APK_SUFFIX));
}

/** Where the main download button goes. */
export function resolveDownload(release: Release | null): DownloadTarget {
    const apk = release ? primaryApk(release) : undefined;
    return apk
        ? {href: apk.url, label: "Download for Android", newTab: false}
        : {href: "#download", label: "Download for Android", newTab: false};
}

export type DownloadFile = { asset: ReleaseAsset; label: string };

/** Every file of the release except the main APK, in display order. */
export function otherFiles(release: Release): DownloadFile[] {
    const rank = (name: string) => {
        const index = ASSET_LABELS.findIndex(({suffix}) => name.endsWith(suffix));
        return index === -1 ? ASSET_LABELS.length : index;
    };

    return release.assets
        .filter((asset) => !asset.name.endsWith(PRIMARY_APK_SUFFIX))
        .sort((a, b) => rank(a.name) - rank(b.name))
        .map((asset) => ({
            asset,
            label:
                ASSET_LABELS.find(({suffix}) => asset.name.endsWith(suffix))?.label ??
                asset.name,
        }));
}

export function formatMegabytes(bytes: number): string {
    return `${(bytes / BYTES_PER_MEGABYTE).toFixed(1)} MB`;
}

export function formatReleaseDate(iso: string): string {
    return new Date(iso).toLocaleDateString("en-US", {
        year: "numeric",
        month: "long",
        day: "numeric",
        timeZone: "UTC",
    });
}