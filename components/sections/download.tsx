import {ButtonLink} from "@/components/ui/button-link";
import {Card} from "@/components/ui/card";
import {DownloadIcon} from "@/components/ui/icons";
import {Section} from "@/components/ui/section";
import {formatMegabytes, formatReleaseDate, otherFiles, primaryApk, type Release,} from "@/lib/release";
import {site} from "@/lib/site";

const BUILD_COMMANDS = [
    `git clone ${site.repoUrl}.git`,
    "cd solenn",
    "fvm install",
    "fvm flutter pub get",
    "fvm flutter run",
].join("\n");

export function Download({release}: { release: Release | null }) {
    return (
        <Section
            id="download"
            eyebrow="Download"
            title="Get Solenn"
            intro="Solenn is not on any store. It ships as an APK on GitHub, and builds for iOS from source."
        >
            <div className="grid gap-6 lg:grid-cols-2">
                <AndroidCard release={release}/>
                <SourceCard/>
            </div>
        </Section>
    );
}

function AndroidCard({release}: { release: Release | null }) {
    const apk = release ? primaryApk(release) : undefined;

    return (
        <Card className="flex flex-col">
            <h3 className="text-2xl font-semibold">Android</h3>

            {release && apk ? (
                <>
                    <p className="mt-2 text-muted">
                        Version {release.version} · {formatReleaseDate(release.publishedAt)}
                    </p>
                    <div className="mt-6">
                        <ButtonLink href={apk.url} newTab={false}>
                            <DownloadIcon/>
                            Download APK · {formatMegabytes(apk.size)}
                        </ButtonLink>
                    </div>

                    <ol className="mt-8 list-decimal space-y-2 pl-5 text-muted marker:text-accent">
                        <li>Open the downloaded file on your phone.</li>
                        <li>If Android asks, allow installing apps from this source.</li>
                        <li>
                            To check the file first, run{" "}
                            <code className="text-foreground">
                                sha256sum --check SHA256SUMS
                            </code>
                            .
                        </li>
                    </ol>

                    <OtherFiles release={release}/>
                </>
            ) : (
                <>
                    <p className="mt-2 text-muted">
                        The first release is on its way. Until then, you can build the app
                        yourself.
                    </p>
                    <div className="mt-6">
                        <ButtonLink href={site.releasesUrl} variant="secondary">
                            Watch the releases
                        </ButtonLink>
                    </div>
                </>
            )}
        </Card>
    );
}

function OtherFiles({release}: { release: Release }) {
    const files = otherFiles(release);
    if (files.length === 0) return null;

    return (
        <details className="mt-8 border-t border-outline pt-4">
            <summary className="cursor-pointer text-sm font-medium text-muted hover:text-foreground">
                Other files
            </summary>
            <ul className="mt-4 space-y-2 text-sm">
                {files.map(({asset, label}) => (
                    <li key={asset.name}>
                        <a
                            href={asset.url}
                            className="text-foreground underline decoration-outline underline-offset-4 hover:decoration-accent"
                        >
                            {label}
                        </a>{" "}
                        <span className="text-muted">({formatMegabytes(asset.size)})</span>
                    </li>
                ))}
            </ul>
        </details>
    );
}

function SourceCard() {
    return (
        <Card className="flex flex-col">
            <h3 className="text-2xl font-semibold">iOS and building from source</h3>
            <p className="mt-2 text-muted">
                There is no App Store build. Compile Solenn with Xcode and your own
                Apple team, or build the Android app yourself.
            </p>

            <pre
                tabIndex={0}
                aria-label="Build commands"
                className="mt-6 overflow-x-auto rounded-2xl bg-background p-4 text-sm leading-relaxed"
            >
        <code>{BUILD_COMMANDS}</code>
      </pre>

            <p className="mt-6 text-muted">
                Full instructions are in the{" "}
                <a
                    href={site.docsUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-foreground underline decoration-outline underline-offset-4 hover:decoration-accent"
                >
                    repository
                </a>
                .
            </p>
        </Card>
    );
}