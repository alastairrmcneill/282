-- Create Blocked Users table
CREATE TABLE blocked_users (
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  blocked_user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  datetime_blocked TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (user_id, blocked_user_id)
);

-- Enable RLS
ALTER TABLE blocked_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE blocked_users FORCE ROW LEVEL SECURITY;

-- Own-row CRUD for signed-in users
CREATE POLICY "user_self_select"
ON blocked_users
FOR SELECT
TO authenticated
USING (user_id = (auth.jwt() ->> 'sub'));

CREATE POLICY "users_self_insert"
ON blocked_users
FOR INSERT
TO authenticated
WITH CHECK (user_id = (auth.jwt() ->> 'sub'));

CREATE POLICY "users_self_update"
ON blocked_users
FOR UPDATE
TO authenticated
USING (user_id = (auth.jwt() ->> 'sub'))
WITH CHECK (user_id = (auth.jwt() ->> 'sub'));

CREATE POLICY "users_self_delete"
ON blocked_users
FOR DELETE
TO authenticated
USING (user_id = (auth.jwt() ->> 'sub'));

-- Tighten GRANTS: anon no direct table access; authenticated can CRUD but still gated by RLS
REVOKE SELECT, INSERT, UPDATE, DELETE ON blocked_users FROM anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON blocked_users TO authenticated;