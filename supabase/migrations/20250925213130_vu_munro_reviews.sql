CREATE OR REPLACE VIEW vu_munro_reviews AS
SELECT 
  r.*,
  u.display_name as author_display_name,
  u.profile_picture_url as author_profile_picture_url
FROM 
  reviews r 
LEFT JOIN users u
  ON u.id = r.author_id;