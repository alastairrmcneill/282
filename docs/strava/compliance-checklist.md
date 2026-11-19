# Strava API compliance checklist

How 282 meets each part of the Strava API Agreement and API Policy (both effective 1 June 2026).
Section numbers are API Policy sections unless marked "Agreement".

Status key: ✅ done in code · 📄 done in docs or policy text · ⚠️ needs action from you · ❓ open question worth asking developers@strava.com

## Users and consent (Section 2)

| Clause | Requirement | How 282 meets it | Status |
| --- | --- | --- | --- |
| 2.1, 7.2 | Before connecting, tell the user what data is collected, how, how to withdraw consent, how to request deletion, and that deletion will be confirmed | `StravaDataDisclosure` is shown on the connect sheet and in onboarding, right above the official Connect button. It links to the privacy policy. | ✅ |
| 2.2 | Users can see the data we hold about them | Settings → Your Strava data (`StravaDataScreen`) lists the connection and every cached activity. Support email for a copy on request. | ✅ |
| 2.3, 6.1, 5.13, Agreement highlights | Strava Data shown only to that user | Strava data is only on owner-only screens. RLS limits every Strava table to `user_id = auth.jwt()->>'sub'`. Posts prefilled from a Strava activity start as **private**; choosing Friends/Public shows `StravaShareConsentDialog` first. | ✅ |
| 2.4 | Support contact and links to the user's Strava account | Support email on the Strava data screen. "View on Strava" links to the athlete profile and each activity. | ✅ |
| 2.5 | Delete on request or revocation, and give written confirmation | `strava-disconnect` deletes everything and returns a reference. `StravaDataDeletedDialog` shows the date, time and reference. The Strava data screen keeps showing the last confirmation. | ✅ |

## Access and rate limits (Section 3)

| Clause | Requirement | How 282 meets it | Status |
| --- | --- | --- | --- |
| 3.1, 3.7, 5.11 | Respect limits, don't circumvent, don't overburden | Webhooks, not polling. Every API response's rate-limit headers are saved to `strava_rate_limit_usage`. Non-essential work stops at 90% of any window, and a 429 defers jobs to the next 15-minute window. History scans fetch pages one at a time and are limited to once per athlete per 24 hours. | ✅ |
| 3.3 | Standard tier subscription requirement | You (or the specified users) need an active Strava subscription. | ⚠️ |
| 3.6 | Admission is discretionary | See `developer-program-application.md`. | 📄 |

## Brand (Section 4, Brand Guidelines)

| Clause | Requirement | How 282 meets it | Status |
| --- | --- | --- | --- |
| Guidelines | Official, unmodified "Connect with Strava" button that goes to `strava.com/oauth/authorize` | `ConnectWithStravaButton` renders the official PNG. The OAuth URL is built server-side in `strava-oauth-start`. | ⚠️ Add the PNGs to `assets/strava/` (see its README) |
| Guidelines | "Powered by Strava" logo wherever Strava data is shown | `PoweredByStravaLogo` on Found on Strava, the review sheet, the scan screen and Your Strava data. | ⚠️ Same assets |
| Guidelines | Link back to Strava reads "View on Strava" and is bold, underlined or `#FC5200` | `ViewOnStravaLink` is bold and `#FC5200`. | ✅ |
| 4.1 | No Strava mark in the app name, icon or logo | The app name and icon don't use any Strava mark. | ✅ |
| 4.3 | No implied endorsement | Terms say 282 isn't developed, sponsored or endorsed by Strava. | 📄 |
| 4.4 | Garmin attribution when showing Garmin-sourced data | `device_name` is stored with each cached activity. `GarminAttribution` shows the device name next to Garmin-recorded activities. | ✅ ❓ The history scan uses the list endpoint, which has no `device_name`, so scan results can't show it. Only the Munro name and date are shown there. |
| 4.6 | No press release mentioning Strava without written consent | Process point: don't announce "Strava integration" without approval. | ⚠️ |

## Use restrictions (Section 5)

