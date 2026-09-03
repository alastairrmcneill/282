import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { getValidAccessToken } from "../_shared/strava-token.ts";
import { requireUser, UnauthorizedError } from "../_shared/firebase-auth.ts";
import {
  StravaActivityRow,
  toStravaActivityRow,
} from "../_shared/strava-activity.ts";

Deno.serve(async (req) => {
  console.log("🎯 ~ req:", req);

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

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const { data: conn } = await supabase.from("strava_connections")
    .select("*").eq("user_id", userId).is(
      "revoked_at",
      null,
    ).single();

  console.log("🎯 ~ conn:", conn);
  if (!conn) return new Response("Not connected", { status: 404 });

  // Get all activities for user, paginated
  const token = await getValidAccessToken(supabase, conn); // refresh if needed

  let page = 1;
  const userActivities: StravaActivityRow[] = [];
  let finished = false;
  while (!finished) {
    const res = await fetch(
      `https://www.strava.com/api/v3/athlete/activities?page=${page}&per_page=200`,
      {
        headers: { Authorization: `Bearer ${token}` },
      },
    );
    console.log("🎯 ~ res:", res);
    const activities = await res.json();

    console.log("🎯 ~ activities:", activities);
    userActivities.push(
      ...activities
        .filter((a: { manual?: boolean }) => !a.manual)
        .map((a: Parameters<typeof toStravaActivityRow>[0]) =>
          toStravaActivityRow(a, userId)
        ),
    );

    if (!activities.length) {
      finished = true;
      break;
    }
    page += 1;
  }

  console.log("🎯 ~ userActivities:", userActivities);

  return new Response(JSON.stringify(userActivities), {
    headers: { "Content-Type": "application/json" },
  });
});
