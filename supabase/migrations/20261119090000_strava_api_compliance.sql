-- Strava API Agreement / API Policy (effective 2026-06-01) compliance.
--
-- Policy references in brackets, e.g. [6.2] = API Policy section 6.2.
--
-- 1. Lock down every Strava table: RLS on, no anon access, tokens never readable
--    by clients. Before this, RLS was off and anon could SELECT strava_connections
--    (including access/refresh tokens).                               [8.1]
-- 2. Stop storing location data (polyline, start/end latlng, elev_high). Matching
--    happens in memory as the activity arrives.                       [5.7, 6.2]
-- 3. strava_activities becomes a 7-day transient cache that is only written for
--    activities that matched a Munro, and is purged hourly.           [5.5, 6.2, 6.4]
-- 4. Single-use, expiring OAuth state so a Strava account can only be linked
--    to the 282 user who started the flow.                            [8.1]
-- 5. Webhook idempotency, rate-limit usage tracking and a deletion log so we
--    can confirm deletion to users and certify it to Strava.          [2.5, 3.7, 7.4]

-- ---------------------------------------------------------------------------
-- strava_connections
-- ---------------------------------------------------------------------------

ALTER TABLE public.strava_connections
  ADD COLUMN IF NOT EXISTS last_historical_scan_at timestamptz NULL;

-- Tokens are now AES-GCM encrypted by the edge functions (STRAVA_TOKEN_ENCRYPTION_KEY).
-- Existing plaintext values are re-encrypted on the next token refresh.
COMMENT ON COLUMN public.strava_connections.access_token IS 'AES-GCM encrypted ("v1:" prefix). Never exposed to clients.';
COMMENT ON COLUMN public.strava_connections.refresh_token IS 'AES-GCM encrypted ("v1:" prefix). Never exposed to clients.';

ALTER TABLE public.strava_connections ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE public.strava_connections FROM anon, authenticated;
GRANT SELECT (user_id, strava_athlete_id, scope, connected_at, revoked_at, last_historical_scan_at)
  ON TABLE public.strava_connections TO authenticated;

DROP POLICY IF EXISTS "strava_connections_self_select" ON public.strava_connections;
CREATE POLICY "strava_connections_self_select"
ON public.strava_connections
FOR SELECT
TO authenticated
USING (user_id = (select auth.jwt() ->> 'sub'));

-- ---------------------------------------------------------------------------
-- strava_activities: 7-day transient cache, no geographic data
-- ---------------------------------------------------------------------------

ALTER TABLE public.strava_activities
  DROP COLUMN IF EXISTS polyline,
  DROP COLUMN IF EXISTS start_latlng,
  DROP COLUMN IF EXISTS end_latlng,
  DROP COLUMN IF EXISTS elev_high_m;

ALTER TABLE public.strava_activities
  ADD COLUMN IF NOT EXISTS device_name text NULL,
  ADD COLUMN IF NOT EXISTS expires_at timestamptz NOT NULL DEFAULT (now() + interval '7 days');

UPDATE public.strava_activities
SET expires_at = LEAST(expires_at, created_at + interval '7 days');

CREATE INDEX IF NOT EXISTS strava_activities_expires_at_idx ON public.strava_activities (expires_at);
CREATE INDEX IF NOT EXISTS strava_activities_user_id_idx ON public.strava_activities (user_id);

ALTER TABLE public.strava_activities ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE public.strava_activities FROM anon, authenticated;
GRANT SELECT ON TABLE public.strava_activities TO authenticated;

DROP POLICY IF EXISTS "strava_activities_self_select" ON public.strava_activities;
CREATE POLICY "strava_activities_self_select"
ON public.strava_activities
FOR SELECT
TO authenticated
USING (user_id = (select auth.jwt() ->> 'sub'));

-- ---------------------------------------------------------------------------
-- munro_matches: cascade with the cached activity, owner-only access
-- ---------------------------------------------------------------------------

ALTER TABLE public.munro_matches
  DROP CONSTRAINT IF EXISTS munro_matches_strava_activity_id_fkey;
ALTER TABLE public.munro_matches
  ADD CONSTRAINT munro_matches_strava_activity_id_fkey
  FOREIGN KEY (strava_activity_id) REFERENCES public.strava_activities(id) ON DELETE CASCADE;

ALTER TABLE public.munro_matches ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE public.munro_matches FROM anon, authenticated;
GRANT SELECT ON TABLE public.munro_matches TO authenticated;
GRANT UPDATE (status, reviewed_at) ON TABLE public.munro_matches TO authenticated;

