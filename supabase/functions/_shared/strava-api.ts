import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

export const STRAVA_API_BASE = "https://www.strava.com/api/v3";

// Stop making non-essential calls once either window is this full, leaving
// headroom for webhook-driven work and token refreshes.
const BACKOFF_THRESHOLD = 0.9;

export class StravaRateLimitError extends Error {
  constructor(public retryAt: Date) {
    super(`Strava rate limit reached, retry after ${retryAt.toISOString()}`);
  }
}

export class StravaNotFoundError extends Error {}

export class StravaUnauthorizedError extends Error {}

/** Start of the next 15-minute window (Strava resets at :00, :15, :30, :45 UTC). */
export function nextShortWindow(now = new Date()): Date {
  const next = new Date(now);
  next.setUTCSeconds(0, 0);
  next.setUTCMinutes(Math.floor(now.getUTCMinutes() / 15) * 15 + 15);
  return next;
}

function nextDailyWindow(now = new Date()): Date {
  const next = new Date(now);
  next.setUTCHours(24, 0, 0, 0);
  return next;
}

function parsePair(header: string | null): [number, number] | null {
  if (!header) return null;
  const [a, b] = header.split(",").map((v) => parseInt(v.trim(), 10));
  return Number.isFinite(a) && Number.isFinite(b) ? [a, b] : null;
}

async function recordUsage(
  supabase: SupabaseClient,
  res: Response,
  throttledUntil: Date | null,
) {
  const limit = parsePair(res.headers.get("X-RateLimit-Limit"));
  const usage = parsePair(res.headers.get("X-RateLimit-Usage"));
  const readLimit = parsePair(res.headers.get("X-ReadRateLimit-Limit"));
  const readUsage = parsePair(res.headers.get("X-ReadRateLimit-Usage"));
  if (!limit && !usage && !readLimit && !readUsage && !throttledUntil) return;

  const { error } = await supabase.from("strava_rate_limit_usage").upsert({
    id: 1,
    short_limit: limit?.[0] ?? null,
    daily_limit: limit?.[1] ?? null,
    short_usage: usage?.[0] ?? null,
    daily_usage: usage?.[1] ?? null,
    read_short_limit: readLimit?.[0] ?? null,
    read_daily_limit: readLimit?.[1] ?? null,
    read_short_usage: readUsage?.[0] ?? null,
    read_daily_usage: readUsage?.[1] ?? null,
    throttled_until: throttledUntil?.toISOString() ?? null,
    updated_at: new Date().toISOString(),
  });
  if (error) console.error("strava_rate_limit_usage upsert failed:", error.message);
}

/**
 * Returns when it is next safe to make non-essential Strava calls, or null if
 * it is safe now. Based on the last response headers we saw.
 */
export async function rateLimitBackoffUntil(
  supabase: SupabaseClient,
): Promise<Date | null> {
  const { data } = await supabase.from("strava_rate_limit_usage").select("*")
    .eq("id", 1).maybeSingle();
  if (!data) return null;

  const now = new Date();
  if (data.throttled_until && new Date(data.throttled_until) > now) {
    return new Date(data.throttled_until);
  }

  const updatedAt = new Date(data.updated_at);
  const sameShortWindow = nextShortWindow(updatedAt).getTime() === nextShortWindow(now).getTime();
  const sameDay = updatedAt.toISOString().slice(0, 10) === now.toISOString().slice(0, 10);

  const over = (usage: number | null, limit: number | null) =>
    usage != null && limit != null && limit > 0 && usage / limit >= BACKOFF_THRESHOLD;

  if (sameDay && (over(data.daily_usage, data.daily_limit) || over(data.read_daily_usage, data.read_daily_limit))) {
    return nextDailyWindow(now);
  }
  if (sameShortWindow && (over(data.short_usage, data.short_limit) || over(data.read_short_usage, data.read_short_limit))) {
    return nextShortWindow(now);
  }
  return null;
}

/**
 * GET a Strava API path with the athlete's access token. Records rate-limit
 * usage from every response and turns 401/404/429 into typed errors.
 */
export async function stravaGet<T>(
  supabase: SupabaseClient,
  path: string,
  accessToken: string,
): Promise<T> {
  const res = await fetch(`${STRAVA_API_BASE}${path}`, {
    headers: { Authorization: `Bearer ${accessToken}` },
  });

  if (res.status === 429) {
    const retryAt = nextShortWindow();
    await recordUsage(supabase, res, retryAt);
    throw new StravaRateLimitError(retryAt);
  }
  await recordUsage(supabase, res, null);

  if (res.status === 401) throw new StravaUnauthorizedError("Strava returned 401");
  if (res.status === 404) throw new StravaNotFoundError(`Strava returned 404 for ${path}`);
  if (!res.ok) throw new Error(`Strava request failed: ${res.status}`);
  return await res.json() as T;
}
