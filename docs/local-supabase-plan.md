# Plan: Run Supabase locally for dev (Firebase stays cloud)

## Context
Dev uses a cloud Supabase project (`pqgaczyxzxopkgyjqudk`); a 2nd cloud project needs a paid tier. Goal: replace dev with `supabase start` (Docker), fully described by `supabase/migrations` + `config.toml` + seed scripts, loaded with an anonymised one-off prod snapshot. Firebase (auth/storage/remote config/FCM) unchanged. Prod project untouched.

Decisions: Strava = separate dev Strava app + tunnel; prod data copied as-is, fresh dev user (no UID remap); iOS Simulator only; one-off snapshot with PII anonymised; schema diff on dev only (read-only).

## Findings: nothing *requires* managed Supabase
Every feature runs locally (Postgres, PostgREST, edge runtime, pg_cron, pg_net, vault all ship in the local stack). Only Strava webhooks need a public URL (tunnel). Drift found in dev that migrations don't capture:

1. **Strava migration not applied via migrations on dev** (`20260814073308` absent from dev migration list; tables created out of band). RLS is OFF on `strava_connections/activities/matching_config`, `munro_matches`, `jobs`; migration has no RLS/policies/indexes. Decide: enable RLS (deny-all; functions use service role) in a new migration.
2. **4 Dashboard DB webhooks** (comments, likes, followers, notifications -> `supabase_functions.http_request` with hardcoded project URL + service-role JWT). Not in migrations. `on-user-created` has no webhook in dev (confirm in prod whether intended).
3. **Vault secrets** `edge_function_invoke_key`, `edge_function_base_url` (manual per env; needed by report/feedback triggers).
4. **Firebase third-party auth** (Dashboard setting) -> `config.toml` `[auth.third_party.firebase]` (`enabled=false`, no project_id now). App sends Firebase ID token as `accessToken`.
5. **Storage bucket `munros`** (public, no storage policies) - not in migrations/config.
6. **Edge function secrets**: STRAVA_CLIENT_ID/SECRET/VERIFY_TOKEN, FIREBASE_PROJECT_ID, FIREBASE_SERVICE_ACCOUNT_BASE64, RESEND_API_KEY, NOTIFICATION_EMAIL, MIXPANEL_TOKEN, SYSTEM_USER_ID.
7. **Hardcoded URLs**: `lib/screens/nav/state/strava_state.dart:60` redirect_uri = dev cloud URL; `config/dev.json` SUPABASE_URL. `supabase/indexes.sql` + SETUP.md step 4 stale (already folded into migrations).
8. `config.toml` edge-function entries: only strava-*; `verify_jwt` true for on-* (dashboard default) - local webhooks need same JWT header.
9. `db.major_version = 15`; cloud is newer (extension list shows PG17 bits, pgaudit 17) -> bump to match prod before dump/restore.

## Steps
1. **Capture drift (read-only on dev, then write migrations)**
   - `supabase db diff --linked` / pg_dump --schema-only of dev vs replay of migrations locally; fix differences.
   - New migration: strava tables RLS + indexes (idempotent `if not exists`).
   - New migration: webhooks as plain triggers using pg_net + vault (same pattern as `20260715120000_report_and_feedback_email_triggers.sql`), one generic function `notify_edge_function(name)`; reads `edge_function_base_url` / `edge_function_invoke_key` from vault. Replaces Dashboard webhooks for all envs (prod: migration must drop the "On X Created Webhook" triggers to avoid double fire - do that carefully, prod apply is a separate explicit step).
   - Migration/config for `munros` bucket (`[storage.buckets.munros] public=true`) + policies mirroring dev/prod.
2. **Local config**
   - `config.toml`: `major_version` = prod's; `[auth.third_party.firebase] enabled=true project_id=<dev firebase id>`; `[functions.*]` entries for all functions; keep `seed.sql` enabled (check it's idempotent, 597 lines).
   - Trim containers: `supabase start -x imgproxy,mailpit,logflare,vector,studio?,realtime,supavisor,gotrue` as appropriate. Needed: db, kong, postgrest, edge runtime, storage (bucket). Auth (gotrue) unused (Firebase) but `auth` schema/uid() functions exist in DB; set `[analytics] enabled=false`, `[realtime] enabled=false` (check app has no `.channel()` usage first), `[inbucket]` off, keep studio optional.
   - `supabase/functions/.env.local` (gitignored) with secrets; `supabase functions serve --env-file`.
   - `config/local.json` + new Flutter flavour/launch config: SUPABASE_URL `http://127.0.0.1:54321`, local anon key from `supabase status`. Simulator reaches host localhost.
