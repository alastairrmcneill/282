CREATE OR REPLACE VIEW vu_post_comments AS 
SELECT
  c.*, 
  u.display_name AS author_display_name, 
  u.profile_picture_url AS author_profile_picture_url
FROM comments c
LEFT JOIN users u ON u.id = c.author_id
ORDER BY c.date_time_created DESC;