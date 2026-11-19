// Run with: STRAVA_TOKEN_ENCRYPTION_KEY=$(openssl rand -base64 32) deno test --allow-env supabase/functions/_shared/strava_test.ts
import { assert, assertEquals, assertNotEquals } from "jsr:@std/assert@1";
import { decryptToken, encryptToken, isEncrypted } from "./strava-crypto.ts";
import { nextShortWindow } from "./strava-api.ts";
import { MatchingConfig, matchActivity } from "./strava-matching.ts";
import { StravaApiActivity, toStravaActivityRow, toStravaScanActivity } from "./strava-activity.ts";

function encodeValue(v: number): string {
  let n = Math.round(v * 1e5);
  n = n < 0 ? ~(n << 1) : n << 1;
  let out = "";
  while (n >= 0x20) {
    out += String.fromCharCode((0x20 | (n & 0x1f)) + 63);
    n >>= 5;
  }
  return out + String.fromCharCode(n + 63);
}

const config: MatchingConfig = {
  radius_m: 1000,
  elev_high_threshold_m: 850,
  bounding_box: { sw_lng: -10, sw_lat: 53, ne_lng: 0, ne_lat: 62 },
  candidate_types: ["Hike", "Walk"],
};

const benNevis = { id: 1, lat: 56.7969, lng: -5.0036 };
const elsewhere = { id: 2, lat: 57.5, lng: -4.0 };

function activity(overrides: Partial<StravaApiActivity> = {}): StravaApiActivity {
  return {
    id: 99,
    type: "Hike",
    name: "Big day",
    start_date: "2026-06-01T07:00:00Z",
    start_date_local: "2026-06-01T08:00:00Z",
    elapsed_time: 3600,
    distance: 16000,
    total_elevation_gain: 1300,
    elev_high: 1340,
    device_name: "Garmin Fenix 8",
    start_latlng: [56.8, -5.1],
    end_latlng: [56.8, -5.1],
    map: { summary_polyline: encodeValue(56.7969) + encodeValue(-5.0035) },
    ...overrides,
  };
}

Deno.test("tokens round-trip and use a fresh IV each time", async () => {
  const a = await encryptToken("secret-token");
  const b = await encryptToken("secret-token");
  assert(isEncrypted(a));
  assertNotEquals(a, b);
  assertEquals(await decryptToken(a), "secret-token");
});

Deno.test("legacy plaintext tokens are returned unchanged", async () => {
  assertEquals(await decryptToken("plain"), "plain");
  assertEquals(isEncrypted("plain"), false);
});

Deno.test("nextShortWindow rounds up to the next quarter hour", () => {
  assertEquals(nextShortWindow(new Date("2026-01-01T10:07:33Z")).toISOString(), "2026-01-01T10:15:00.000Z");
  assertEquals(nextShortWindow(new Date("2026-01-01T23:50:00Z")).toISOString(), "2026-01-02T00:00:00.000Z");
});

Deno.test("matches a Munro on the route", () => {
  assertEquals(matchActivity(activity(), [benNevis, elsewhere], config), [{ munroId: 1, distanceM: 6 }]);
});

Deno.test("skips manual, non-candidate, out-of-region and low activities", () => {
  assertEquals(matchActivity(activity({ manual: true }), [benNevis], config), []);
  assertEquals(matchActivity(activity({ type: "Ride" }), [benNevis], config), []);
  assertEquals(matchActivity(activity({ start_latlng: [40, 2], end_latlng: [] }), [benNevis], config), []);
  assertEquals(matchActivity(activity({ elev_high: 300 }), [benNevis], config), []);
});

Deno.test("stored and returned rows never contain location data", () => {
  const row = toStravaActivityRow(activity(), "user1") as unknown as Record<string, unknown>;
  const scan = toStravaScanActivity(activity()) as unknown as Record<string, unknown>;
  for (const key of ["polyline", "start_latlng", "end_latlng", "map", "elev_high"]) {
    assertEquals(key in row, false);
    assertEquals(key in scan, false);
  }
  assertEquals(row.device_name, "Garmin Fenix 8");
  assert(new Date(row.expires_at as string).getTime() - Date.now() <= 7 * 24 * 3600 * 1000);
});
