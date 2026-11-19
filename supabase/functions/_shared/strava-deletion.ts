import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

export type StravaDeletionReason =
  | "user_disconnect"
  | "strava_deauthorization"
  | "user_request"
  | "account_deleted";

export interface StravaDeletionResult {
  deletion_id: string;
  completed_at: string;
  activities_deleted: number;
  matches_deleted: number;
}

/**
 * Permanently deletes every piece of Strava Data and Strava-derived data held
 * for a user, then records that it happened (without keeping any Strava Data)
 * so we can confirm it to the user and certify it to Strava [API Policy 2.5, 7.4].
 */
export async function deleteStravaDataForUser(
  supabase: SupabaseClient,
  userId: string,
  reason: StravaDeletionReason,
): Promise<StravaDeletionResult> {
  const { data: conn } = await supabase.from("strava_connections")
    .select("strava_athlete_id").eq("user_id", userId).maybeSingle();

  const { count: matchesDeleted, error: matchesError } = await supabase
    .from("munro_matches").delete({ count: "exact" }).eq("user_id", userId);
  if (matchesError) throw matchesError;

  const { count: activitiesDeleted, error: activitiesError } = await supabase
    .from("strava_activities").delete({ count: "exact" }).eq("user_id", userId);
  if (activitiesError) throw activitiesError;

  const { error: statesError } = await supabase.from("strava_oauth_states")
    .delete().eq("user_id", userId);
  if (statesError) throw statesError;

  if (conn?.strava_athlete_id) {
    const { error: jobsError } = await supabase.from("jobs").delete()
      .like("job_type", "strava_%")
      .eq("payload->>owner_id", String(conn.strava_athlete_id));
    if (jobsError) throw jobsError;
  }

  const { error: connError } = await supabase.from("strava_connections")
    .delete().eq("user_id", userId);
  if (connError) throw connError;

  const { data: log, error: logError } = await supabase.from("strava_data_deletions")
    .insert({
      user_id: userId,
      reason,
      activities_deleted: activitiesDeleted ?? 0,
      matches_deleted: matchesDeleted ?? 0,
    })
    .select("id, completed_at, activities_deleted, matches_deleted")
    .single();
  if (logError) throw logError;

  return {
    deletion_id: log.id,
    completed_at: log.completed_at,
    activities_deleted: log.activities_deleted,
    matches_deleted: log.matches_deleted,
  };
}
