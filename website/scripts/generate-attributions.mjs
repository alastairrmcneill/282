// One-off: fetch author + licence for each munro hero image from the Wikimedia
// Commons API and write src/data/attributions.json (keyed by munro id).
// Usage: npm run generate:attributions
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { parse } from 'csv-parse/sync';

const root = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const repoRoot = path.dirname(root);
const outFile = path.join(root, 'src/data/attributions.json');

const munros = parse(fs.readFileSync(path.join(repoRoot, 'assets/munros.csv'), 'utf-8'), {
  columns: true,
  skip_empty_lines: true,
});

// .../commons/thumb/0/0d/<FILE>.jpg/1280px-<FILE>.jpg -> <FILE>.jpg (percent-encoded)
function fileNameFromUrl(url) {
  const match = url.match(/\/commons\/thumb\/[^/]+\/[^/]+\/([^/]+)\//);
  return match ? decodeURIComponent(match[1]) : null;
}

function stripHtml(html) {
  return html
    .replace(/<[^>]+>/g, '')
    .replace(/\s+/g, ' ')
    .trim();
}

const byFile = new Map(); // file name -> munro ids
for (const m of munros) {
  const file = fileNameFromUrl(m.hero_image_url);
  if (!file) {
    console.warn(`No Commons file parsed for munro ${m.id} (${m.name})`);
    continue;
  }
  if (!byFile.has(file)) byFile.set(file, []);
  byFile.get(file).push(m.id);
}

const files = [...byFile.keys()];
const attributions = {};

for (let i = 0; i < files.length; i += 50) {
  const batch = files.slice(i, i + 50);
  const titles = batch.map((f) => `File:${f}`).join('|');
  const url =
    'https://commons.wikimedia.org/w/api.php?action=query&format=json&prop=imageinfo' +
    '&iiprop=extmetadata&iiextmetadatafilter=Artist|LicenseShortName|LicenseUrl' +
    `&titles=${encodeURIComponent(titles)}`;
  let data;
  for (let attempt = 1; ; attempt++) {
    try {
      const res = await fetch(url, {
        headers: { 'User-Agent': '282app.uk website build (alastair.r.mcneill@gmail.com)' },
        signal: AbortSignal.timeout(30_000),
      });
      if (!res.ok) throw new Error(`Commons API ${res.status}`);
      data = await res.json();
      break;
    } catch (err) {
      if (attempt >= 3) throw err;
      console.warn(`Retry ${attempt}: ${err.message}`);
      await new Promise((r) => setTimeout(r, 2000 * attempt));
    }
  }
  const normalized = new Map(
    (data.query?.normalized ?? []).map((n) => [n.to, n.from]),
  );
  for (const page of Object.values(data.query?.pages ?? {})) {
    const meta = page.imageinfo?.[0]?.extmetadata;
    if (!meta) continue;
    const originalTitle = normalized.get(page.title) ?? page.title;
    const file = originalTitle.replace(/^File:/, '');
    const ids = byFile.get(file) ?? [];
    for (const id of ids) {
      attributions[id] = {
        artist: meta.Artist ? stripHtml(meta.Artist.value) : undefined,
        license: meta.LicenseShortName?.value,
        licenseUrl: meta.LicenseUrl?.value,
        filePage: `https://commons.wikimedia.org/wiki/File:${encodeURIComponent(file.replace(/ /g, '_'))}`,
      };
    }
  }
  console.log(`Fetched metadata for ${Math.min(i + 50, files.length)}/${files.length} files`);
}

fs.writeFileSync(outFile, JSON.stringify(attributions, null, 2) + '\n');
const covered = Object.keys(attributions).length;
console.log(`Wrote ${outFile}: ${covered}/${munros.length} munros covered`);
