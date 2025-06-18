-- Munro Pictures
CREATE TABLE munro_pictures (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  munro_id INT NOT NULL REFERENCES munros(id) ON DELETE CASCADE,
  author_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL UNIQUE,
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  date_time_created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  privacy TEXT DEFAULT 'public'
);