// @ts-check
import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  site: 'https://282app.uk',
  trailingSlash: 'never',
  build: {
    format: 'file',
  },
  integrations: [sitemap()],
  image: {
    domains: ['upload.wikimedia.org', 'bzzdszqqstspbzyclwxh.supabase.co'],
  },
  vite: {
    plugins: [tailwindcss()],
  },
});
