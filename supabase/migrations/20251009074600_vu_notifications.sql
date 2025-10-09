CREATE OR REPLACE VIEW vu_notifications AS
SELECT 
  n.*,
  u.display_name AS source_display_name,
  u.profile_picture_url AS source_profile_picture_url 
FROM notifications n
LEFT JOIN users u ON u.id = n.source_id
ORDER BY n.date_time_created DESC;