import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";
import { decryptToken, encryptToken, isEncrypted } from "./strava-crypto.ts";

const REFRESH_BUFFER_SECONDS = 300;

export interface StoredStravaConnection {
  user_id: string;
  strava_athlete_id: number;
  access_token: string;
  refresh_token: string;
  token_expires_at: string;
}

export class StravaConnectionRevokedError extends Error {}

/** Returns a valid access token for this connection, refreshing via Strava if it's expired or close to it. */
export async function getValidAccessToken(
  supabase: SupabaseClient,
  conn: StoredStravaConnection,
): Promise<string> {
  const expiresAt = new Date(conn.token_expires_at).getTime();
  const legacyPlaintext = !isEncrypted(conn.access_token) || !isEncrypted(conn.refresh_token);

  if (expiresAt - Date.now() > REFRESH_BUFFER_SECONDS * 1000 && !legacyPlaintext) {
    return await decryptToken(conn.access_token);
  }

  const res = await fetch("https://www.strava.com/oauth/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: Deno.env.get("STRAVA_CLIENT_ID")!,
      client_secret: Deno.env.get("STRAVA_CLIENT_SECRET")!,
      grant_type: "refresh_token",
      refresh_token: await decryptToken(conn.refresh_token),
    }),
  });

  if (!res.ok) {
    // 400/401 here means the refresh token itself is no longer valid (athlete revoked access).
    if (res.status === 400 || res.status === 401) {
      throw new StravaConnectionRevokedError(`Strava token refresh rejected: ${res.status}`);
    }
    throw new Error(`Strava token refresh failed: ${res.status}`);
  }

  const tokens = await res.json();

  // Strava may or may not rotate the refresh token on each use, so always persist what comes back.
  const { error } = await supabase.from("strava_connections").update({
    access_token: await encryptToken(tokens.access_token),
    refresh_token: await encryptToken(tokens.refresh_token),
    token_expires_at: new Date(tokens.expires_at * 1000).toISOString(),
  }).eq("user_id", conn.user_id);
  if (error) throw error;

  return tokens.access_token;
}

/** Revokes this app's access for the athlete on Strava's side. Best effort. */
export async function deauthorizeAtStrava(accessToken: string): Promise<boolean> {
  try {
    const res = await fetch("https://www.strava.com/oauth/deauthorize", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({ access_token: accessToken }),
    });
    return res.ok;
  } catch (e) {
    console.error("Strava deauthorize request failed:", (e as Error).message);
    return false;
  }
}
