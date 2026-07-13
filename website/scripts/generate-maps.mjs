// One-off: generate a static map image per munro via the Mapbox Static Images API
// and commit the results. Token is read from config/prod.json (MAPBOX_TOKEN).
// Usage: npm run generate:maps [-- --force]
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { parse } from 'csv-parse/sync';
import sharp from 'sharp';

const root = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const repoRoot = path.dirname(root);
const outDir = path.join(root, 'public/static/maps');
fs.mkdirSync(outDir, { recursive: true });

const token = JSON.parse(fs.readFileSync(path.join(repoRoot, 'config/prod.json'), 'utf-8'))
  .MAPBOX_TOKEN;
if (!token) throw new Error('MAPBOX_TOKEN missing from config/prod.json');

const munros = parse(fs.readFileSync(path.join(repoRoot, 'assets/munros.csv'), 'utf-8'), {
  columns: true,
  skip_empty_lines: true,
});

const force = process.argv.includes('--force');
const CONCURRENCY = 6;
let done = 0;
let skipped = 0;

async function generate(munro) {
  const slug = munro.link.replace(/\/+$/, '').split('/').pop();
  const outFile = path.join(outDir, `${slug}.webp`);
  if (!force && fs.existsSync(outFile)) {
    skipped++;
    return;
  }
  const lng = Number(munro.lng).toFixed(5);
  const lat = Number(munro.lat).toFixed(5);
  const marker = `pin-l+10b981(${lng},${lat})`;
  const url =
    `https://api.mapbox.com/styles/v1/mapbox/outdoors-v12/static/` +
    `${marker}/${lng},${lat},10.5,0/640x400@2x?access_token=${token}`;
  let res;
  for (let attempt = 1; ; attempt++) {
    try {
      res = await fetch(url, { signal: AbortSignal.timeout(30_000) });
      if (!res.ok) {
        throw new Error(`Mapbox ${res.status} for ${slug}: ${await res.text()}`);
      }
      break;
    } catch (err) {
      if (attempt >= 3) throw err;
      console.warn(`Retry ${attempt} for ${slug}: ${err.message}`);
      await new Promise((r) => setTimeout(r, 2000 * attempt));
    }
  }
  const png = Buffer.from(await res.arrayBuffer());
  await sharp(png).webp({ quality: 78 }).toFile(outFile);
  done++;
  if (done % 25 === 0) console.log(`${done} maps generated…`);
}

const queue = [...munros];
await Promise.all(
  Array.from({ length: CONCURRENCY }, async () => {
    while (queue.length) {
      const munro = queue.shift();
      await generate(munro);
    }
  }),
);

console.log(`Done: ${done} generated, ${skipped} already existed, output: ${outDir}`);
