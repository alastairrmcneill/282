CREATE TABLE user_fcm_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device_id TEXT NOT NULL,
  token TEXT NOT NULL UNIQUE,
  platform TEXT NOT NULL,  -- 'iOS', 'Android', 'web'
  push_enabled BOOLEAN NOT NULL DEFAULT true,
  is_active BOOLEAN NOT NULL DEFAULT true,
  app_version TEXT,
  os_version TEXT,
  device_model TEXT,
  last_used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_error TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(user_id, device_id)
);

-- Index for efficient queries
CREATE INDEX idx_user_fcm_tokens_user_id ON user_fcm_tokens(user_id);
CREATE INDEX idx_user_fcm_tokens_active_push ON user_fcm_tokens(user_id, is_active, push_enabled) WHERE is_active = true AND push_enabled = true;

-- RLS policies
ALTER TABLE user_fcm_tokens ENABLE ROW LEVEL SECURITY;

-- Users can read all their own device tokens
CREATE POLICY "user_fcm_tokens_self_select"
ON user_fcm_tokens
FOR SELECT
TO authenticated
USING (user_id = (auth.jwt() ->> 'sub'));

CREATE POLICY "user_fcm_tokens_self_insert"
ON user_fcm_tokens
FOR INSERT
TO authenticated
WITH CHECK (user_id = (auth.jwt() ->> 'sub'));

CREATE POLICY "user_fcm_tokens_self_update"
ON user_fcm_tokens
FOR UPDATE
TO authenticated
USING (user_id = (auth.jwt() ->> 'sub'))
WITH CHECK (user_id = (auth.jwt() ->> 'sub'));

CREATE POLICY "user_fcm_tokens_self_delete"
ON user_fcm_tokens
FOR DELETE
TO authenticated
USING (user_id = (auth.jwt() ->> 'sub'));

-- Tighten GRANTS: anon no direct table access; authenticated can CRUD but still gated by RLS
REVOKE UPDATE, DELETE ON user_fcm_tokens FROM anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON user_fcm_tokens TO authenticated;

-- Function to auto-update updated_at
CREATE OR REPLACE FUNCTION update_user_fcm_tokens_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_fcm_tokens_updated_at
  BEFORE UPDATE ON user_fcm_tokens
  FOR EACH ROW
  EXECUTE FUNCTION update_user_fcm_tokens_updated_at();

-- Update vu_profiles view to not depend on fcm_token column before dropping it
DROP VIEW IF EXISTS vu_profiles;

CREATE OR REPLACE VIEW vu_profiles AS
SELECT  
  u.id,
  u.first_name,
  u.last_name,
  u.display_name,
  u.search_name,
  u.bio,
  u.profile_picture_url,
  u.app_version,
  u.platform,
  u.sign_in_method,
  u.date_time_created,
  u.profile_visibility,
  COALESCE(fc.followers_count, 0) AS followers_count,
  COALESCE(fg.following_count, 0) AS following_count,
  ag.annual_goal_target,
  ag.annual_goal_progress,
  ag.annual_goal_id,
  ag.annual_goal_year,
  mc.munros_completed
FROM users u
LEFT JOIN LATERAL (
  SELECT count(*)::bigint AS followers_count
  FROM followers f
  WHERE f.target_id = u.id
) fc ON true
LEFT JOIN LATERAL (
  SELECT count(*)::bigint AS following_count
  FROM followers f
  WHERE f.source_id = u.id
) fg ON true
LEFT JOIN LATERAL (
  SELECT
    p.annual_target AS annual_goal_target,
    p.progress AS annual_goal_progress,
    p.achievement_id AS annual_goal_id,
    p.criteria_value as annual_goal_year
  FROM vu_user_achievement_progress p
  WHERE p.user_id = u.id
    AND p.type = 'annualGoal'
  ORDER BY p.date_time_created DESC
  LIMIT 1
) ag ON true
LEFT JOIN LATERAL (
  SELECT
    COUNT(DISTINCT m.munro_id) AS munros_completed
  FROM munro_completions m
  WHERE m.user_id = u.id
) mc ON true;

ALTER VIEW vu_profiles SET (security_invoker = true, security_barrier = true);

-- Now safe to drop legacy fcm_token column from users table
ALTER TABLE users DROP COLUMN IF EXISTS fcm_token;
