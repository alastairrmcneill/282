-- One row per user's Strava connection
create table public.strava_connections (
  user_id text primary key references public.users(id),
  strava_athlete_id bigint not null unique,
  access_token text not null,        -- Supabase Vault-encrypted, see Part 6
  refresh_token text not null,       -- Supabase Vault-encrypted
  token_expires_at timestamptz not null,
  scope text not null,
  connected_at timestamptz not null default now(),
  revoked_at timestamptz null,
  historical_scan_status text not null default 'pending', -- pending | in_progress | completed | failed
  historical_scan_progress jsonb null, -- { activities_scanned, munros_found, page_cursor }
  historical_scan_completed_at timestamptz null
);

-- Activity summaries pulled from Strava, and the outcome of matching
create table public.strava_activities (
  id bigint primary key,             -- Strava's activity id
  user_id text not null references public.users(id),
  source text not null,              -- 'historical_scan' | 'webhook'
  activity_type text not null,
  start_date timestamptz not null,
  start_latlng point null,
  end_latlng point null,
  distance_m numeric null,
  elevation_gain_m numeric null,
  elev_high_m numeric null,
  summary_polyline text null,
  match_status text not null default 'pending', -- pending | no_match | matched | skipped_manual | skipped_type | skipped_out_of_region
  raw_summary jsonb null,
  created_at timestamptz not null default now()
);

-- Individual munro matches — the review-queue content
create table public.munro_matches (
  id uuid primary key default gen_random_uuid(),
  user_id text not null references public.users(id),
  munro_id int not null references public.munros(id),
  strava_activity_id bigint not null references public.strava_activities(id),
  match_distance_m numeric null,
  status text not null default 'pending', -- pending | confirmed | rejected
  detected_at timestamptz not null default now(),
  reviewed_at timestamptz null,
  unique (user_id, munro_id, strava_activity_id)
);

-- Tunable matching thresholds — edited directly in Supabase, no redeploy needed
create table public.strava_matching_config (
  id int primary key default 1,
  radius_m numeric not null default 1000,
  elev_high_threshold_m numeric not null default 850,
  bounding_box jsonb not null default '{"sw_lng": -10, "sw_lat": 53, "ne_lng": 0, "ne_lat": 62}',
  candidate_types text[] not null default array['Hike','Walk','TrailRun','Run','BackcountrySki','AlpineSki'],
  updated_at timestamptz not null default now(),
  constraint single_row check (id = 1)
);

-- Async job queue
create table public.jobs (
  id uuid primary key default gen_random_uuid(),
  job_type text not null,   -- 'strava_historical_scan' | 'strava_webhook_activity'
  payload jsonb not null,
  status text not null default 'queued', -- queued | running | done | failed
  attempts int not null default 0,
  run_after timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- -- Strava API usage tracking (per-app, shared across all users)
-- create table public.strava_rate_limit_usage (
--   window_start timestamptz primary key,
--   requests_used int not null default 0
-- );

-- -- Idempotency guard for webhook deliveries — see Part 7
-- create table public.strava_webhook_events_processed (
--   strava_activity_id bigint not null,
--   aspect_type text not null,
--   event_time timestamptz not null,
--   processed_at timestamptz not null default now(),
--   primary key (strava_activity_id, aspect_type, event_time)
-- );


alter publication supabase_realtime add table public.munro_matches;