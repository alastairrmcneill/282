-- Create Achievements
CREATE TABLE achievements (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  type TEXT NOT NULL,
  criteria_value TEXT NOT NULL,
  criteria_count INT NOT NULL,
  date_time_created TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
