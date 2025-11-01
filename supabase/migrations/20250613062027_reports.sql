CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  type TEXT,
  content_id TEXT NULL,
  comment TEXT NULL,
  completed BOOLEAN NULL DEFAULT false,
  date_time_created TIMESTAMP WITH TIME ZONE NULL DEFAULT NOW()
);

ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports FORCE ROW LEVEL SECURITY;

CREATE POLICY "reports_insert"
ON reports
FOR INSERT
TO anon, authenticated
WITH CHECK (true);

REVOKE ALL ON TABLE reports FROM anon, authenticated;
GRANT INSERT ON TABLE reports TO anon, authenticated;