import type { Munro } from '../data/munros';
import { APP_STORE_URL, PLAY_STORE_URL } from './branch';

export const SITE_URL = 'https://282app.uk';
export const SITE_NAME = '282';

export function munroTitle(m: Munro): string {
  return `${m.displayName} — Height, Map & Routes | 282 Munro Bagging App`;
}

export function munroDescription(m: Munro): string {
  return `${m.displayName} is a ${m.meters}m (${m.feet.toLocaleString()}ft) Munro in ${m.area}, Scotland — ranked ${m.heightRank} of 282 by height. Map, starting point and route info, and track your climb with the 282 app.`;
}

export function mountainJsonLd(m: Munro, imageUrl?: string) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Mountain',
    name: m.displayName,
    description: m.description,
    ...(imageUrl ? { image: imageUrl } : {}),
    geo: {
      '@type': 'GeoCoordinates',
      latitude: m.lat,
      longitude: m.lng,
      elevation: `${m.meters} m`,
    },
    containedInPlace: {
      '@type': 'Place',
      name: m.area,
      containedInPlace: { '@type': 'Country', name: 'Scotland' },
    },
    url: `${SITE_URL}/munros/${m.slug}`,
  };
}

export function breadcrumbJsonLd(crumbs: { name: string; path?: string }[]) {
  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: crumbs.map((c, i) => ({
      '@type': 'ListItem',
      position: i + 1,
      name: c.name,
      ...(c.path ? { item: `${SITE_URL}${c.path}` } : {}),
    })),
  };
}

export function mobileAppJsonLd() {
  return {
    '@context': 'https://schema.org',
    '@type': 'MobileApplication',
    name: '282: Munro Bagging',
    operatingSystem: 'iOS, Android',
    applicationCategory: 'SportsApplication',
    description:
      'Track your Munro bagging progress across all 282 Scottish Munros. Interactive map, summit log, photos, weather forecasts, achievements and a community of fellow baggers.',
    offers: { '@type': 'Offer', price: '0', priceCurrency: 'GBP' },
    installUrl: APP_STORE_URL,
    sameAs: [APP_STORE_URL, PLAY_STORE_URL],
  };
}

export function faqJsonLd(faqs: { question: string; answer: string }[]) {
  return {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: faqs.map((f) => ({
      '@type': 'Question',
      name: f.question,
      acceptedAnswer: { '@type': 'Answer', text: f.answer },
    })),
  };
}

export function articleJsonLd(opts: {
  title: string;
  description: string;
  path: string;
  publishDate: Date;
  imageUrl?: string;
}) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: opts.title,
    description: opts.description,
    datePublished: opts.publishDate.toISOString().slice(0, 10),
    ...(opts.imageUrl ? { image: opts.imageUrl } : {}),
    author: { '@type': 'Organization', name: '282', url: SITE_URL },
    publisher: { '@type': 'Organization', name: '282', url: SITE_URL },
    mainEntityOfPage: `${SITE_URL}${opts.path}`,
  };
}
