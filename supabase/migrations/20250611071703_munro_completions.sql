-- Munro Completions
CREATE TABLE munro_completions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  munro_id INT NOT NULL REFERENCES munros(id) ON DELETE CASCADE,
  date_time_completed TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  post_id UUID REFERENCES posts(id) ON DELETE SET NULL
);

ALTER TABLE munro_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE munro_completions FORCE ROW LEVEL SECURITY;

CREATE POLICY "munro_completions_read_authenticated_anon"
ON munro_completions 
FOR SELECT
TO anon, authenticated
USING (
  user_id = (auth.jwt() ->> 'sub')
  OR (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.id = munro_completions.user_id AND u.profile_visibility = 'public'
    )
  )
);

CREATE POLICY "munro_completions_insert_authenticated"
ON munro_completions
FOR INSERT
TO authenticated
WITH CHECK (user_id = (auth.jwt() ->> 'sub'));

CREATE POLICY "munro_completions_update_authenticated"
ON munro_completions
FOR UPDATE
TO authenticated
USING (user_id = (auth.jwt() ->> 'sub'))
WITH CHECK (user_id = (auth.jwt() ->> 'sub'));

CREATE POLICY "munro_completions_delete_authenticated"
ON munro_completions
FOR DELETE
TO authenticated
USING (user_id = (auth.jwt() ->> 'sub'));

REVOKE ALL ON TABLE munro_completions FROM anon, authenticated;
GRANT SELECT ON TABLE munro_completions TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE munro_completions TO authenticated;