CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  type TEXT,
  content_id TEXT NULL,
  comment TEXT NULL,
  completed BOOLEAN NULL DEFAULT false,
  date_time_created TIMESTAMP WITH TIME ZONE NULL DEFAULT NOW()
);