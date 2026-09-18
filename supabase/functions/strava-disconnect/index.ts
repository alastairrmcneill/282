import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { requireUser, UnauthorizedError } from "../_shared/firebase-auth.ts";

Deno.serve(async (req) => {
  console.log("🎯 ~ Deno.serve ~ req:", req);

  let userId: string;
  try {
    userId = await requireUser(req);
    console.log("🎯 ~ userId:", userId);
  } catch (e) {
    if (e instanceof UnauthorizedError) {
      return new Response("Unauthorized", { status: 401 });
    }
    throw e;
  }

  const service = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
  const { data: conn } = await service.from("strava_connections").select("*")
    .eq("user_id", userId).single();
  console.log("🎯 ~ conn:", conn);
  if (!conn) return new Response("Not connected", { status: 404 });

  await fetch("https://www.strava.com/oauth/revoke", {
    method: "POST",
    headers: {
      Authorization: `Basic ${
        btoa(
          `${Deno.env.get("STRAVA_CLIENT_ID")}:${
            Deno.env.get("STRAVA_CLIENT_SECRET")
          }`,
        )
      }`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({ token: conn.refresh_token }),
  });
  await service.from("strava_connections").update({
    revoked_at: new Date().toISOString(),
  }).eq("user_id", userId);
  console.log("🎯 ~ strava_connections revoked for userId:", userId);
  return new Response(JSON.stringify({ ok: true }), {
    headers: { "Content-Type": "application/json" },
  });
});
