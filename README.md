# Solenn: the website

The presentation site of [Solenn](https://github.com/owner/solenn), the calculator that is confidently wrong. A single
page built with Next.js, TypeScript and Tailwind CSS.

This code lives on the **`site`** branch of the repository. It shares no history with the app, which lives on `main`.

## Branches

| Branch | Holds                                    |
|--------|------------------------------------------|
| `main` | The Flutter app, its CI and its releases |
| `site` | This website                             |

Work happens on short-lived branches cut from `site` (`feat/site-...`), merged into `site` by pull request. The
workflows of `main` do not run here: `.github/workflows/site.yml` does the job.

## Getting started

Requirements: Node.js 20.9 or newer.

```bash
npm install
cp .env.example .env.local
npm run dev
```

| Command             | Purpose                      |
|---------------------|------------------------------|
| `npm run dev`       | Development server           |
| `npm run lint`      | ESLint                       |
| `npm run typecheck` | TypeScript, without emitting |
| `npm run build`     | Production build             |
| `npm run start`     | Serve the production build   |

## Structure

```text
app/
├── layout.tsx            # font, metadata, skip link
├── page.tsx              # composes the page, resolves the release and screenshots
└── globals.css           # design tokens (@theme) and base styles
components/
├── layout/               # header, footer
├── sections/             # one file per section of the page
├── ui/                   # container, section, button, card, badge, phone frame, icons
└── calculator-mock.tsx   # static drawing of the calculator, used in the hero
lib/
├── site.ts               # name, links, navigation
├── release.ts            # latest GitHub release and download links
├── screens.ts            # screenshots found in public/screens
└── cn.ts                 # class name helper
public/screens/           # the app screenshots
```

The content of a section (steps, phases, plans, guarantees) is a constant at the top of its file. Plans and phases
mirror the app; if the app changes, update them by hand.

## Configuration

| Setting           | Where                     | Notes                                                                                                 |
|-------------------|---------------------------|-------------------------------------------------------------------------------------------------------|
| GitHub repository | `repo` in `lib/site.ts`   | Replace `owner`. Drives every link and the release lookup.                                            |
| Site URL          | `NEXT_PUBLIC_SITE_URL`    | Used for metadata.                                                                                    |
| GitHub token      | `GITHUB_TOKEN` (optional) | Raises the API rate limit (60 requests an hour without it). Also needed if the repository is private. |

## The download button

The site does not host the APK. A 40 MB binary per version would bloat the repository, go stale, and lose the signature
and provenance attestations of the release.

At build time, and again at most once an hour, `lib/release.ts` asks the GitHub API for the latest release and links the
`arm64-v8a` APK directly. Release files carry their version in their name, so a fixed `releases/latest/download/...` URL
would not work.

- **A release exists:** the main button downloads the APK, and the page lists the other files.
- **No release yet, or GitHub is unreachable:** the button goes to the download section, which says so and links to the
  releases page. The site never breaks because of the lookup.

## Screenshots

The page shows the seven screenshots of the app, named as in the app's README. They are not duplicated in the history of
`site` by hand; copy them from `main`:

```bash
git checkout main -- docs/design/screens
mkdir -p public/screens
cp docs/design/screens/*.png public/screens/
git rm -r --cached docs
rm -rf docs
```

Missing files are skipped: the gallery and its navigation link only appear when at least one screenshot exists. All
screenshots must be taken at the same resolution so the frames line up.

## Accessibility and performance

- Semantic landmarks and headings, a skip link, visible focus rings, and the same palette and contrast ratios as the
  app.
- No client-side JavaScript beyond what Next.js needs: navigation, the gallery and the download details use plain HTML
  and CSS.
- `prefers-reduced-motion` stops the floating phone and smooth scrolling.
- The hero mock is described as one image, so the joke (`36 × 4 = 414`) reaches screen readers.

## Deployment

The site is static with hourly revalidation, so it suits any Next.js host. On Vercel: import the repository, set *
*Production Branch** to `site`, and add the variables above.

## Maintenance

- Dependabot reads the configuration of the default branch only. Add an npm stream with `target-branch: site` to
  `.github/dependabot.yml` on `main`.
- Replace `app/favicon.ico` with the brand mark once the final artwork exists.