import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";
import { StravaApiActivity } from "./strava-activity.ts";

export interface MatchingConfig {
  radius_m: number;
  elev_high_threshold_m: number;
  bounding_box: { sw_lng: number; sw_lat: number; ne_lng: number; ne_lat: number };
  candidate_types: string[];
}

export interface MunroPoint {
  id: number;
  lat: number;
  lng: number;
}

export interface MunroMatchResult {
  munroId: number;
  distanceM: number;
}

export async function loadMatchingInputs(supabase: SupabaseClient) {
  const [{ data: config, error: configError }, { data: munros, error: munrosError }] = await Promise.all([
    supabase.from("strava_matching_config").select("*").single(),
    supabase.from("munros").select("id, lat, lng"),
  ]);
  if (configError) throw configError;
  if (munrosError) throw munrosError;
  return { config: config as MatchingConfig, munros: munros as MunroPoint[] };
}

function decodePolyline(str: string): [number, number][] {
  let index = 0, lat = 0, lng = 0;
  const coords: [number, number][] = [];
  while (index < str.length) {
    let shift = 0, result = 0, byte;
    do {
      byte = str.charCodeAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);
    lat += (result & 1) ? ~(result >> 1) : (result >> 1);
    shift = 0;
    result = 0;
    do {
      byte = str.charCodeAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);
    lng += (result & 1) ? ~(result >> 1) : (result >> 1);
    coords.push([lat / 1e5, lng / 1e5]);
  }
  return coords;
}

function haversineM(lat1: number, lon1: number, lat2: number, lon2: number) {
  const R = 6371000, toRad = (d: number) => (d * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1), dLon = toRad(lon2 - lon1);
  const a = Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

/**
 * Cheap checks that need no route data. Used to skip activities before
 * decoding a polyline, and to decide whether a webhook event is worth an API call.
 */
export function isCandidateType(activityType: string, config: MatchingConfig) {
  return config.candidate_types.includes(activityType);
}

/** Matches an activity against all Munros. The route is decoded in memory only and never stored. */
export function matchActivity(
  activity: StravaApiActivity,
  munros: MunroPoint[],
  config: MatchingConfig,
): MunroMatchResult[] {
  if (activity.manual) return [];
  if (!isCandidateType(activity.sport_type ?? activity.type, config) && !isCandidateType(activity.type, config)) {
    return [];
  }

  const box = config.bounding_box;
  const inBox = (latlng?: [number, number] | [] | null) =>
    !!latlng && latlng.length === 2 &&
    latlng[0] >= box.sw_lat && latlng[0] <= box.ne_lat &&
    latlng[1] >= box.sw_lng && latlng[1] <= box.ne_lng;
  if (!inBox(activity.start_latlng) && !inBox(activity.end_latlng)) return [];
  if ((activity.elev_high ?? 0) < config.elev_high_threshold_m) return [];

  const encoded = activity.map?.polyline ?? activity.map?.summary_polyline;
  if (!encoded) return [];

  const points = decodePolyline(encoded);
  const matches: MunroMatchResult[] = [];
  for (const munro of munros) {
    let closest = Infinity;
    for (const [lat, lng] of points) {
      const d = haversineM(lat, lng, munro.lat, munro.lng);
      if (d < closest) closest = d;
      if (closest < config.radius_m) break;
    }
    if (closest < config.radius_m) {
      matches.push({ munroId: munro.id, distanceM: Math.round(closest) });
    }
  }
  return matches;
}
