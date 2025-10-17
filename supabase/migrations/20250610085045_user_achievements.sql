-- User Achievements
CREATE TABLE user_achievements (
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  achievement_id TEXT NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
  acknowledged_at TIMESTAMPTZ,
  annual_target   INT,
  PRIMARY KEY (user_id, achievement_id)
);
