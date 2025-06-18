-- Reviews
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  munro_id INT NOT NULL REFERENCES munros(id) ON DELETE CASCADE,
  author_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  rating INTEGER,
  text TEXT, 
  date_time_created TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);