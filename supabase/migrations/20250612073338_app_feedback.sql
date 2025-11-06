-- App Feedback
CREATE TABLE app_feedbacks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT REFERENCES users(id) ON DELETE SET NULL,
  date_time_provided TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  survey_number INT,
  answer_1 TEXT,
  answer_2 TEXT,
  app_version TEXT,
  platform TEXT
);

ALTER TABLE app_feedbacks ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_feedbacks FORCE ROW LEVEL SECURITY;

CREATE POLICY "app_feedbacks_insert"
ON app_feedbacks
FOR INSERT
TO anon, authenticated
WITH CHECK (true);

REVOKE ALL ON TABLE app_feedbacks FROM anon, authenticated;
GRANT INSERT ON TABLE app_feedbacks TO anon, authenticated;