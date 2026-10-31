import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

const REFRESH_BUFFER_SECONDS = 300; // refresh 5 min before actual expiry, not exactly at it

/** Returns a valid access token for this connection, refreshing via Strava if it's expired or close to it. */
export async function getValidAccessToken(
    supabase: SupabaseClient,
    conn: any,
): Promise<string> {
    const expiresAt = new Date(conn.token_expires_at).getTime();
    const now = Date.now();

    if (expiresAt - now > REFRESH_BUFFER_SECONDS * 1000) {
        return conn.access_token; // still valid, no call needed
    }

    const res = await fetch("https://www.strava.com/oauth/token", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: new URLSearchParams({
            client_id: Deno.env.get("STRAVA_CLIENT_ID")!,
            client_secret: Deno.env.get("STRAVA_CLIENT_SECRET")!,
            grant_type: "refresh_token",
            refresh_token: conn.refresh_token,
        }),
    });

    if (!res.ok) {
        // Strava returns 400 here if the refresh token itself has been revoked —
        // that's a real "this connection is dead" signal, not a transient failure
        if (res.status === 400) {
            await supabase.from("strava_connections").update({
                revoked_at: new Date().toISOString(),
            }).eq("user_id", conn.user_id);
        }
        throw new Error(`Strava token refresh failed: ${res.status}`);
    }

    const tokens = await res.json();

    // Strava may or may not rotate the refresh token on each use — always persist whatever comes back
    await supabase.from("strava_connections").update({
        access_token: tokens.access_token,
        refresh_token: tokens.refresh_token,
        token_expires_at: new Date(tokens.expires_at * 1000).toISOString(),
    }).eq("user_id", conn.user_id);

    return tokens.access_token;
}
