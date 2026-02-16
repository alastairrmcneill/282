-- Add detail column to notifications table
ALTER TABLE notifications ADD COLUMN detail TEXT;

-- Populate detail column based on type
UPDATE notifications
SET detail = CASE
  WHEN type = 'like' THEN 'liked your post.'
  WHEN type = 'comment' THEN 'commented on your post.'
  WHEN type = 'follow' THEN 'followed you.'
  ELSE NULL
END;

-- Update the view
DROP VIEW IF EXISTS vu_notifications;

CREATE OR REPLACE VIEW vu_notifications AS
SELECT 
  n.*,
  u.display_name AS source_display_name,
  u.profile_picture_url AS source_profile_picture_url 
FROM notifications n
LEFT JOIN users u ON u.id = n.source_id;

ALTER VIEW vu_notifications SET (security_invoker = true, security_barrier = true);