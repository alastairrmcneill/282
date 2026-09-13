import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CALLBACK_URL_SCHEME = "twoeightwo://strava-connect";

function errorRedirect(message: string) {
  const location = `${CALLBACK_URL_SCHEME}?status=error&message=${
    encodeURIComponent(message)
  }`;
  return Response.redirect(location, 302);
}

Deno.serve(async (req) => {
  const url = new URL(req.url);
  const code = url.searchParams.get("code");
  const userId = url.searchParams.get("state"); // see Part 6 re: signing this
  console.log("🎯 ~ code:", code);
  console.log("🎯 ~ userId:", userId);

  if (!code || !userId) {
    console.error("🎯 ~ missing code or userId:", { code, userId });
    return errorRedirect("Missing authorization code. Please try again.");
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
    console.error(
      "🎯 ~ Strava token exchange failed:",
      tokenRes.status,
      tokens,
    );
    return errorRedirect(
      "Strava rejected the authorization request. Please try connecting again.",
    );
  }
  console.log("🎯 ~ tokens.athlete.id:", tokens.athlete.id);
  console.log("🎯 ~ tokens.expires_at:", tokens.expires_at);

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
  const { error } = await supabase.from("strava_connections").upsert({
    user_id: userId,
    strava_athlete_id: tokens.athlete.id,
    access_token: tokens.access_token, // Vault-encrypt before storing, see Part 6
    refresh_token: tokens.refresh_token,
    token_expires_at: new Date(tokens.expires_at * 1000).toISOString(),
    scope: tokens.scope ?? "activity:read_all",
    revoked_at: null,
  }, { onConflict: "user_id" });

  if (error) {
    console.error("🎯 ~ strava_connections upsert failed:", error);
    if (error.code === "23505") {
      // strava_athlete_id is unique — this Strava account is already linked to a different 282 user
      return errorRedirect(
        "This Strava account is already connected to a different 282 account. Disconnect it there first, or sign in with that account instead.",
      );
    }
    return errorRedirect(
      "Something went wrong saving your Strava connection. Please try again.",
    );
  }

  // Historical backfill is now user-initiated (strava-scan-activities), not auto-triggered here.

  return Response.redirect(`${CALLBACK_URL_SCHEME}?status=success`, 302);
});
