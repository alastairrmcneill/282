// Shared shape between strava-job-processor (writes strava_activities rows)
// and strava-scan-activities (returns the same shape to the client, unpersisted).

export interface StravaApiActivity {
  id: number;
  type: string;
  name: string;
  manual?: boolean;
  start_date_local: string;
  elapsed_time: number;
  distance: number;
  total_elevation_gain: number;
  elev_high: number;
  start_latlng?: [number, number] | null;
  end_latlng?: [number, number] | null;
  map?: { polyline?: string | null; summary_polyline?: string | null };
}

// Matches the strava_activities table columns (StravaActivityFields on the Dart side).
export interface StravaActivityRow {
  id: number;
  user_id: string;
  activity_type: string;
  name: string;
  start_date: string;
  duration_s: number;
  start_lat: number | null;
  start_lng: number | null;
  end_lat: number | null;
  end_lng: number | null;
  distance_m: number;
  elevation_gain_m: number;
  elev_high_m: number;
  polyline: string | null;
}

export function toStravaActivityRow(
  activity: StravaApiActivity,
  userId: string,
): StravaActivityRow {
  return {
    id: activity.id,
    user_id: userId,
    activity_type: activity.type,
    name: activity.name,
    start_date: activity.start_date_local,
    duration_s: activity.elapsed_time,
    start_lat: activity.start_latlng ? activity.start_latlng[0] : null,
    start_lng: activity.start_latlng ? activity.start_latlng[1] : null,
    end_lat: activity.end_latlng ? activity.end_latlng[0] : null,
    end_lng: activity.end_latlng ? activity.end_latlng[1] : null,
    distance_m: activity.distance,
    elevation_gain_m: activity.total_elevation_gain,
    elev_high_m: activity.elev_high,
    polyline: activity.map?.polyline ?? activity.map?.summary_polyline ?? null,
  };
}
