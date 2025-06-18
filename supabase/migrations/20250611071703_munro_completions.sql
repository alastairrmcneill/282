-- Munro Completions
CREATE TABLE munro_completions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  munro_id INT NOT NULL REFERENCES munros(id) ON DELETE CASCADE,
  date_time_completed TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  post_id UUID REFERENCES posts(id) ON DELETE SET NULL
);