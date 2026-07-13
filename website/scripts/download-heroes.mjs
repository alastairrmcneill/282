// One-off: download each munro's Wikimedia hero image, recompress to webp and
// commit under src/assets/heroes/<slug>.webp so builds never fetch Wikimedia
// (their thumb server rate-limits bulk fetches with 429s).
// Usage: npm run download:heroes [-- --force]
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { parse } from 'csv-parse/sync';
import sharp from 'sharp';

const root = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const repoRoot = path.dirname(root);
const outDir = path.join(root, 'src/assets/heroes');
fs.mkdirSync(outDir, { recursive: true });

const munros = parse(fs.readFileSync(path.join(repoRoot, 'assets/munros.csv'), 'utf-8'), {
  columns: true,
  skip_empty_lines: true,
});

const force = process.argv.includes('--force');
const CONCURRENCY = 3;
let done = 0;
let skipped = 0;

async function download(munro) {
  const slug = munro.link.replace(/\/+$/, '').split('/').pop();
  const outFile = path.join(outDir, `${slug}.webp`);
  if (!force && fs.existsSync(outFile)) {
    skipped++;
    return;
  }
  for (let attempt = 1; ; attempt++) {
    try {
      const res = await fetch(munro.hero_image_url, {
        headers: { 'User-Agent': '282app.uk website build (alastair.r.mcneill@gmail.com)' },
        signal: AbortSignal.timeout(30_000),
      });
      if (res.status === 429) throw new Error('429 rate limited');
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const buf = Buffer.from(await res.arrayBuffer());
      await sharp(buf)
        .resize({ width: 1280, withoutEnlargement: true })
        .webp({ quality: 80 })
        .toFile(outFile);
      break;
    } catch (err) {
      if (attempt >= 5) throw new Error(`${slug}: ${err.message}`);
      const wait = err.message.includes('429') ? 10_000 * attempt : 2_000 * attempt;
      console.warn(`Retry ${attempt} for ${slug} in ${wait / 1000}s: ${err.message}`);
      await new Promise((r) => setTimeout(r, wait));
    }
  }
  done++;
  if (done % 25 === 0) console.log(`${done} heroes downloaded…`);
}

const queue = [...munros];
await Promise.all(
  Array.from({ length: CONCURRENCY }, async () => {
    while (queue.length) {
      await download(queue.shift());
    }
  }),
);

console.log(`Done: ${done} downloaded, ${skipped} already existed, output: ${outDir}`);
