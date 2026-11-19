import { requireUser, UnauthorizedError } from "../_shared/firebase-auth.ts";
import { json, serviceClient } from "../_shared/http.ts";
import { deauthorizeAtStrava, getValidAccessToken } from "../_shared/strava-token.ts";
import { deleteStravaDataForUser } from "../_shared/strava-deletion.ts";

// Disconnecting revokes access on Strava's side and permanently deletes all
// Strava Data we hold for the user, then returns a confirmation the app shows
// to the user [API Policy 2.5, 7.4].
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
    .select("user_id, strava_athlete_id, access_token, refresh_token, token_expires_at")
    .eq("user_id", userId).maybeSingle();

  let stravaAccessRevoked = false;
  if (conn) {
    try {
      const token = await getValidAccessToken(supabase, conn);
      stravaAccessRevoked = await deauthorizeAtStrava(token);
    } catch (e) {
      // Already revoked on Strava's side; nothing to revoke, but we still delete.
      console.error("Could not obtain token to deauthorize:", (e as Error).message);
    }
  }

  try {
    const result = await deleteStravaDataForUser(supabase, userId, "user_disconnect");
    return json({ ...result, strava_access_revoked: stravaAccessRevoked });
  } catch (e) {
    console.error("Strava data deletion failed:", (e as Error).message);
    return json({ error: "Deletion failed" }, 500);
  }
});
