# 282app.uk — marketing & SEO website

Static Astro site for the 282 Munro bagging app. Generates a landing page, one SEO page
per Munro (282), 12 region pages and a set of guide articles from `../assets/munros.csv`
(single source of truth — the same dataset the app ships).

## Develop

```bash
npm install
npm run dev        # http://localhost:4321
npm run build      # outputs to dist/
npm run preview    # serve the built site locally
```

## Deploy (Firebase Hosting, prod project)

The repo-root `firebase.json` points hosting at `website/dist` and keeps the existing
`/images/**` → `imageProxy` rewrite.

**Automatic**: pushes to `main` that touch `website/**`, `firebase.json`, or
`assets/munros.csv` trigger [`.github/workflows/website_deploy.yml`](../.github/workflows/website_deploy.yml),
which builds and deploys to prod.

**Manual**:

```bash
npm run build
firebase deploy --only hosting -P prod          # live
firebase hosting:channel:deploy staging -P prod # preview channel
```

## Analytics

Set `PUBLIC_GA_ID` in `website/.env` (see `.env.example`). When unset, the site builds
with no analytics script and no cookie banner. Consent Mode v2 defaults to denied; the
banner grants `analytics_storage` on accept.

## Generated assets (committed)

- `public/static/maps/*.webp` — one Mapbox static map per Munro.
  Regenerate: `npm run generate:maps` (token read from `../config/prod.json`).
- `src/assets/heroes/*.webp` — one Wikimedia hero image per Munro, pre-downloaded so
  builds never hit Wikimedia's rate limits.
  Regenerate: `npm run download:heroes`.
- `src/data/attributions.json` — Wikimedia Commons author/licence per hero image,
  rendered as the photo credit on each Munro page.
  Regenerate: `npm run generate:attributions`.

Card thumbnails are fetched from the app's own Supabase storage at build time and
optimised by Astro automatically.

Run both again if `assets/munros.csv` changes (new/renamed Munros, new hero images).

## App screenshots

The landing page "See it in action" section shows placeholders. To replace: drop portrait
screenshots into `public/screenshots/` and swap the placeholder `<div>`s in
`src/pages/index.astro` for `<img>` tags.

## Branch deep links

CTA buttons use Branch long links built in `src/lib/branch.ts`. Munro pages pass
`$canonical_identifier=munro/<id>` + `munroId=<id>`, matching what the app reads in
`lib/repos/deep_link_repository.dart`. Desktop clicks fall back to the munro page itself.
