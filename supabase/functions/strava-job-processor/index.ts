import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { getValidAccessToken } from "../_shared/strava-token.ts";
import { toStravaActivityRow } from "../_shared/strava-activity.ts";

function decodePolyline(str: string) {
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

function matchActivity(activity: any, munros: any[], config: any) {
  if (activity.manual) return [];
  if (!config.candidate_types.includes(activity.type)) return [];
  const [sLat, sLng] = activity.start_latlng ?? [];
  const [eLat, eLng] = activity.end_latlng ?? [];
  const box = config.bounding_box;
  const inBox = (lat: number, lng: number) =>
    lat >= box.sw_lat && lat <= box.ne_lat && lng >= box.sw_lng &&
    lng <= box.ne_lng;
  if (!(inBox(sLat, sLng) || inBox(eLat, eLng))) return [];
  if ((activity.elev_high ?? 0) < config.elev_high_threshold_m) return [];
  if (!activity.map?.polyline) return [];

  const points = decodePolyline(activity.map.polyline);
  const matches: { munroId: number; distanceM: number }[] = [];
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

Deno.serve(async () => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const { data: config, error: configError } = await supabase.from(
    "strava_matching_config",
  ).select(
    "*",
  ).single();
  if (configError) {
    console.error("🎯 ~ configError:", configError);
    return new Response("failed to load matching config", { status: 500 });
  }
  console.log("🎯 ~ config:", config);

  const { data: munros, error: munrosError } = await supabase.from("munros")
    .select(
      "id, lat, lng, meters",
    );
  if (munrosError) {
    console.error("🎯 ~ munrosError:", munrosError);
    return new Response("failed to load munros", { status: 500 });
  }
  console.log("🎯 ~ munros:", munros);

  const { data: jobs, error: jobsError } = await supabase.from("jobs")
    .select("*").eq("status", "queued").lte(
      "run_after",
      new Date().toISOString(),
    ).limit(5);
  if (jobsError) {
    console.error("🎯 ~ jobsError:", jobsError);
    return new Response("failed to load jobs", { status: 500 });
  }
  console.log("🎯 ~ jobs:", jobs);

  for (const job of jobs ?? []) {
    const { error: runningError } = await supabase.from("jobs").update({
      status: "running",
    }).eq("id", job.id);
    if (runningError) console.error("🎯 ~ runningError:", runningError);
    try {
      if (job.job_type === "strava_webhook_activity") {
        const event = job.payload;
        console.log("🎯 ~ event:", event);
        if (event.object_type !== "activity") {
          const { error } = await supabase.from("jobs").update({
            status: "done",
          }).eq(
            "id",
            job.id,
          );
          if (error) console.error("🎯 ~ error:", error);
          continue;
        }

        const { data: conn, error: connError } = await supabase.from(
          "strava_connections",
        )
          .select("*").eq("strava_athlete_id", event.owner_id).is(
            "revoked_at",
            null,
          ).single();
        if (connError) console.error("🎯 ~ connError:", connError);
        console.log("🎯 ~ conn:", conn);
        if (!conn) {
          const { error } = await supabase.from("jobs").update({
            status: "failed",
          }).eq(
            "id",
            job.id,
          );
          if (error) console.error("🎯 ~ error:", error);
          continue;
        }

        const token = await getValidAccessToken(supabase, conn); // refresh if needed
        const res = await fetch(
          `https://www.strava.com/api/v3/activities/${event.object_id}`,
          {
            headers: { Authorization: `Bearer ${token}` },
          },
        );
        console.log("🎯 ~ res:", res);
        const activity = await res.json();
        console.log("🎯 ~ activity:", activity);
        const matches = matchActivity(activity, munros!, config);
        console.log("🎯 ~ matches:", matches);

        const { error: activityError } = await supabase.from(
          "strava_activities",
        ).upsert(
          toStravaActivityRow(
            activity,
            conn.user_id,
            matches.length ? "matched" : "no_match",
          ),
        );
        if (activityError) throw activityError;

        for (const m of matches) {
          const { error: matchError } = await supabase.from("munro_matches")
            .upsert({
              user_id: conn.user_id,
              munro_id: m.munroId,
              strava_activity_id: activity.id,
              match_distance_m: m.distanceM,
            }, { onConflict: "user_id,munro_id,strava_activity_id" });
          if (matchError) throw matchError;
        }
      }

      const { error: doneError } = await supabase.from("jobs").update({
        status: "done",
      }).eq("id", job.id);
      if (doneError) throw doneError;
    } catch (e) {
      console.error("🎯 ~ error:", e);
      const { error: failError } = await supabase.from("jobs").update({
        status: "failed",
        attempts: job.attempts + 1,
        run_after: new Date(Date.now() + 60_000).toISOString(),
      }).eq("id", job.id);
      if (failError) console.error("🎯 ~ failError:", failError);
    }
  }

  return new Response("ok");
});
