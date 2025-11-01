-- Creating followers table
CREATE TABLE followers (
  source_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  target_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  date_time_followed TIMESTAMP WITH TIME ZONE DEFAULT now(),
  PRIMARY KEY (source_id, target_id)
);

-- Enable RLS
ALTER TABLE followers ENABLE ROW LEVEL SECURITY;
ALTER TABLE followers FORCE ROW LEVEL SECURITY;

-- Own-row CRUD for signed-in users
CREATE POLICY "followers_select_policy"
ON followers
FOR SELECT
TO authenticated
USING (
  source_id = (auth.jwt() ->> 'sub')
  OR target_id = (auth.jwt() ->> 'sub')
  OR (
    EXISTS (
      SELECT 1 FROM users us
      WHERE us.id = followers.source_id AND us.profile_visibility = 'public'
    )
    AND EXISTS (
      SELECT 1 FROM users ut
      WHERE ut.id = followers.target_id AND ut.profile_visibility = 'public'
    )
  )
);

CREATE POLICY "followers_insert_policy"
ON followers
FOR INSERT
TO authenticated
WITH CHECK (source_id = (auth.jwt() ->> 'sub'));
  
CREATE POLICY "followers_delete_policy"
ON followers
FOR DELETE
TO authenticated
USING (source_id = (auth.jwt() ->> 'sub'));

-- Tighten GRANTS: anon no direct table access; authenticated can CRUD but still gated by RLS
REVOKE SELECT, INSERT, UPDATE, DELETE ON followers FROM anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON followers TO authenticated;
