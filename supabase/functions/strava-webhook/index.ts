import { json, safeEqual, serviceClient } from "../_shared/http.ts";
import { deleteStravaDataForUser } from "../_shared/strava-deletion.ts";

const VERIFY_TOKEN = Deno.env.get("STRAVA_VERIFY_TOKEN");
const SUBSCRIPTION_ID = Deno.env.get("STRAVA_SUBSCRIPTION_ID");

interface StravaWebhookEvent {
  object_type: "activity" | "athlete";
  object_id: number;
  aspect_type: "create" | "update" | "delete";
  owner_id: number;
  subscription_id: number;
  event_time: number;
  updates?: Record<string, string>;
}

function isEvent(body: unknown): body is StravaWebhookEvent {
  const e = body as StravaWebhookEvent;
  return !!e && typeof e.object_id === "number" && typeof e.owner_id === "number" &&
    typeof e.event_time === "number" &&
    (e.object_type === "activity" || e.object_type === "athlete") &&
    ["create", "update", "delete"].includes(e.aspect_type);
}

async function handleEvent(event: StravaWebhookEvent) {
  const supabase = serviceClient();

  // Strava retries deliveries that time out; only act on each event once.
  const { error: dupError } = await supabase.from("strava_webhook_events_processed").insert({
    object_type: event.object_type,
    object_id: event.object_id,
    aspect_type: event.aspect_type,
    event_time: event.event_time,
  });
  if (dupError) {
    if (dupError.code !== "23505") console.error("Idempotency insert failed:", dupError.message);
    return;
  }

  const { data: conn } = await supabase.from("strava_connections")
    .select("user_id").eq("strava_athlete_id", event.owner_id).is("revoked_at", null).maybeSingle();

  // Athlete revoked access from Strava's side, or deleted their Strava account [API Policy 7.4].
  if (event.object_type === "athlete") {
    if (event.updates?.authorized === "false" && conn) {
      await deleteStravaDataForUser(supabase, conn.user_id, "strava_deauthorization");
    }
    return;
  }

  // Activity deleted, or made private (we only hold activity:read) [API Policy 6.3, 7.1].
  if (event.aspect_type === "delete" || event.updates?.private === "true") {
    await supabase.from("strava_activities").delete().eq("id", event.object_id);
    await supabase.from("jobs").delete()
      .eq("job_type", "strava_webhook_activity")
      .eq("status", "queued")
      .eq("payload->>object_id", String(event.object_id));
    return;
  }

  if (!conn) return;

  if (event.aspect_type === "update") {
    // Title changes carry the new value, so keep the cache in sync without an API call.
    if (event.updates?.title !== undefined) {
      await supabase.from("strava_activities").update({ name: event.updates.title })
        .eq("id", event.object_id);
    }
    // Only a change of type can change the match result; everything else is ignored.
    const needsRematch = event.updates?.type !== undefined || event.updates?.sport_type !== undefined;
    if (!needsRematch) return;
  }

  await supabase.from("jobs").insert({
    job_type: "strava_webhook_activity",
    payload: event,
  });
}

Deno.serve(async (req) => {
  const url = new URL(req.url);

  // Subscription validation handshake.
  if (req.method === "GET") {
    const mode = url.searchParams.get("hub.mode");
    const token = url.searchParams.get("hub.verify_token") ?? "";
    const challenge = url.searchParams.get("hub.challenge");
    if (!VERIFY_TOKEN) {
      console.error("STRAVA_VERIFY_TOKEN is not set");
      return new Response("Not configured", { status: 500 });
    }
    if (mode === "subscribe" && safeEqual(token, VERIFY_TOKEN)) {
      return json({ "hub.challenge": challenge });
    }
    return new Response("Forbidden", { status: 403 });
  }

  if (req.method === "POST") {
    let body: unknown;
    try {
      body = await req.json();
    } catch (_) {
      return new Response("Bad Request", { status: 400 });
    }

    // Strava expects a 200 within 2 seconds, otherwise it retries. Acknowledge
    // anything well-formed and do the (fast, DB-only) handling in the background.
    if (!isEvent(body)) return new Response("ok");
    if (SUBSCRIPTION_ID && String(body.subscription_id) !== SUBSCRIPTION_ID) {
      return new Response("ok");
    }

    const work = handleEvent(body).catch((e) =>
      console.error("Webhook handling failed:", (e as Error).message)
    );
    // deno-lint-ignore no-explicit-any
    const runtime = (globalThis as any).EdgeRuntime;
    if (runtime?.waitUntil) {
      runtime.waitUntil(work);
    } else {
      await work;
    }
    return new Response("ok");
  }

  return new Response("Method Not Allowed", { status: 405 });
});
