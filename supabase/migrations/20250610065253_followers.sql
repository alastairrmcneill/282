-- Creating followers table
CREATE TABLE followers (
  source_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  target_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  date_time_followed TIMESTAMP WITH TIME ZONE DEFAULT now(),
  PRIMARY KEY (source_id, target_id)
);