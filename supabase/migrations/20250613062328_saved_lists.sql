CREATE TABLE saved_lists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firebase_id TEXT UNIQUE,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  date_time_created TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
