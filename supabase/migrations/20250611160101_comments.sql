-- Comments
CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id TEXT NOT NULL REFERENCES users(id),
  post_id UUID NOT NULL REFERENCES posts(id),
  text TEXT,
  date_time_created TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments FORCE ROW LEVEL SECURITY;

CREATE POLICY "comments_read_authenticated_anon"
ON comments
FOR SELECT
TO anon, authenticated
USING (
  author_id = (auth.jwt() ->> 'sub')
  OR (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.id = comments.author_id AND u.profile_visibility = 'public'
    )
  )
);

CREATE POLICY "comments_insert_authenticated"
ON comments
FOR INSERT
TO authenticated
WITH CHECK (author_id = (auth.jwt() ->> 'sub'));

CREATE POLICY "comments_update_authenticated"
ON comments
FOR UPDATE
TO authenticated
USING (author_id = (auth.jwt() ->> 'sub'))
WITH CHECK (author_id = (auth.jwt() ->> 'sub'));

CREATE POLICY "comments_delete_authenticated"
ON comments
FOR DELETE
TO authenticated
USING (author_id = (auth.jwt() ->> 'sub'));

REVOKE ALL ON TABLE comments FROM anon, authenticated;
GRANT SELECT ON TABLE comments TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE comments TO authenticated;