-- Supabase stops auto-granting Data API access to new objects in public (Oct 30 2026).
-- These objects previously relied on default privileges; grant explicitly so
-- `supabase db reset`, preview branches and new projects match prod.

GRANT SELECT ON TABLE
  vu_followers,
  vu_friends_feed,
  vu_friends_feed_base,
  vu_global_completion_count,
  vu_global_feed,
  vu_likes,
  vu_munro_ratings_breakdown,
  vu_munro_reviews,
  vu_notifications,
  vu_onboarding_achievements,
  vu_onboarding_feed,
  vu_onboarding_totals,
  vu_post_comments,
  vu_posts,
  vu_posts_base,
  vu_profiles,
  vu_saved_lists,
  vu_user_achievement_progress,
  vu_user_search
TO anon, authenticated;

GRANT SELECT ON TABLE
  vu_munros,
  mv_munros_commonly_climbed_with
TO anon, authenticated;

GRANT SELECT ON TABLE saved_lists, saved_list_munros TO anon;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO service_role;
