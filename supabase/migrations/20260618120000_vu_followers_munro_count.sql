DROP VIEW IF EXISTS vu_followers;

CREATE OR REPLACE VIEW vu_followers AS
SELECT
  f.*,
  s.display_name AS source_display_name,
  s.profile_picture_url AS source_profile_picture_url,
  s.munros_completed AS source_munros_completed,
  t.display_name AS target_display_name,
  t.profile_picture_url AS target_profile_picture_url,
  t.search_name AS target_search_name,
  t.munros_completed AS target_munros_completed
FROM followers f
LEFT JOIN vu_profiles s ON s.id = f.source_id
LEFT JOIN vu_profiles t ON t.id = f.target_id;

ALTER VIEW vu_followers SET (security_invoker = true, security_barrier = true);
