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