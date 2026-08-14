import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
// A shared secret only you and Strava know — pick any string, you'll reuse it in step 4
const VERIFY_TOKEN = Deno.env.get("STRAVA_VERIFY_TOKEN") ?? "STRAVA_TEST_TOKEN";
console.log("🎯 ~ VERIFY_TOKEN:", VERIFY_TOKEN);

Deno.serve(async (req) => {
  const url = new URL(req.url);

  // Strava calls this with GET once, when the subscription is first created,
  // to prove you control this URL.
  if (req.method === "GET") {
    const mode = url.searchParams.get("hub.mode");
    const token = url.searchParams.get("hub.verify_token");
    const challenge = url.searchParams.get("hub.challenge");

    console.log("🎯 ~ mode:", mode);
    console.log("🎯 ~ token:", token);
    console.log("🎯 ~ challenge:", challenge);
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

    const stravaAthleteId = event.owner_id;

    const userId = await supabase.from("strava_connections").select("user_id")
      .eq("strava_athlete_id", stravaAthleteId).single();

    const userData = await supabase.from("users").select("*").eq(
      "id",
      userId.data?.user_id,
    ).single();

    const resendApiKey = Deno.env.get("RESEND_API_KEY");
    const notificationEmail = Deno.env.get("NOTIFICATION_EMAIL");
    const fromEmail = Deno.env.get("FROM_EMAIL") ?? "onboarding@resend.dev";
    console.log("🎯 ~ notificationEmail:", notificationEmail);
    console.log("🎯 ~ fromEmail:", fromEmail);

    if (!resendApiKey || !notificationEmail) {
      throw new Error(
        "RESEND_API_KEY or NOTIFICATION_EMAIL secret is not set",
      );
    }

    await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${resendApiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: `282 Feedback <${fromEmail}>`,
        to: [notificationEmail],
        subject: `New Strava activity`,
        html: JSON.stringify(userData),
      }),
    });

    // Strava requires a fast 200 response
    return new Response("EVENT_RECEIVED", { status: 200 });
  }

  return new Response("Method Not Allowed", { status: 405 });
});
