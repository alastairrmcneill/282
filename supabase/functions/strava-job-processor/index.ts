import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { getValidAccessToken } from "../_shared/strava-token.ts";

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

  const { data: config } = await supabase.from("strava_matching_config").select(
    "*",
  ).single();
  console.log("🎯 ~ config:", config);
  const { data: munros } = await supabase.from("munros").select(
    "id, lat, lng, meters",
  );
  console.log("🎯 ~ munros:", munros);

  const { data: jobs } = await supabase.from("jobs")
    .select("*").eq("status", "queued").lte(
      "run_after",
      new Date().toISOString(),
    ).limit(5);
  console.log("🎯 ~ jobs:", jobs);

  for (const job of jobs ?? []) {
    await supabase.from("jobs").update({ status: "running" }).eq("id", job.id);
    try {
      if (job.job_type === "strava_webhook_activity") {
        const event = job.payload;
        console.log("🎯 ~ event:", event);
        if (event.object_type !== "activity") {
          await supabase.from("jobs").update({ status: "done" }).eq(
            "id",
            job.id,
          );
          continue;
        }

        const { data: conn } = await supabase.from("strava_connections")
          .select("*").eq("strava_athlete_id", event.owner_id).is(
            "revoked_at",
            null,
          ).single();
        console.log("🎯 ~ conn:", conn);
        if (!conn) {
          await supabase.from("jobs").update({ status: "failed" }).eq(
            "id",
            job.id,
          );
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

        await supabase.from("strava_activities").upsert({
          id: activity.id,
          user_id: conn.user_id,
          source: "webhook",
          activity_type: activity.type,
          name: activity.name,
          start_date: activity.start_date,
          distance_m: activity.distance,
          elevation_gain_m: activity.total_elevation_gain,
          elev_high_m: activity.elev_high,
          polyline: activity.map?.polyline,
          match_status: matches.length ? "matched" : "no_match",
        });
        for (const m of matches) {
          await supabase.from("munro_matches").upsert({
            user_id: conn.user_id,
            munro_id: m.munroId,
            strava_activity_id: activity.id,
            match_distance_m: m.distanceM,
          }, { onConflict: "user_id,munro_id,strava_activity_id" });
        }
      }

      if (job.job_type === "strava_historical_scan") {
        // Get user connection
        const { data: conn } = await supabase.from("strava_connections")
          .select("*").eq("user_id", job.payload.user_id).is(
            "revoked_at",
            null,
          ).single();
        console.log("🎯 ~ conn:", conn);

        if (!conn) {
          await supabase.from("jobs").update({ status: "failed" }).eq(
            "id",
            job.id,
          );
          continue;
        }

        await supabase.from("jobs").update({ status: "in_progress" }).eq(
          "id",
          job.id,
        );
        await supabase.from("strava_connections").update({
          historical_scan_status: "in_progress",
          historical_scan_progress: {
            total_activities: 0,
            activities_scanned: 0,
            munros_matched: 0,
          },
        }).eq("user_id", conn.user_id);

        // Get all activities for user, paginated
        const token = await getValidAccessToken(supabase, conn); // refresh if needed

        let page = job.payload.page ?? 1;
        const userActivities: any[] = [];
        let finished = false;
        while (!finished) {
          const res = await fetch(
            `https://www.strava.com/api/v3/athlete/activities?page=${page}&per_page=200`,
            {
              headers: { Authorization: `Bearer ${token}` },
            },
          );
          console.log("🎯 ~ res:", res);
          const activities = await res.json();

          console.log("🎯 ~ activities:", activities);
          userActivities.push(...activities);

          if (!activities.length) {
            finished = true;
            break;
          }
          page += 1;
        }

        // Store all activites in strava_activities table

        await supabase.from("strava_activities").upsert(
          userActivities.map((activity) => ({
            id: activity.id,
            user_id: conn.user_id,
            source: "historical",
            activity_type: activity.type,
            name: activity.name,
            start_date: activity.start_date,
            distance_m: activity.distance,
            elevation_gain_m: activity.total_elevation_gain,
            elev_high_m: activity.elev_high,
            polyline: activity.map?.polyline,
            match_status: "pending",
          })),
        );

        await supabase.from("strava_connections").update({
          historical_scan_status: "in_progress",
          historical_scan_progress: {
            total_activities: userActivities.length,
            activities_scanned: 0,
            munros_matched: 0,
          },
        }).eq("user_id", conn.user_id);

        // Scan activities for matches
        let totalMatches = 0;
        let scannedActivities = 0;

        for (const activity of userActivities) {
          const matches = matchActivity(activity, munros!, config);
          console.log("🎯 ~ matches:", matches);
          totalMatches += matches.length;
          scannedActivities += 1;

          await supabase.from("strava_activities").update({
            match_status: matches.length ? "matched" : "no_match",
          }).eq("id", activity.id);

          await supabase.from("munro_matches").upsert(
            matches.map((match) => ({
              user_id: conn.user_id,
              munro_id: match.munroId,
              strava_activity_id: activity.id,
              match_distance_m: match.distanceM,
            })),
          );
          await supabase.from("strava_connections").update({
            historical_scan_progress: {
              total_activities: userActivities.length,
              activities_scanned: scannedActivities,
              munros_matched: totalMatches,
            },
          }).eq("user_id", conn.user_id);
        }
      }

      await supabase.from("jobs").update({ status: "done" }).eq("id", job.id);
    } catch (e) {
      console.error("🎯 ~ error:", e);
      await supabase.from("jobs").update({
        status: "failed",
        attempts: job.attempts + 1,
        run_after: new Date(Date.now() + 60_000).toISOString(),
      }).eq("id", job.id);
    }
  }

  return new Response("ok");
});
