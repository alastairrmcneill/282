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