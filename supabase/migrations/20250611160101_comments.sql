-- Comments
CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id TEXT NOT NULL REFERENCES users(id),
  post_id UUID NOT NULL REFERENCES posts(id),
  text TEXT,
  date_time_created TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

