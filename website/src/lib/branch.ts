import type { Munro } from '../data/munros';

const BRANCH_DOMAIN = 'https://282.app.link';
const SITE = 'https://282app.uk';

export const APP_STORE_URL = 'https://apps.apple.com/us/app/282/id6474512889';
export const PLAY_STORE_URL =
  'https://play.google.com/store/apps/details?id=com.alastairrmcneill.TwoEightTwo';
export const APP_STORE_ID = '6474512889';

/**
 * Branch "long link" — plain URL construction, no API call. The app's
 * DeepLinkRepository requires both `~canonical_identifier` starting with
 * "munro/" and a `munroId` custom data key (lib/repos/deep_link_repository.dart).
 */
export function munroBranchLink(munro: Munro): string {
  const params = new URLSearchParams({
    $canonical_identifier: `munro/${munro.id}`,
    munroId: String(munro.id),
    $desktop_url: `${SITE}/munros/${munro.slug}`,
    $og_title: `${munro.name} on 282`,
    '~channel': 'website',
    '~feature': 'munro_page',
  });
  return `${BRANCH_DOMAIN}/?${params.toString()}`;
}

export function appBranchLink(feature = 'landing'): string {
  const params = new URLSearchParams({
    $canonical_identifier: 'app',
    $desktop_url: SITE,
    '~channel': 'website',
    '~feature': feature,
  });
  return `${BRANCH_DOMAIN}/?${params.toString()}`;
}