| Clause | Requirement | How 282 meets it | Status |
| --- | --- | --- | --- |
| 5.2 | Don't compete with or imitate Strava | 282 is a Munro log and doesn't replicate Strava's feed, segments, routes or leaderboards. It sends users back to Strava with "View on Strava". | ✅ |
| 5.3 | No AI/ML use of Strava data, including context windows | No Strava data reaches any AI system. | ✅ |
| 5.4 | No analytics on Strava data | Mixpanel only records which Strava sheet was shown. When a post was prefilled from Strava, `createPost` leaves out the completion date, start time and duration properties (covered by a test). | ✅ |
| 5.5 | No bulk export or persistent index | Scan results are computed server-side and returned, never stored. Cached activities expire after 7 days. | ✅ |
| 5.7 | No storing geographic data beyond the 7-day cache | Polyline and start/end latlng columns are dropped. Routes are decoded in memory for matching only. | ✅ |
| 5.8 | Don't charge for Strava-powered features | Strava features are free. | ✅ |
| 5.10 | No transfer to third parties | Only Supabase and Firebase process data on our behalf (listed in the privacy policy). | 📄 |
| 5.16 | No proxy or MCP re-exposure | Not applicable. | ✅ |

## Data rights and retention (Section 6)

| Clause | Requirement | How 282 meets it | Status |
| --- | --- | --- | --- |
| 6.2, 6.4 | 7-day cache maximum, keep only as long as needed | Only activities that matched a Munro are stored, with `expires_at = now() + 7 days`. Hourly `purge_expired_strava_data()` (pg_cron) deletes expired activities and any whose matches have all been reviewed; matches cascade. Job payloads and webhook idempotency rows are purged too. | ✅ |
| 6.3 | Reflect Strava deletions within 48 hours | Webhook `delete` and `private: true` events delete the cached row straight away. | ✅ |
| 6.5 | Privacy policy says Strava may use Usage Data | Added to `website/src/pages/privacy.astro`. | 📄 |
| — | Confirmed Munros stay in the user's 282 log after disconnecting | The user confirms each Munro and it becomes their own log entry, like one logged by hand. | ❓ Worth confirming with Strava that a user-confirmed log entry isn't "Personal Data derived from Strava Data" under 7.4. |

## Privacy (Section 7)

| Clause | Requirement | How 282 meets it | Status |
| --- | --- | --- | --- |
| 7.1 | Respect privacy settings | Scope is `activity:read` (was `activity:read_all`), so "Only You" activities are invisible. If an activity is made private, its cached copy is deleted. | ✅ |
| 7.3 | GDPR / UK GDPR privacy policy | A Strava section has been added. ⚠️ The rest of the existing policy is generic boilerplate. For example, it says personal information "will be retained on your device and is not collected by me", which isn't accurate now that Supabase, Firebase, Mixpanel and Sentry are used. A full GDPR review is recommended before resubmitting. | 📄 ⚠️ |
| 7.4 | Delete within 30 days on revocation, account deletion or request | Deauthorisation webhook, disconnect, a refresh token rejected by Strava, or a 401 all call `deleteStravaDataForUser()` immediately. | ✅ |
| 7.7 | Subprocessor list on request | Supabase (EU/US, your project region) and Google Firebase. | 📄 |

## Security (Section 8)

| Clause | Requirement | How 282 meets it | Status |
| --- | --- | --- | --- |
| 8.1 | Appropriate security | RLS on all Strava tables; `anon` revoked. Tokens are AES-256-GCM encrypted at rest and are column-revoked from clients. Single-use, 10-minute OAuth `state` stops account-linking attacks. The webhook checks `subscription_id`, and the verify token has no fallback default. The job processor requires a shared secret. No tokens, Firebase ID tokens or Strava payloads are logged. | ✅ |
| 8.3 | Report breaches to legal@strava.com within 24 hours | Before this branch, RLS was off and `anon` could read `strava_connections`, including tokens. Check whether any of the tokens exposed by this were accessed, and if so notify Strava. Rotating them is recommended either way (see deployment step 6). | ⚠️ |
| 9.2 | Terms disclaim warranties on behalf of third-party providers | Added to `website/src/pages/terms.astro`. | 📄 |
