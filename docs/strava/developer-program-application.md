# Strava Developer Program application: 282

Draft answers for the athlete capacity / rate limit increase form. It targets the **Standard tier,
9,999-athlete level** (API Policy 3.3(a)). The Extended Access Tier is for apps with 10,000+
users, so leave that for a later application once the integration has a track record.

Fill in everything in `[brackets]` before submitting. Strava reviews what's live, so submit only
once this branch is in a public build (App Store / Play Store, or at least a TestFlight link in
the form), with the official brand assets in place.

---

## App details

- **App name:** 282
- **Strava API application ID:** 270263
- **Website:** https://282app.uk
- **Privacy policy:** https://282app.uk/privacy
- **Terms:** https://282app.uk/terms
- **iOS:** https://apps.apple.com/us/app/282/id6474512889
- **Android:** https://play.google.com/store/apps/details?id=com.alastairrmcneill.TwoEightTwo
- **Developer contact:** [name, email]
- **Current athlete capacity:** 10 · **Requested:** 9,999
- **Strava subscription held by the developer:** [Yes — required for the Standard tier, API Policy 3.3]

## What does your app do?

282 is a free iOS and Android app for people working through Scotland's 282 Munros (the
mountains over 3,000 ft). Users keep a log of the Munros they've climbed, plan their next one, and
see progress towards completing the list. It has [X] registered users and [Y] monthly active
users.

Most of our users already record their hill days on Strava, and the biggest complaint we hear is
having to log each summit again by hand in 282. The Strava integration fixes that. When an athlete
uploads a walk, hike or run to Strava, 282 checks the route against the summit locations of the
282 Munros. If it passed within [1 km] of a summit, 282 asks the athlete to confirm it. Nothing is
logged without the athlete confirming it. Athletes can also scan their Strava history once to pick
up Munros they climbed before they joined 282.

## How does it complement Strava?

- **It adds something Strava doesn't do.** Strava has no concept of a Munro list or of completing
  one. 282 doesn't replicate any Strava feature: no activity feed of Strava data, no segments, no
  leaderboards, no route planning from Strava data.
- **It gives people a reason to record on Strava.** Once connected, every hill day recorded on
  Strava ticks off Munros automatically, so recording on Strava becomes the easiest way to keep a
  282 log.
- **It sends people back to Strava.** Each activity 282 shows has a "View on Strava" link to the
  original, and each athlete's data page links to their Strava profile.
- **It's free.** 282 doesn't charge for anything, and the Strava features never will be paid.

## Which Strava data do you use, and how?

**Scope:** `activity:read` only. We moved off `activity:read_all`, so activities an athlete has set
to "Only You" are never visible to 282.

**Read:** the athlete ID, plus each activity's name, sport type, start date/time, elapsed time,
distance, elevation gain, maximum elevation, recording device and route.

**Use:** the route, start/end points and maximum elevation are used in memory to decide whether the
activity passed a Munro summit. **They are never stored.** If the activity matched, we cache the
name, type, date, time, distance, elevation gain and device so the athlete can review it. That
cache is deleted when they review it, or after 7 days, whichever is first. Activities that match
nothing aren't stored at all.

**Display:** Strava data is shown only to the athlete it belongs to, on screens only they can see.
When an athlete confirms a Munro, 282 opens its normal "log a Munro" screen prefilled with the date,
start time and duration. That post defaults to **private**. If the athlete chooses to make it
visible to friends or everyone, 282 first tells them which Strava-derived details that would share
and asks for consent.

**Never:** shown to other users, used for analytics, sold, shared with third parties, used in
advertising, or used in any AI or machine-learning system.

## How is your API usage optimised?

- **Webhooks, not polling.** New activities come from the push subscription. Each `create` event
  costs one `GET /activities/{id}`.
- **Events that can't change the result are ignored.** Title changes update our cache directly from
  the event payload with no API call. Only `type` / `sport_type` changes trigger a re-check.
  Deletions and activities made private are handled with no API call.
- **Duplicate deliveries are dropped.** Webhook events are de-duplicated on
  `(object_type, object_id, aspect_type, event_time)`, so retries never cause extra calls.
- **The webhook responds within 2 seconds.** It acknowledges immediately and does the work in the
  background.
- **The history scan is a one-off, and limited.** It uses `GET /athlete/activities` at
  `per_page=200`, fetches pages one at a time, matches on the server, and is limited to once per
  athlete per 24 hours. For a typical athlete with under 400 activities, that's 1–2 requests in
  total.
- **We back off before Strava has to throttle us.** We save the `X-RateLimit-*` and
  `X-ReadRateLimit-*` headers from every response. Background work pauses at 90% of any window, and
  a 429 defers queued work to the next 15-minute window rather than retrying.
- **Tokens are refreshed only when they're within 5 minutes of expiring.**

**Expected volume at 9,999 athletes:** about [0.4] uploaded activities per athlete per day gives
roughly [4,000] activity reads per day, spread across the day. On top of that, one-off history
scans add about [1–2] requests per newly connected athlete. [Adjust with your own numbers. If
the default limits would be exceeded, say which limit you're asking for and show the
calculation.]

## Security and privacy

- Access and refresh tokens are encrypted at rest (AES-256-GCM), held only server-side, and can't
  be read by the mobile app. The client secret is held only in server-side environment secrets.
- Row-level security restricts every Strava table to the athlete's own rows.
- The OAuth `state` is random, single-use and expires after 10 minutes, so an authorisation can't be
  replayed or attached to another 282 account.
- The webhook endpoint checks the subscription id, and the background worker requires a shared
  secret.
- **Consent:** before the Strava authorisation screen, 282 explains what it reads, how, who can
  see it, how to withdraw consent and how deletion works, with a link to the privacy policy.
- **Access:** Settings → Your Strava data shows the connection and everything 282 currently holds
  from Strava.
- **Deletion:** disconnecting in 282, revoking 282 on strava.com (deauthorisation webhook), or
  deleting the Strava account all permanently delete every piece of Strava data 282 holds for that
  athlete straight away. The app shows a written confirmation with the date and a reference.
  Deletions on Strava are reflected immediately via the webhook.
- **Processors:** Supabase (database and server functions) and Google Firebase (sign-in).

## Brand guidelines

- Connecting uses the official, unmodified "Connect with Strava" button, linking to
  `https://www.strava.com/oauth/authorize`.
- The official "Powered by Strava" logo appears on every screen that shows Strava data.
- Links back use the text "View on Strava" in bold `#FC5200`.
- Device attribution is shown for Garmin-recorded activities (API Policy 4.4).
- The 282 name, icon and branding contain no Strava marks, and the terms state that 282 isn't
  developed, sponsored or endorsed by Strava.

## Screenshots to attach

Take these from a build with the official assets in place, in light mode, plus one in dark mode:

1. The connect sheet showing the disclosure and the official Connect with Strava button
2. Strava's authorisation screen showing only "View data about your activities"
3. Found on Strava: activity card with "View on Strava", the Garmin device name and "Powered by Strava"
4. The review sheet for one activity
5. Log a Munro screen showing visibility defaulting to Private
6. The "Share details from Strava?" consent dialog
7. History scan results with "Powered by Strava"
8. Settings → Your Strava data
9. The disconnect confirmation and the "Strava disconnected" deletion confirmation

A 60–90 second screen recording of steps 1 → 9 is worth including if the form takes a link.
