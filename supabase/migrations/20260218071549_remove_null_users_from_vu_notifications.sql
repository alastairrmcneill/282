DROP VIEW IF EXISTS vu_notifications;

CREATE OR REPLACE VIEW vu_notifications AS
SELECT 
  n.*,
  u.display_name AS source_display_name,
  u.profile_picture_url AS source_profile_picture_url 
FROM notifications n
JOIN users u ON u.id = n.source_id;

ALTER VIEW vu_notifications SET (security_invoker = true, security_barrier = true);