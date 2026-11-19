# Deploying the Strava compliance changes

Nothing on this branch has been applied to Supabase. Do these steps in order.

## 1. Brand assets

Download the official assets from https://developers.strava.com/guidelines/ and add them to
`assets/strava/`. The file names are listed in `assets/strava/README.md`. Until then the app shows
text fallbacks, which aren't compliant.

## 2. Edge function secrets

```bash
supabase secrets set STRAVA_TOKEN_ENCRYPTION_KEY="$(openssl rand -base64 32)"
```

```bash
supabase secrets set STRAVA_JOB_PROCESSOR_SECRET="$(openssl rand -hex 32)"
```

```bash
supabase secrets set STRAVA_VERIFY_TOKEN="$(openssl rand -hex 24)"
```

Already set and still needed: `STRAVA_CLIENT_ID`, `STRAVA_CLIENT_SECRET`, `FIREBASE_PROJECT_ID`.
`STRAVA_REDIRECT_URI` is optional and defaults to `<SUPABASE_URL>/functions/v1/strava-connect`.

Keep `STRAVA_TOKEN_ENCRYPTION_KEY` safe. Losing it means every athlete has to reconnect.

## 3. Vault secrets used by the job-processor cron

Run once in the SQL editor:

```sql
select vault.create_secret('https://pqgaczyxzxopkgyjqudk.supabase.co', 'project_url');
select vault.create_secret('<same value as STRAVA_JOB_PROCESSOR_SECRET>', 'strava_job_processor_secret');
```

## 4. Migration

Apply `supabase/migrations/20261119090000_strava_api_compliance.sql`. It:
- turns on RLS for every Strava table and revokes `anon` access (closes the token exposure)
- drops `polyline`, `start_latlng`, `end_latlng` and `elev_high_m` from `strava_activities`
- adds `strava_oauth_states`, `strava_webhook_events_processed`, `strava_rate_limit_usage` and `strava_data_deletions`
- schedules `purge_expired_strava_data` hourly and `run_strava_job_processor` every minute

The old app build reads `strava_connections` with `select *`. Once the token columns are revoked,
that call fails, so older builds will show "Error with Strava connection". That's expected while
this is unreleased.

## 5. Deploy the functions

Deploy the shared code changes and every Strava function together:

```bash
supabase functions deploy strava-oauth-start strava-connect strava-disconnect strava-webhook strava-job-processor strava-scan-activities
```

`on-app-feedback-created` was overwritten with webhook test code on `21-strava`. This branch
restores it from `main`, so redeploy it too:

```bash
supabase functions deploy on-app-feedback-created
```

## 6. Webhook subscription

Strava allows one subscription per app. If one exists, delete it and create a new one so it uses the
new verify token. Then save its id:

```bash
supabase secrets set STRAVA_SUBSCRIPTION_ID="<id returned by Strava>"
```

## 7. Rotate the exposed tokens

RLS was off, and `anon` could read `strava_connections` until step 4. For each connected athlete
(you and any testers), either disconnect and reconnect in the app, or revoke 282 at
https://www.strava.com/settings/apps and reconnect. Reconnecting stores fresh, encrypted tokens.
Check the API logs for unexpected reads of `strava_connections`, and if you find any, email
legal@strava.com within 24 hours (API Policy 8.3).

## 8. Smoke test

- Connect from Settings. The disclosure appears and Strava's consent screen asks only for "View data about your activities".
- Untick the activity permission on Strava's screen. The app explains it's needed.
- Record or upload a hike over a Munro. Within a minute it appears in Found on Strava, with "View on Strava" and "Powered by Strava".
- Rename the activity on Strava. The cached name updates without an API call (check `strava_rate_limit_usage` usage doesn't move).
- Delete the activity on Strava. It disappears from Found on Strava.
- Confirm a match. The post defaults to Private, and switching to Public asks for consent.
- Scan your history. Scan again: the second scan is refused for 24 hours.
- Disconnect. A confirmation with a reference appears, all your Strava rows are gone, and `strava_data_deletions` has a row.
- Revoke 282 on strava.com. The deauthorisation webhook deletes your data.
