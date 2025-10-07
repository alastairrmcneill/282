CREATE OR REPLACE VIEW vu_followers AS
SELECT 
  f.*,
  s.display_name AS source_display_name,
  s.profile_picture_url AS source_profile_picture_url,
  t.display_name AS target_display_name,
  t.profile_picture_url AS target_profile_picture_url,
  t.search_name AS target_search_name
FROM followers f
LEFT JOIN users s ON s.id = f.source_id
LEFT JOIN users t ON t.id = f.target_id;