-- POSTS
CREATE TABLE POSTS (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firebase_id TEXT UNIQUE,
  author_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT,
  description TEXT,
  date_time_created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  privacy TEXT DEFAULT 'public'
);

ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts FORCE ROW LEVEL SECURITY;

-- Read policy for authenticated users
CREATE POLICY "posts_select_authenticated"
ON posts
FOR SELECT
TO authenticated
USING (
  -- Author can always see their own post
  author_id = (auth.jwt() ->> 'sub')

  -- Anyone authenticated can see public posts
  OR privacy = 'public'

  -- Friends-only posts: visible if a follow exists in either direction
  OR (
    privacy = 'friends'
    AND EXISTS (
      SELECT 1
      FROM followers f
      WHERE (f.source_id = posts.author_id AND f.target_id = (auth.jwt() ->> 'sub'))
         OR (f.target_id = posts.author_id AND f.source_id = (auth.jwt() ->> 'sub'))
    )
  )
);

-- Read policy for anonymous users
CREATE POLICY "posts_select_anon"
ON posts
FOR SELECT
TO anon
USING (privacy = 'public');

-- Insert policy for authenticated users
CREATE POLICY "posts_insert_authenticated"
ON posts
FOR INSERT
TO authenticated
WITH CHECK (author_id = (auth.jwt() ->> 'sub'));

-- Update policy for authenticated users
CREATE POLICY "posts_update_authenticated"
ON posts
FOR UPDATE
TO authenticated
USING (author_id = (auth.jwt() ->> 'sub'))
WITH CHECK (author_id = (auth.jwt() ->> 'sub'));

-- Delete policy for authenticated users
CREATE POLICY "posts_delete_authenticated"
ON posts
FOR DELETE
TO authenticated
USING (author_id = (auth.jwt() ->> 'sub'));

-- Tighten GRANTS: anon no direct table access; authenticated can CRUD but still gated by RLS
REVOKE ALL ON TABLE posts FROM anon, authenticated;
GRANT SELECT ON TABLE posts TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE posts TO authenticated;