import { requireUser, UnauthorizedError } from "../_shared/firebase-auth.ts";
import { json, serviceClient } from "../_shared/http.ts";

// Only what matching needs. activity:read excludes activities the athlete has
// set to "Only You", so their privacy choice is respected [API Policy 7.1].
export const STRAVA_SCOPE = "activity:read";

function randomState(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(32));
  return btoa(String.fromCharCode(...bytes)).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
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
  const state = randomState();
  const { error } = await supabase.from("strava_oauth_states").insert({ state, user_id: userId });
  if (error) {
    console.error("strava_oauth_states insert failed:", error.message);
    return json({ error: "Could not start Strava connection" }, 500);
  }

  const redirectUri = Deno.env.get("STRAVA_REDIRECT_URI") ??
    `${Deno.env.get("SUPABASE_URL")}/functions/v1/strava-connect`;

  const url = new URL("https://www.strava.com/oauth/authorize");
  url.search = new URLSearchParams({
    client_id: Deno.env.get("STRAVA_CLIENT_ID")!,
    redirect_uri: redirectUri,
    response_type: "code",
    approval_prompt: "auto",
    scope: STRAVA_SCOPE,
    state,
  }).toString();

  return json({ url: url.toString() });
});
