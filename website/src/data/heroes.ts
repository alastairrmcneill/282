import type { ImageMetadata } from 'astro';

// Hero images are downloaded once by scripts/download-heroes.mjs and committed.
const modules = import.meta.glob<{ default: ImageMetadata }>('../assets/heroes/*.webp', {
  eager: true,
});

export function heroImage(slug: string): ImageMetadata | undefined {
  return modules[`../assets/heroes/${slug}.webp`]?.default;
}
