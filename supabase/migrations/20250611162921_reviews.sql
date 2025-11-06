-- Reviews
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  munro_id INT NOT NULL REFERENCES munros(id) ON DELETE CASCADE,
  author_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  rating INTEGER,
  text TEXT, 
  date_time_created TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews FORCE ROW LEVEL SECURITY;

CREATE POLICY "reviews_read_authenticated_anon"
ON reviews
FOR SELECT
TO anon, authenticated
USING (
  author_id = (auth.jwt() ->> 'sub')
  OR (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.id = reviews.author_id AND u.profile_visibility = 'public'
    )
  )
);

CREATE POLICY "reviews_insert_authenticated"
ON reviews
FOR INSERT
TO authenticated
WITH CHECK (author_id = (auth.jwt() ->> 'sub'));

CREATE POLICY "reviews_update_authenticated"
ON reviews
FOR UPDATE
TO authenticated
USING (author_id = (auth.jwt() ->> 'sub'))
WITH CHECK (author_id = (auth.jwt() ->> 'sub'));

CREATE POLICY "reviews_delete_authenticated"
ON reviews
FOR DELETE
TO authenticated
USING (author_id = (auth.jwt() ->> 'sub'));

REVOKE ALL ON TABLE reviews FROM anon, authenticated;
GRANT SELECT ON TABLE reviews TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE reviews TO authenticated;