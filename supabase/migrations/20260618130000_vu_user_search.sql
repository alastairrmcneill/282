DROP VIEW IF EXISTS vu_user_search;

CREATE OR REPLACE VIEW vu_user_search AS
SELECT
  u.id,
  u.display_name,
  u.search_name,
  u.first_name,
  u.last_name,
  u.profile_picture_url,
  u.bio,
  u.app_version,
  u.platform,
  u.sign_in_method,
  u.date_time_created AS date_created,
  u.profile_visibility,
  COALESCE(mc.munros_completed, 0) AS munros_completed
FROM users u
LEFT JOIN LATERAL (
  SELECT COUNT(DISTINCT munro_id)::int AS munros_completed
  FROM munro_completions
  WHERE user_id = u.id
) mc ON true;

ALTER VIEW vu_user_search SET (security_invoker = true);
