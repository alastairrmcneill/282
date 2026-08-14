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