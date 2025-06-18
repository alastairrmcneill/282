-- POSTS
CREATE TABLE POSTS (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firebase_id TEXT UNIQUE,
  author_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT,
  description TEXT,
  date_time_created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  privacy TEXT DEFAULT 'public'
);