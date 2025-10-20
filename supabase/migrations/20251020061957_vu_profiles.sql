CREATE OR REPLACE VIEW vu_profiles AS
SELECT  
  u.*,
  COALESCE(fc.followers_count, 0) AS followers_count,
  COALESCE(fg.following_count, 0) AS following_count,
  ag.annual_goal_target,
  ag.annual_goal_progress,
  ag.annual_goal_id,
  ag.annual_goal_year,
  mc.munros_completed
FROM users u
LEFT JOIN LATERAL (
  SELECT count(*)::bigint AS followers_count
  FROM followers f
  WHERE f.target_id = u.id
) fc ON true
LEFT JOIN LATERAL (
  SELECT count(*)::bigint AS following_count
  FROM followers f
  WHERE f.source_id = u.id
) fg ON true
-- latest annualGoal target + progress
LEFT JOIN LATERAL (
  SELECT
    p.annual_target AS annual_goal_target,
    p.progress AS annual_goal_progress,
    p.achievement_id AS annual_goal_id,
    p.criteria_value as annual_goal_year
  FROM vu_user_achievement_progress p
  WHERE p.user_id = u.id
    AND p.type = 'annualGoal'
  ORDER BY p.date_time_created DESC
  LIMIT 1
) ag ON true
LEFT JOIN LATERAL (
  SELECT
    COUNT(DISTINCT m.munro_id) AS munros_completed
  FROM munro_completions m
  WHERE m.user_id = u.id
) mc ON true;