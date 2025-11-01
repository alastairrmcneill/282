-- User Achievements
CREATE TABLE user_achievements (
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  achievement_id TEXT NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
  acknowledged_at TIMESTAMPTZ,
  annual_target   INT,
  PRIMARY KEY (user_id, achievement_id)
);

ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements FORCE ROW LEVEL SECURITY;

CREATE POLICY "user_achievements_read_authenticated"
ON user_achievements
FOR SELECT
TO authenticated
USING (
  user_id = (auth.jwt() ->> 'sub')
  OR (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.id = user_achievements.user_id AND u.profile_visibility = 'public'
    )
  )
);

CREATE POLICY "user_achievements_insert_authenticated"
ON user_achievements
FOR INSERT
TO authenticated
WITH CHECK (user_id = (auth.jwt() ->> 'sub'));

CREATE POLICY "user_achievements_update_authenticated"
ON user_achievements
FOR UPDATE
TO authenticated
USING (user_id = (auth.jwt() ->> 'sub'))
WITH CHECK (user_id = (auth.jwt() ->> 'sub'));

REVOKE ALL ON TABLE user_achievements FROM anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE user_achievements TO authenticated;
