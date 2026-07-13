import fs from 'node:fs';
import { parse } from 'csv-parse/sync';

export interface Munro {
  id: number;
  name: string;
  extra: string;
  area: string;
  meters: number;
  feet: number;
  section: string;
  region: string;
  lat: number;
  lng: number;
  link: string;
  description: string;
  pictureUrl: string;
  startingPointUrl: string;
  heightRank: number;
  heroImageUrl: string;
  slug: string;
  /** Disambiguator for duplicate names, e.g. "Braemar" for An Socach (Braemar). Empty when the name is unique. */
  qualifier: string;
  /** Name with qualifier when needed: "An Socach (Braemar)" or plain "Ben Nevis". */
  displayName: string;
  areaSlug: string;
}

function slugify(text: string): string {
  return text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/['’]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

function titleCase(slug: string): string {
  return slug
    .split('-')
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(' ');
}

const csvPath = new URL('../../../assets/munros.csv', import.meta.url);
const records: Record<string, string>[] = parse(fs.readFileSync(csvPath, 'utf-8'), {
  columns: true,
  skip_empty_lines: true,
});

const nameCounts = new Map<string, number>();
for (const r of records) {
  nameCounts.set(r.name, (nameCounts.get(r.name) ?? 0) + 1);
}

export const munros: Munro[] = records.map((r) => {
  const slug = r.link.replace(/\/+$/, '').split('/').pop()!;
  const nameSlug = slugify(r.name);
  const isDuplicate = (nameCounts.get(r.name) ?? 0) > 1;
  let qualifier = '';
  if (isDuplicate) {
    qualifier = slug.startsWith(`${nameSlug}-`)
      ? titleCase(slug.slice(nameSlug.length + 1))
      : r.area;
  }
  return {
    id: Number(r.id),
    name: r.name,
    extra: r.extra ?? '',
    area: r.area,
    meters: Number(r.meters),
    feet: Number(r.feet),
    section: r.section,
    region: r.region,
    lat: Number(r.lat),
    lng: Number(r.lng),
    link: r.link,
    description: r.description,
    pictureUrl: r.picture_url,
    startingPointUrl: r.starting_point_url,
    heightRank: Number(r.height_rank),
    heroImageUrl: r.hero_image_url,
    slug,
    qualifier,
    displayName: qualifier ? `${r.name} (${qualifier})` : r.name,
    areaSlug: slugify(r.area),
  };
});

if (munros.length !== 282) {
  throw new Error(`Expected 282 munros in assets/munros.csv, found ${munros.length}`);
}
const slugSet = new Set(munros.map((m) => m.slug));
if (slugSet.size !== munros.length) {
  throw new Error('Duplicate munro slugs derived from the link field');
}

export const munrosBySlug = new Map(munros.map((m) => [m.slug, m]));

export interface Area {
  name: string;
  slug: string;
  munros: Munro[];
}

export const areas: Area[] = [...new Set(munros.map((m) => m.area))]
  .sort()
  .map((name) => ({
    name,
    slug: slugify(name),
    munros: munros
      .filter((m) => m.area === name)
      .sort((a, b) => a.name.localeCompare(b.name)),
  }));

export const areasBySlug = new Map(areas.map((a) => [a.slug, a]));

export const highestFirst = [...munros].sort((a, b) => a.heightRank - b.heightRank);
