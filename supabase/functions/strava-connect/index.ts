import { encryptToken } from "../_shared/strava-crypto.ts";
import { serviceClient } from "../_shared/http.ts";

const CALLBACK_URL_SCHEME = "twoeightwo://strava-connect";
const REQUIRED_SCOPE = "activity:read";

function redirect(params: Record<string, string>) {
  return Response.redirect(`${CALLBACK_URL_SCHEME}?${new URLSearchParams(params)}`, 302);
}

function errorRedirect(message: string) {
  return redirect({ status: "error", message });
}

Deno.serve(async (req) => {
  const url = new URL(req.url);
  const code = url.searchParams.get("code");
  const state = url.searchParams.get("state");
  const grantedScope = url.searchParams.get("scope") ?? "";

  if (url.searchParams.get("error") === "access_denied") {
    return redirect({ status: "cancelled" });
  }
  if (!code || !state) {
    return errorRedirect("Missing authorization code. Please try again.");
  }

  const supabase = serviceClient();

  // Single use: the row is deleted as it is read, so a state can't be replayed.
  const { data: oauthState, error: stateError } = await supabase
    .from("strava_oauth_states")
    .delete()
    .eq("state", state)
    .gt("expires_at", new Date().toISOString())
    .select("user_id")
    .maybeSingle();
  if (stateError || !oauthState) {
    return errorRedirect("This Strava connection link has expired. Please try connecting again.");
  }
  const userId = oauthState.user_id as string;

  // Athletes can untick scopes on Strava's consent screen.
  const scopes = grantedScope.split(",").map((s) => s.trim());
  if (!scopes.includes(REQUIRED_SCOPE) && !scopes.includes("activity:read_all")) {
    return errorRedirect(
      "282 needs permission to view your activities to find your Munros. Please connect again and leave that box ticked.",
    );
  }

  const tokenRes = await fetch("https://www.strava.com/oauth/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: Deno.env.get("STRAVA_CLIENT_ID")!,
      client_secret: Deno.env.get("STRAVA_CLIENT_SECRET")!,
      code,
      grant_type: "authorization_code",
    }),
  });
  const tokens = await tokenRes.json();
  if (!tokenRes.ok || !tokens.access_token || !tokens.athlete?.id) {
    console.error("Strava token exchange failed:", tokenRes.status);
    return errorRedirect("Strava rejected the authorization request. Please try connecting again.");
  }

  const { error } = await supabase.from("strava_connections").upsert({
    user_id: userId,
    strava_athlete_id: tokens.athlete.id,
    access_token: await encryptToken(tokens.access_token),
    refresh_token: await encryptToken(tokens.refresh_token),
    token_expires_at: new Date(tokens.expires_at * 1000).toISOString(),
    scope: grantedScope || REQUIRED_SCOPE,
    connected_at: new Date().toISOString(),
    revoked_at: null,
  }, { onConflict: "user_id" });

  if (error) {
    console.error("strava_connections upsert failed:", error.code, error.message);
    if (error.code === "23505") {
      return errorRedirect(
        "This Strava account is already connected to a different 282 account. Disconnect it there first, or sign in with that account instead.",
      );
    }
    return errorRedirect("Something went wrong saving your Strava connection. Please try again.");
  }

  return redirect({ status: "success" });
});
