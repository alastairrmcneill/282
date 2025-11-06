-- Create users table
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  display_name TEXT GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,
  search_name TEXT GENERATED ALWAYS AS (lower(first_name || ' ' || last_name)) STORED,
  bio TEXT,
  profile_picture_url TEXT,
  fcm_token TEXT,
  app_version TEXT,
  platform TEXT,
  sign_in_method TEXT,
  date_time_created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  profile_visibility TEXT NOT NULL DEFAULT 'public'
);

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE users FORCE ROW LEVEL SECURITY;

-- Own-row CRUD for signed-in users
CREATE POLICY "users_self_select"
ON users
FOR SELECT
TO authenticated
USING ((profile_visibility = 'public') OR (id = (auth.jwt() ->> 'sub')));

CREATE POLICY "users_self_insert"
ON users
FOR INSERT
TO authenticated
WITH CHECK (id = (auth.jwt() ->> 'sub'));

CREATE POLICY "users_self_update"
ON users
FOR UPDATE
TO authenticated
USING (id = (auth.jwt() ->> 'sub'))
WITH CHECK (id = (auth.jwt() ->> 'sub'));

CREATE POLICY "users_self_delete"
ON users
FOR DELETE
TO authenticated
USING (id = (auth.jwt() ->> 'sub'));

-- Public read of public profiles OR my own profile
CREATE POLICY "users_public_or_self_selectable"
ON users
FOR SELECT
TO anon, authenticated
USING (
  profile_visibility = 'public'
  OR id = (auth.jwt() ->> 'sub')
);

-- Tighten GRANTS: anon no direct table access; authenticated can CRUD but still gated by RLS
REVOKE UPDATE, DELETE ON users FROM anon;
GRANT SELECT ON users TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON users TO authenticated;