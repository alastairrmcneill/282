CREATE TABLE saved_lists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firebase_id TEXT UNIQUE,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  date_time_created TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE saved_lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_lists FORCE ROW LEVEL SECURITY;

-- Own-row CRUD for signed-in saved_lists
CREATE POLICY "saved_lists_select_authenticated"
ON saved_lists
FOR SELECT
TO authenticated
USING (user_id = (auth.jwt() ->> 'sub'));

CREATE POLICY "saved_lists_insert_authenticated"
ON saved_lists
FOR INSERT
TO authenticated
WITH CHECK (user_id = (auth.jwt() ->> 'sub'));

CREATE POLICY "saved_lists_update_authenticated"
ON saved_lists
FOR UPDATE
TO authenticated
USING (user_id = (auth.jwt() ->> 'sub'))
WITH CHECK (user_id = (auth.jwt() ->> 'sub'));

CREATE POLICY "saved_lists_delete_authenticated"
ON saved_lists
FOR DELETE
TO authenticated
USING (user_id = (auth.jwt() ->> 'sub'));

-- Tighten GRANTS: anon no direct table access; authenticated can CRUD but still gated by RLS
REVOKE UPDATE, DELETE ON saved_lists FROM anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON saved_lists TO authenticated;