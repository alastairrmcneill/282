CREATE OR REPLACE VIEW vu_likes AS
SELECT 
  l.*,
  u.display_name AS user_display_name,
  u.profile_picture_url AS user_profile_picture_url
FROM likes l
LEFT JOIN users u ON l.user_id = u.id
ORDER BY l.date_time_created DESC;

