import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// A shared secret only you and Strava know — pick any string, you'll reuse it in step 4
const VERIFY_TOKEN = Deno.env.get("STRAVA_VERIFY_TOKEN") ?? "STRAVA_TEST_TOKEN";

Deno.serve(async (req) => {
  const url = new URL(req.url);

  // Strava calls this with GET once, when the subscription is first created,
  // to prove you control this URL.
  if (req.method === "GET") {
    const mode = url.searchParams.get("hub.mode");
    const token = url.searchParams.get("hub.verify_token");
    const challenge = url.searchParams.get("hub.challenge");

    if (mode === "subscribe" && token === VERIFY_TOKEN) {
      return new Response(JSON.stringify({ "hub.challenge": challenge }), {
        headers: { "Content-Type": "application/json" },
      });
    }
    return new Response("Forbidden", { status: 403 });
  }

  // Strava calls this with POST every time a subscribed event happens.
  if (req.method === "POST") {
    const event = await req.json();
    console.log("Strava webhook event:", JSON.stringify(event));

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );
    await supabase.from("strava_webhook_events_test").insert({
      raw_event: event,
    });

    // Strava requires a fast 200 response
    return new Response("EVENT_RECEIVED", { status: 200 });
  }

  return new Response("Method Not Allowed", { status: 405 });
});
