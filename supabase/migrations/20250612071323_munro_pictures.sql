-- Munro Pictures
CREATE TABLE munro_pictures (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  munro_id INT NOT NULL REFERENCES munros(id) ON DELETE CASCADE,
  author_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL UNIQUE,
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  date_time_created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  privacy TEXT DEFAULT 'public'
);

ALTER TABLE munro_pictures ENABLE ROW LEVEL SECURITY;
ALTER TABLE munro_pictures FORCE ROW LEVEL SECURITY;

-- Read policy for authenticated users
CREATE POLICY "munro_pictures_select_authenticated"
ON munro_pictures
FOR SELECT
TO authenticated
USING (
  -- Author can always see their own post
  author_id = (auth.jwt() ->> 'sub')

  -- Anyone authenticated can see public munro_pictures
  OR privacy = 'public'

  -- Friends-only munro_pictures: visible if a follow exists in either direction
  OR (
    privacy = 'friends'
    AND EXISTS (
      SELECT 1
      FROM followers f
      WHERE (f.source_id = munro_pictures.author_id AND f.target_id = (auth.jwt() ->> 'sub'))
         OR (f.target_id = munro_pictures.author_id AND f.source_id = (auth.jwt() ->> 'sub'))
    )
  )
);

-- Insert policy for authenticated users
CREATE POLICY "munro_pictures_insert_authenticated"
ON munro_pictures
FOR INSERT
TO authenticated
WITH CHECK (author_id = (auth.jwt() ->> 'sub'));

-- Update policy for authenticated users
CREATE POLICY "munro_pictures_update_authenticated"
ON munro_pictures
FOR UPDATE
TO authenticated
USING (author_id = (auth.jwt() ->> 'sub'))
WITH CHECK (author_id = (auth.jwt() ->> 'sub'));

-- Delete policy for authenticated users
CREATE POLICY "munro_pictures_delete_authenticated"
ON munro_pictures
FOR DELETE
TO authenticated
USING (author_id = (auth.jwt() ->> 'sub'));

-- Tighten GRANTS: anon no direct table access; authenticated can CRUD but still gated by RLS
REVOKE ALL ON TABLE munro_pictures FROM anon, authenticated;
GRANT SELECT ON TABLE munro_pictures TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE munro_pictures TO authenticated;