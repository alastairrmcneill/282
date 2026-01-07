DROP POLICY "user_self_select" ON blocked_users;

CREATE POLICY "blocked_users_visible_to_both"
ON blocked_users
FOR SELECT
TO authenticated
USING (
  user_id = (auth.jwt() ->> 'sub')
  OR blocked_user_id = (auth.jwt() ->> 'sub')
);

DROP POLICY "notifications_read_authenticated_anon" ON notifications;

CREATE POLICY "notifications_read_authenticated"
ON notifications
FOR SELECT
TO authenticated
USING (
  target_id = (auth.jwt() ->> 'sub')
  AND NOT EXISTS (
    SELECT 1
    FROM blocked_users b
    WHERE
      -- I blocked them
      (b.user_id = target_id AND b.blocked_user_id = source_id)
      OR
      -- They blocked me
      (b.user_id = source_id AND b.blocked_user_id = target_id)
  )
);

DROP POLICY "notifications_update_authenticated" ON notifications;

CREATE POLICY "notifications_update_authenticated"
ON notifications
FOR UPDATE
TO authenticated
USING (
  target_id = (auth.jwt() ->> 'sub')
  AND NOT EXISTS (
    SELECT 1
    FROM blocked_users b
    WHERE
      (b.user_id = target_id AND b.blocked_user_id = source_id)
      OR
      (b.user_id = source_id AND b.blocked_user_id = target_id)
  )
)
WITH CHECK (
  target_id = (auth.jwt() ->> 'sub')
  AND NOT EXISTS (
    SELECT 1
    FROM blocked_users b
    WHERE
      (b.user_id = target_id AND b.blocked_user_id = source_id)
      OR
      (b.user_id = source_id AND b.blocked_user_id = target_id)
  )
);
