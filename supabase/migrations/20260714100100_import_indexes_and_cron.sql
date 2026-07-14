-- ============================================================================
-- Import supabase/indexes.sql into migrations (282 Prod audit, 2026-07-14)
--
-- indexes.sql was previously a manual-apply-only file (SETUP.md step 4) because
-- CREATE INDEX CONCURRENTLY can't run inside the transaction `supabase db push`
-- wraps a migration file in. Tables here are in the thousands of rows, so a
-- brief write-lock from a plain CREATE INDEX is a non-issue -- this migration
-- uses plain CREATE INDEX IF NOT EXISTS throughout, safe on both a fresh
-- database and prod (where most of these objects already exist).
--
-- idx_slm_munro is dropped (confirmed unused, no covering feature) rather than
-- recreated. idx_posts_author_privacy_created and idx_users_search_name_trgm
-- are kept despite showing as "unused" in the advisor -- see migration plan
-- notes for why.
-- ============================================================================

-- quick name search (case-insensitive / partial)
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX IF NOT EXISTS idx_users_search_name_trgm
ON users USING GIN (search_name gin_trgm_ops);

-- blocked lookups in both directions
CREATE INDEX IF NOT EXISTS idx_blocked_user_id ON blocked_users (user_id);
CREATE INDEX IF NOT EXISTS idx_blocked_blocked_user_id ON blocked_users (blocked_user_id);

-- followers: you count both "followers of X" and "following of X"
-- PK (source_id, target_id) already handles "following", add reverse for "followers"
CREATE INDEX IF NOT EXISTS idx_followers_target_id ON followers (target_id);

-- paginate a user's posts, filter by privacy, global feed
CREATE INDEX IF NOT EXISTS idx_posts_privacy_created
  ON posts (privacy, date_time_created DESC);
CREATE INDEX IF NOT EXISTS idx_posts_author_privacy_created
  ON posts (author_id, privacy, date_time_created DESC);
-- fast join from foreign keys
CREATE INDEX IF NOT EXISTS idx_posts_author_id ON posts (author_id);

-- fast per-user tallies and distincts
CREATE INDEX IF NOT EXISTS idx_mc_user_munro ON munro_completions (user_id, munro_id);
CREATE INDEX IF NOT EXISTS idx_mc_user_date ON munro_completions (user_id, date_time_completed);
CREATE INDEX IF NOT EXISTS idx_mc_post ON munro_completions (post_id);
CREATE INDEX IF NOT EXISTS mc_post_id_notnull_idx
  ON munro_completions (post_id)
  WHERE post_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS mc_post_user_munro_idx
  ON munro_completions (post_id, user_id, munro_id)
  WHERE post_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_mc_munro_id ON munro_completions (munro_id);

-- required for concurrent refresh of vu_munros (stays materialized)
CREATE UNIQUE INDEX IF NOT EXISTS mv_vu_munros_pkey ON vu_munros (id);

-- common: count likes per post, does user X like post Y? (and prevent double-like)
CREATE UNIQUE INDEX IF NOT EXISTS idx_likes_unique_post_user ON likes (post_id, user_id);
CREATE INDEX IF NOT EXISTS idx_likes_post ON likes (post_id);

-- post comments pagination
CREATE INDEX IF NOT EXISTS idx_comments_post_created
  ON comments (post_id, date_time_created DESC);
CREATE INDEX IF NOT EXISTS idx_comments_author ON comments (author_id);

CREATE INDEX IF NOT EXISTS idx_reviews_munro_created
  ON reviews (munro_id, date_time_created DESC);
CREATE INDEX IF NOT EXISTS idx_reviews_author ON reviews (author_id);

-- "my unread notifications newest first"
CREATE INDEX IF NOT EXISTS idx_notifications_target_read_created
  ON notifications (target_id, read, date_time_created DESC);

-- common: pictures by post, per munro, public-only
CREATE INDEX IF NOT EXISTS idx_munro_pictures_post_created
  ON munro_pictures (post_id, date_time_created DESC);
CREATE INDEX IF NOT EXISTS idx_munro_pictures_munro_created
  ON munro_pictures (munro_id, date_time_created DESC);
CREATE INDEX IF NOT EXISTS idx_munro_pictures_privacy_post
  ON munro_pictures (privacy, post_id);

-- list contents and reverse lookup
CREATE INDEX IF NOT EXISTS idx_slm_list_added ON saved_list_munros (saved_list_id, date_time_added);
-- idx_slm_munro confirmed unused (pg_stat_user_indexes idx_scan = 0, no feature
-- depends on a "which lists contain munro X" reverse lookup) -- drop rather than
-- recreate. IF EXISTS makes this a no-op on a fresh database.
DROP INDEX IF EXISTS idx_slm_munro;

-- Missing FK-covering indexes flagged by the performance advisor
CREATE INDEX IF NOT EXISTS idx_app_feedbacks_user_id ON app_feedbacks (user_id);
CREATE INDEX IF NOT EXISTS idx_munro_pictures_author_id ON munro_pictures (author_id);
CREATE INDEX IF NOT EXISTS idx_notifications_post_id ON notifications (post_id);
CREATE INDEX IF NOT EXISTS idx_notifications_source_id ON notifications (source_id);
CREATE INDEX IF NOT EXISTS idx_reports_reporter_id ON reports (reporter_id);
CREATE INDEX IF NOT EXISTS idx_saved_lists_user_id ON saved_lists (user_id);
CREATE INDEX IF NOT EXISTS idx_user_achievements_achievement_id ON user_achievements (achievement_id);

-- required for concurrent refresh of mv_munros_commonly_climbed_with (stays materialized)
CREATE UNIQUE INDEX IF NOT EXISTS mv_munros_commonly_climbed_with_pkey
  ON mv_munros_commonly_climbed_with (munro_id, climbed_with_id);

-- refresh cron jobs. Note: mv_post_card's refresh job is intentionally NOT
-- (re)created here -- that materialized view is dropped and replaced with a
-- live view in the next migration.
--
-- Hourly, not every minute -- neither matview needs to be near-real-time, and
-- a 1-minute REFRESH CONCURRENTLY cadence on both was a real CPU/infra risk.
-- Job names kept as-is (now a bit misleading re: "every_min") on purpose --
-- cron.schedule upserts by name, so re-running this with the same name just
-- updates the existing job's interval in place; renaming would need an extra
-- cron.unschedule(old_name) step to avoid leaving a duplicate job behind on
-- environments where this migration already ran with the old schedule.
CREATE EXTENSION IF NOT EXISTS pg_cron;
SELECT cron.schedule('refresh_mv_munros_commonly_climbed_with_every_min',
                     '0 * * * *',
                     $$ REFRESH MATERIALIZED VIEW CONCURRENTLY mv_munros_commonly_climbed_with; $$);
SELECT cron.schedule('refresh_vu_munros_every_min',
                     '0 * * * *',
                     $$ REFRESH MATERIALIZED VIEW CONCURRENTLY vu_munros; $$);
