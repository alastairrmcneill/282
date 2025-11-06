-- Likes
CREATE TABLE likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  date_time_created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, post_id)
);

ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes FORCE ROW LEVEL SECURITY;

CREATE POLICY "likes_read_authenticated_anon"
ON likes
FOR SELECT
TO anon, authenticated
USING (
  user_id = (auth.jwt() ->> 'sub')
  OR (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.id = likes.user_id AND u.profile_visibility = 'public'
    )
  )
);

CREATE POLICY "likes_insert_authenticated"
ON likes
FOR INSERT
TO authenticated
WITH CHECK (user_id = (auth.jwt() ->> 'sub'));

CREATE POLICY "likes_delete_authenticated"
ON likes
FOR DELETE
TO authenticated
USING (user_id = (auth.jwt() ->> 'sub'));

REVOKE ALL ON TABLE likes FROM anon, authenticated;
GRANT SELECT ON TABLE likes TO anon;
GRANT SELECT, INSERT, DELETE ON TABLE likes TO authenticated;