3. **Strava local**
   - Create 2nd Strava API app (dev); set callback domain to tunnel host.
   - Run `cloudflared tunnel --url http://127.0.0.1:54321` (named tunnel for stable hostname recommended, else ngrok reserved domain).
   - Make `redirect_uri` in `strava_state.dart` come from config (`SUPABASE_URL` + `/functions/v1/strava-connect` or new `STRAVA_REDIRECT_URI` define) instead of hardcoded.
   - Script `scripts/strava_register_webhook.sh`: POST `https://www.strava.com/api/v3/push_subscriptions` with tunnel URL `/functions/v1/strava-webhook` + STRAVA_VERIFY_TOKEN. Strava's verification GET needs functions served and tunnel up. Re-run if tunnel URL changes.
   - Offline alternative: curl strava-webhook with fake event or insert into `jobs`. Note strava-job-processor trigger path - verify how it is invoked (cron/pg_net?) and mirror locally.
   - Existing TODO in strava-webhook (deauthorize event) unaffected.
4. **Prod snapshot -> local** (`scripts/restore_prod_to_local.sh`, replaces `migrate_prod_to_dev.sh`)
   - `supabase db reset` (migrations + seed) then `pg_dump --data-only --schema=public` from prod (read-only connection), exclude `user_fcm_tokens`, `strava_connections`, `strava_activities`, `jobs`, `munro_matches`; load with `session_replication_role=replica`.
   - Exclude/handle `seed.sql` overlap (munros/achievements static data: truncate before load or ON CONFLICT DO NOTHING as the old script does).
   - Anonymise after load: scrub `users` (display_name/search_name/email-like fields, bio, avatar), comment/review/post text optional, FCM and Strava tokens never copied. Keep `is_shadowed` flags. Notifications table: disable/skip webhook triggers during load (`replica` role) so no pushes fire.
   - Refresh matviews (`vu_munros`, `mv_munros_commonly_climbed_with`) after load.
   - Safety: local webhooks must not email/push real people - edge fns use dev Firebase service account and no prod FCM tokens; set RESEND_API_KEY blank locally.
5. **Fresh dev user**: sign in with dev Firebase -> `on-user-created` path / app create users row; follow prod users to exercise feeds.
6. **Docs**: rewrite SETUP.md DB section (`supabase start`, reset, restore, tunnel); drop indexes.sql step; delete `supabase/indexes.sql`; note new dev flavour in DEVELOPER_WORKFLOW.md.
7. **Cutover**: verify app end-to-end locally, then pause/delete cloud dev project (keep until satisfied).

## Critical files
- `supabase/config.toml`, `supabase/migrations/` (new: strava RLS, webhook triggers, storage bucket), `supabase/seed.sql`
- `supabase/functions/*/index.ts`, `_shared/firebase-auth.ts` (needs FIREBASE_PROJECT_ID)
- `lib/screens/nav/state/strava_state.dart:60`, `lib/config/app_config.dart`, `config/*.json`
- `scripts/migrate_prod_to_dev.sh` (base for new restore script), `SETUP.md`

## Verification
- `supabase db reset` completes clean; `supabase db diff` against dev cloud shows no meaningful drift.
- Simulator on local flavour: Firebase login, feed loads with prod data, like/comment -> notification webhook fires (check `net._http_response` + edge logs), report -> email trigger path.
- Strava: connect flow via tunnel, historical scan, real activity upload -> webhook -> `jobs` row -> job processor.
- `flutter analyze`; user verifies UI manually (no simulator driving).

## Open items to confirm during execution
- Whether prod also has drift (user chose dev-only diff; prod webhooks/RLS assumed to match dev).
- Whether app uses Supabase Realtime (determines disabling realtime container).
- Dev Firebase project id for `[auth.third_party.firebase]`.
- Note: dev webhook trigger definitions contain a hardcoded service-role JWT - never copy into migrations; rotate if the repo/logs ever exposed it.
