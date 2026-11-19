// Shape of the Strava activity fields we read. Location fields (polyline,
// latlng) are only ever used in memory for matching and are never stored or
// returned to the client [API Policy 5.7, 6.2].

export interface StravaApiActivity {
  id: number;
  type: string;
  sport_type?: string;
  name: string;
  manual?: boolean;
  private?: boolean;
  start_date: string;
  start_date_local: string;
  elapsed_time: number;
  distance: number;
  total_elevation_gain: number;
  elev_high?: number;
  device_name?: string | null;
  start_latlng?: [number, number] | [] | null;
  end_latlng?: [number, number] | [] | null;
  map?: { polyline?: string | null; summary_polyline?: string | null };
}

// Matches the strava_activities table (StravaActivityFields on the Dart side).
export interface StravaActivityRow {
  id: number;
  user_id: string;
  activity_type: string;
  name: string;
  start_date: string;
  duration_s: number;
  distance_m: number;
  elevation_gain_m: number;
  device_name: string | null;
  match_status: "matched";
  expires_at: string;
}

export const CACHE_TTL_MS = 7 * 24 * 60 * 60 * 1000;

export function toStravaActivityRow(
  activity: StravaApiActivity,
  userId: string,
): StravaActivityRow {
  return {
    id: activity.id,
    user_id: userId,
    activity_type: activity.sport_type ?? activity.type,
    name: activity.name,
    start_date: activity.start_date_local,
    duration_s: activity.elapsed_time,
    distance_m: activity.distance,
    elevation_gain_m: activity.total_elevation_gain,
    device_name: activity.device_name ?? null,
    match_status: "matched",
    expires_at: new Date(Date.now() + CACHE_TTL_MS).toISOString(),
  };
}

/** Summary returned to the client by the historical scan. Never persisted. */
export interface StravaScanActivity {
  id: number;
  activity_type: string;
  name: string;
  start_date: string;
  duration_s: number;
  distance_m: number;
  elevation_gain_m: number;
}

export function toStravaScanActivity(activity: StravaApiActivity): StravaScanActivity {
  return {
    id: activity.id,
    activity_type: activity.sport_type ?? activity.type,
    name: activity.name,
    start_date: activity.start_date_local,
    duration_s: activity.elapsed_time,
    distance_m: activity.distance,
    elevation_gain_m: activity.total_elevation_gain,
  };
}
