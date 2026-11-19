import { requireUser, UnauthorizedError } from "../_shared/firebase-auth.ts";
import { json, serviceClient } from "../_shared/http.ts";
import {
  rateLimitBackoffUntil,
  StravaRateLimitError,
  StravaUnauthorizedError,
  stravaGet,
} from "../_shared/strava-api.ts";
import { StravaApiActivity, StravaScanActivity, toStravaScanActivity } from "../_shared/strava-activity.ts";
import { loadMatchingInputs, matchActivity } from "../_shared/strava-matching.ts";
import { getValidAccessToken, StravaConnectionRevokedError } from "../_shared/strava-token.ts";
import { deleteStravaDataForUser } from "../_shared/strava-deletion.ts";

// One-off backfill of an athlete's history. Matching runs here, in memory, so
// routes never leave the server and nothing from the scan is persisted
// [API Policy 5.5, 5.7, 6.2]. Pages are fetched one at a time and the scan is
// limited to once per day per athlete to keep API usage proportionate.

const PER_PAGE = 200;
const MAX_PAGES = 25;
const SCAN_COOLDOWN_MS = 24 * 60 * 60 * 1000;

interface ScanMatch {
  munro_id: number;
  activity: StravaScanActivity;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return new Response("Method Not Allowed", { status: 405 });

  let userId: string;
  try {
    userId = await requireUser(req);
  } catch (e) {
    if (e instanceof UnauthorizedError) return new Response("Unauthorized", { status: 401 });
    throw e;
  }

  const supabase = serviceClient();

  const { data: conn } = await supabase.from("strava_connections")
    .select("user_id, strava_athlete_id, access_token, refresh_token, token_expires_at, last_historical_scan_at")
    .eq("user_id", userId).is("revoked_at", null).maybeSingle();
  if (!conn) return json({ error: "not_connected" }, 404);

  if (conn.last_historical_scan_at) {
    const nextAllowed = new Date(conn.last_historical_scan_at).getTime() + SCAN_COOLDOWN_MS;
    if (nextAllowed > Date.now()) {
      return json({ error: "scan_cooldown", retry_after: new Date(nextAllowed).toISOString() }, 429);
    }
  }

  const backoffUntil = await rateLimitBackoffUntil(supabase);
  if (backoffUntil) {
    return json({ error: "rate_limited", retry_after: backoffUntil.toISOString() }, 503);
  }

  let token: string;
  try {
    token = await getValidAccessToken(supabase, conn);
  } catch (e) {
    if (e instanceof StravaConnectionRevokedError) {
      await deleteStravaDataForUser(supabase, userId, "strava_deauthorization");
      return json({ error: "not_connected" }, 404);
    }
    throw e;
  }

  const { config, munros } = await loadMatchingInputs(supabase);

  const matches: ScanMatch[] = [];
  let activitiesScanned = 0;
  let complete = false;

  try {
    for (let page = 1; page <= MAX_PAGES; page++) {
      const activities = await stravaGet<StravaApiActivity[]>(
        supabase,
        `/athlete/activities?page=${page}&per_page=${PER_PAGE}`,
        token,
      );
      for (const activity of activities) {
        activitiesScanned++;
        for (const m of matchActivity(activity, munros, config)) {
          matches.push({ munro_id: m.munroId, activity: toStravaScanActivity(activity) });
        }
      }
      if (activities.length < PER_PAGE) {
        complete = true;
        break;
      }
    }
  } catch (e) {
    if (e instanceof StravaUnauthorizedError) {
      await deleteStravaDataForUser(supabase, userId, "strava_deauthorization");
      return json({ error: "not_connected" }, 404);
    }
    if (!(e instanceof StravaRateLimitError)) throw e;
    // Return what we have; the client tells the user the scan was partial.
  }

  await supabase.from("strava_connections")
    .update({ last_historical_scan_at: new Date().toISOString() })
    .eq("user_id", userId);

  return json({ activities_scanned: activitiesScanned, complete, matches });
});