DROP POLICY IF EXISTS "munro_matches_self_select" ON public.munro_matches;
CREATE POLICY "munro_matches_self_select"
ON public.munro_matches
FOR SELECT
TO authenticated
USING (user_id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "munro_matches_self_update" ON public.munro_matches;
CREATE POLICY "munro_matches_self_update"
ON public.munro_matches
FOR UPDATE
TO authenticated
USING (user_id = (select auth.jwt() ->> 'sub'))
WITH CHECK (user_id = (select auth.jwt() ->> 'sub'));

-- ---------------------------------------------------------------------------
-- jobs / strava_matching_config: server-only
-- ---------------------------------------------------------------------------

ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.jobs FROM anon, authenticated;

CREATE INDEX IF NOT EXISTS jobs_queued_idx ON public.jobs (run_after) WHERE status = 'queued';

ALTER TABLE public.strava_matching_config ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.strava_matching_config FROM anon, authenticated;

-- ---------------------------------------------------------------------------
-- OAuth state (single use, 10 minute expiry)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.strava_oauth_states (
  state text PRIMARY KEY,
  user_id text NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL DEFAULT (now() + interval '10 minutes')
);

ALTER TABLE public.strava_oauth_states ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.strava_oauth_states FROM anon, authenticated;

-- ---------------------------------------------------------------------------
-- Webhook idempotency (Strava retries deliveries)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.strava_webhook_events_processed (
  object_type text NOT NULL,
  object_id bigint NOT NULL,
  aspect_type text NOT NULL,
  event_time bigint NOT NULL,
  processed_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (object_type, object_id, aspect_type, event_time)
);

ALTER TABLE public.strava_webhook_events_processed ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.strava_webhook_events_processed FROM anon, authenticated;

-- ---------------------------------------------------------------------------
-- App-wide Strava rate limit usage, read from X-RateLimit-* / X-ReadRateLimit-*
-- response headers so the job processor and scans back off before hitting 429s.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.strava_rate_limit_usage (
  id int PRIMARY KEY DEFAULT 1,
  short_limit int NULL,
  short_usage int NULL,
  daily_limit int NULL,
  daily_usage int NULL,
  read_short_limit int NULL,
  read_short_usage int NULL,
  read_daily_limit int NULL,
  read_daily_usage int NULL,
  throttled_until timestamptz NULL,
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT strava_rate_limit_usage_single_row CHECK (id = 1)
);

INSERT INTO public.strava_rate_limit_usage (id) VALUES (1) ON CONFLICT (id) DO NOTHING;

ALTER TABLE public.strava_rate_limit_usage ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.strava_rate_limit_usage FROM anon, authenticated;

-- ---------------------------------------------------------------------------
-- Deletion log: lets the app show written confirmation of deletion [2.5] and
-- lets us certify deletion to Strava on request [7.4]. Holds no Strava Data.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.strava_data_deletions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id text NOT NULL,
  reason text NOT NULL, -- user_disconnect | strava_deauthorization | user_request | account_deleted
  activities_deleted int NOT NULL DEFAULT 0,
  matches_deleted int NOT NULL DEFAULT 0,
  completed_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS strava_data_deletions_user_id_idx
  ON public.strava_data_deletions (user_id, completed_at DESC);

ALTER TABLE public.strava_data_deletions ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.strava_data_deletions FROM anon, authenticated;
GRANT SELECT ON TABLE public.strava_data_deletions TO authenticated;

DROP POLICY IF EXISTS "strava_data_deletions_self_select" ON public.strava_data_deletions;
CREATE POLICY "strava_data_deletions_self_select"
ON public.strava_data_deletions
FOR SELECT
TO authenticated
USING (user_id = (select auth.jwt() ->> 'sub'));

-- ---------------------------------------------------------------------------
-- Leftover debug table from webhook testing
-- ---------------------------------------------------------------------------

DROP TABLE IF EXISTS public.strava_webhook_events_test;

-- ---------------------------------------------------------------------------
-- Retention purge [6.2, 6.4]
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.purge_expired_strava_data()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Cached activities older than 7 days, or whose matches have all been reviewed.
  -- munro_matches rows go with them via ON DELETE CASCADE.
  DELETE FROM strava_activities a
  WHERE a.expires_at < now()
     OR (
       a.created_at < now() - interval '1 hour'
       AND NOT EXISTS (
         SELECT 1 FROM munro_matches m
         WHERE m.strava_activity_id = a.id AND m.status = 'pending'
       )
     );

  DELETE FROM strava_oauth_states WHERE expires_at < now();

  DELETE FROM strava_webhook_events_processed WHERE processed_at < now() - interval '7 days';

  -- Job payloads contain Strava ids.
  DELETE FROM jobs
  WHERE job_type LIKE 'strava_%'
    AND (
      (status IN ('done', 'failed') AND updated_at < now() - interval '1 day')
      OR created_at < now() - interval '7 days'
    );
END;
$$;

REVOKE ALL ON FUNCTION public.purge_expired_strava_data() FROM PUBLIC, anon, authenticated;

CREATE EXTENSION IF NOT EXISTS pg_cron;

SELECT cron.schedule(
  'purge_expired_strava_data',
  '7 * * * *',
  $$SELECT public.purge_expired_strava_data();$$
);

-- ---------------------------------------------------------------------------
-- Drive strava-job-processor every minute.
-- Requires two Vault secrets (create once, outside migrations):
--   select vault.create_secret('https://<project-ref>.supabase.co', 'project_url');
--   select vault.create_secret('<same value as STRAVA_JOB_PROCESSOR_SECRET>', 'strava_job_processor_secret');
-- ---------------------------------------------------------------------------

CREATE EXTENSION IF NOT EXISTS pg_net;

SELECT cron.schedule(
  'run_strava_job_processor',
  '* * * * *',
  $$
  SELECT net.http_post(
    url := (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'project_url') || '/functions/v1/strava-job-processor',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-job-processor-secret', (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'strava_job_processor_secret')
    ),
    body := '{}'::jsonb
  )
  WHERE EXISTS (SELECT 1 FROM public.jobs WHERE status = 'queued' AND run_after <= now());
  $$
);
