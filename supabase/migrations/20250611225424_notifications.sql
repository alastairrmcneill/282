-- Notifications
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  target_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  source_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  type TEXT,
  read BOOLEAN,
  date_time_created TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications FORCE ROW LEVEL SECURITY;

CREATE POLICY "notifications_read_authenticated_anon"
ON notifications
FOR SELECT
TO authenticated
USING (target_id = (auth.jwt() ->> 'sub'));

CREATE POLICY "notifications_update_authenticated"
ON notifications
FOR UPDATE
TO authenticated
USING (target_id = (auth.jwt() ->> 'sub'))
WITH CHECK (target_id = (auth.jwt() ->> 'sub'));

REVOKE ALL ON TABLE notifications FROM anon, authenticated;
GRANT SELECT ON TABLE notifications TO anon;
GRANT SELECT, UPDATE ON TABLE notifications TO authenticated;