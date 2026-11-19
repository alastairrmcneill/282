import { json, safeEqual, serviceClient } from "../_shared/http.ts";
import {
  rateLimitBackoffUntil,
  StravaNotFoundError,
  StravaRateLimitError,
  StravaUnauthorizedError,
  stravaGet,
} from "../_shared/strava-api.ts";
import { StravaApiActivity, toStravaActivityRow } from "../_shared/strava-activity.ts";
import { loadMatchingInputs, matchActivity } from "../_shared/strava-matching.ts";
import { getValidAccessToken, StravaConnectionRevokedError } from "../_shared/strava-token.ts";
import { deleteStravaDataForUser } from "../_shared/strava-deletion.ts";

const JOB_BATCH_SIZE = 10;
const MAX_ATTEMPTS = 5;

Deno.serve(async (req) => {
  const secret = Deno.env.get("STRAVA_JOB_PROCESSOR_SECRET");
  const provided = req.headers.get("x-job-processor-secret") ?? "";
  if (!secret || !safeEqual(provided, secret)) {
    return new Response("Unauthorized", { status: 401 });
  }

  const supabase = serviceClient();

  const backoffUntil = await rateLimitBackoffUntil(supabase);
  if (backoffUntil) return json({ deferred_until: backoffUntil.toISOString() });

  const { data: jobs, error: jobsError } = await supabase.from("jobs")
    .select("*")
    .eq("status", "queued")
    .eq("job_type", "strava_webhook_activity")
    .lte("run_after", new Date().toISOString())
    .order("run_after")
    .limit(JOB_BATCH_SIZE);
  if (jobsError) {
    console.error("Failed to load jobs:", jobsError.message);
    return new Response("failed to load jobs", { status: 500 });
  }
  if (!jobs?.length) return json({ processed: 0 });

  const { config, munros } = await loadMatchingInputs(supabase);

  const setJob = (id: string, fields: Record<string, unknown>) =>
    supabase.from("jobs").update({ ...fields, updated_at: new Date().toISOString() }).eq("id", id);

  let processed = 0;
  for (const job of jobs) {
    // Claim atomically so overlapping invocations never process the same job twice.
    const { data: claimed } = await supabase.from("jobs")
      .update({ status: "running", updated_at: new Date().toISOString() })
      .eq("id", job.id).eq("status", "queued").select("id");
    if (!claimed?.length) continue;

    const event = job.payload;
    try {
      const { data: conn } = await supabase.from("strava_connections")
        .select("user_id, strava_athlete_id, access_token, refresh_token, token_expires_at")
        .eq("strava_athlete_id", event.owner_id).is("revoked_at", null).maybeSingle();
      if (!conn) {
        await setJob(job.id, { status: "done" });
        continue;
      }

      let activity: StravaApiActivity;
      try {
        const token = await getValidAccessToken(supabase, conn);
        activity = await stravaGet<StravaApiActivity>(supabase, `/activities/${event.object_id}`, token);
      } catch (e) {
        if (e instanceof StravaNotFoundError) {
          // Deleted, or private and outside our scope: make sure we hold nothing for it.
          await supabase.from("strava_activities").delete().eq("id", event.object_id);
          await setJob(job.id, { status: "done" });
          continue;
        }
        if (e instanceof StravaConnectionRevokedError || e instanceof StravaUnauthorizedError) {
          await deleteStravaDataForUser(supabase, conn.user_id, "strava_deauthorization");
          await setJob(job.id, { status: "done" });
          continue;
        }
        throw e;
      }

      const matches = matchActivity(activity, munros, config);

      if (!matches.length) {
        // Nothing to review, so nothing to keep [API Policy 6.4].
        await supabase.from("strava_activities").delete().eq("id", activity.id);
        await setJob(job.id, { status: "done" });
        processed++;
        continue;
      }

      const { error: activityError } = await supabase.from("strava_activities")
        .upsert(toStravaActivityRow(activity, conn.user_id));
      if (activityError) throw activityError;

      const { error: matchError } = await supabase.from("munro_matches").upsert(
        matches.map((m) => ({
          user_id: conn.user_id,
          munro_id: m.munroId,
          strava_activity_id: activity.id,
          match_distance_m: m.distanceM,
        })),
        { onConflict: "user_id,munro_id,strava_activity_id", ignoreDuplicates: true },
      );
      if (matchError) throw matchError;

      // A type change can drop Munros that previously matched.
      await supabase.from("munro_matches").delete()
        .eq("strava_activity_id", activity.id)
        .eq("status", "pending")
        .not("munro_id", "in", `(${matches.map((m) => m.munroId).join(",")})`);

      await setJob(job.id, { status: "done" });
      processed++;
    } catch (e) {
      if (e instanceof StravaRateLimitError) {
        await setJob(job.id, { status: "queued", run_after: e.retryAt.toISOString() });
        return json({ processed, deferred_until: e.retryAt.toISOString() });
      }
      console.error(`Job ${job.id} failed:`, (e as Error).message);
      const attempts = job.attempts + 1;
      await setJob(job.id, {
        status: attempts >= MAX_ATTEMPTS ? "failed" : "queued",
        attempts,
        run_after: new Date(Date.now() + 60_000 * 2 ** attempts).toISOString(),
      });
    }
  }

  return json({ processed });
});
