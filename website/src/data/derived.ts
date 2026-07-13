import { munros, type Munro } from './munros';

function haversineKm(a: Munro, b: Munro): number {
  const R = 6371;
  const dLat = ((b.lat - a.lat) * Math.PI) / 180;
  const dLng = ((b.lng - a.lng) * Math.PI) / 180;
  const sinLat = Math.sin(dLat / 2);
  const sinLng = Math.sin(dLng / 2);
  const h =
    sinLat * sinLat +
    Math.cos((a.lat * Math.PI) / 180) * Math.cos((b.lat * Math.PI) / 180) * sinLng * sinLng;
  return 2 * R * Math.asin(Math.sqrt(h));
}

/**
 * Munros commonly climbed together: same massif/group (`extra`) first,
 * then nearest neighbours in the same region, then nearest overall. Cap 6.
 */
export function nearbyMunros(munro: Munro, limit = 6): Munro[] {
  const others = munros.filter((m) => m.id !== munro.id);
  const byDistance = (a: Munro, b: Munro) => haversineKm(munro, a) - haversineKm(munro, b);

  const sameGroup = munro.extra
    ? others.filter((m) => m.extra === munro.extra).sort(byDistance)
    : [];
  const picked = new Set(sameGroup.map((m) => m.id));

  const sameRegion = others
    .filter((m) => !picked.has(m.id) && m.region === munro.region)
    .sort(byDistance);
  for (const m of sameRegion) picked.add(m.id);

  const rest = others.filter((m) => !picked.has(m.id)).sort(byDistance);

  return [...sameGroup, ...sameRegion, ...rest].slice(0, limit);
}
