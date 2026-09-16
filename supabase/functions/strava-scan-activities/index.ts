import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { getValidAccessToken } from "../_shared/strava-token.ts";
import { requireUser, UnauthorizedError } from "../_shared/firebase-auth.ts";
import {
  StravaActivityRow,
  toStravaActivityRow,
} from "../_shared/strava-activity.ts";

const PER_PAGE = 200;
const PAGE_CONCURRENCY = 5; // pages fetched in parallel once we know there's more than one

Deno.serve(async (req) => {
  let userId: string;
  try {
    userId = await requireUser(req);
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
    .select("user_id, access_token, refresh_token, token_expires_at")
    .eq("user_id", userId).is("revoked_at", null).single();

  if (!conn) return new Response("Not connected", { status: 404 });

  const token = await getValidAccessToken(supabase, conn); // refresh if needed

  const fetchPage = async (page: number) => {
    const res = await fetch(
      `https://www.strava.com/api/v3/athlete/activities?page=${page}&per_page=${PER_PAGE}`,
      { headers: { Authorization: `Bearer ${token}` } },
    );
    return await res.json();
  };

  const toRows = (activities: { manual?: boolean }[]) =>
    activities
      .filter((a) => !a.manual)
      .map((a) =>
        toStravaActivityRow(
          a as Parameters<typeof toStravaActivityRow>[0],
          userId,
        )
      );

  // Most users only have one page — fetch it alone rather than always
  // burning a follow-up request just to confirm there's nothing more.
  const pages: StravaActivityRow[][] = [];
  const first = await fetchPage(1);
  pages.push(toRows(first));

  let page = 2;
  let done = first.length < PER_PAGE;
  while (!done) {
    const batch = await Promise.all(
      Array.from({ length: PAGE_CONCURRENCY }, (_, i) => fetchPage(page + i)),
    );
    for (const activities of batch) {
      pages.push(toRows(activities));
      if (activities.length < PER_PAGE) done = true;
    }
    page += PAGE_CONCURRENCY;
  }

  const userActivities = pages.flat();

  return new Response(JSON.stringify(userActivities), {
    headers: { "Content-Type": "application/json" },
  });
});
