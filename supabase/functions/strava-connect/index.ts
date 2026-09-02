import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (req) => {
  const url = new URL(req.url);
  const code = url.searchParams.get("code");
  const userId = url.searchParams.get("state"); // see Part 6 re: signing this
  console.log("🎯 ~ code:", code);
  console.log("🎯 ~ userId:", userId);

  const tokenRes = await fetch("https://www.strava.com/oauth/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: Deno.env.get("STRAVA_CLIENT_ID")!,
      client_secret: Deno.env.get("STRAVA_CLIENT_SECRET")!,
      code: code!,
      grant_type: "authorization_code",
    }),
  });
  const tokens = await tokenRes.json();
  console.log("🎯 ~ tokens.athlete.id:", tokens.athlete?.id);
  console.log("🎯 ~ tokens.expires_at:", tokens.expires_at);

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
  await supabase.from("strava_connections").upsert({
    user_id: userId,
    strava_athlete_id: tokens.athlete.id,
    access_token: tokens.access_token, // Vault-encrypt before storing, see Part 6
    refresh_token: tokens.refresh_token,
    token_expires_at: new Date(tokens.expires_at * 1000).toISOString(),
    scope: tokens.scope ?? "activity:read_all",
    revoked_at: null,
  });

  // Historical backfill is now user-initiated (strava-scan-activities), not auto-triggered here.

  return new Response(
    "<h1>Connected to 282!</h1><p>You can close this and go back to the app.</p>",
    { headers: { "Content-Type": "text/html" } },
  );
});
