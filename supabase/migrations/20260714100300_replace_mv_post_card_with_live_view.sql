-- ============================================================================
-- Replace mv_post_card (materialized, 1-minute cron refresh, no RLS) with a
-- live, privacy-aware view (282 Prod audit, 2026-07-14).
--
-- Real bug fixed: vu_posts was `SELECT * FROM mv_post_card` with zero privacy
-- filtering -- since materialized views can't carry RLS, any caller could read
-- any other user's private/friends-only post via vu_posts (used directly by
-- lib/repos/posts_repository.dart's readPostFromUid and readPostsFromUserId).
--
-- Two-layer design per feed (global + friends), each split into:
--   - a thin "*_base" view touching posts/followers directly (no expensive
--     columns), so the outer caller's ORDER BY + LIMIT/OFFSET can be pushed
--     all the way down to an index scan and stop early.
--   - a heavy enrichment view on top, computing per-post aggregates via a
--     SECURITY DEFINER function, evaluated only for the rows that survive
--     the LIMIT (not the entire matching set).
--
-- RLS is enforced by `posts` itself (FORCE ROW LEVEL SECURITY + security_
-- invoker propagating the caller's role) -- this is a table-level guarantee,
-- independent of any view's security_barrier setting. security_barrier is
-- only needed when a VIEW has its own hand-written WHERE-clause-style
-- filtering that isn't backed by RLS (none of these views do -- privacy
-- IN ('public','friends') is a feed-curation choice, not a secrecy filter,
-- since privacy is already a visible column). None of the views below use
-- security_barrier; verified this doesn't leak friends-only/private posts to
-- a non-connected viewer (see plan verification notes).
--
-- Why a SECURITY DEFINER function for the aggregates (not a plain join under
-- security_invoker): likes/comments/munro_completions/users all have their
-- own RLS. If the enrichment view joined them directly under security_
-- invoker, a like or comment from a private-profile user would be invisible
-- to the counting subquery for any other viewer -- silently under-counting
-- likes/comments, and a friends-only post from a private-profile author
-- could lose its author_display_name entirely (users' RLS has no "connected
-- via followers" clause, only public-or-self). The old matview avoided this
-- by bypassing RLS for these aggregates entirely; get_post_enrichment() does
-- the same on purpose, matching prior behaviour. Only the "*_base" views gate
-- row visibility.
--
-- Iteration history (both found empirically on 282 Dev, not guessed):
--   1. First attempt: single security_barrier view with the aggregates
--      inline. Caused the global feed to time out -- EXPLAIN showed all 9
--      correlated subqueries running for all ~15,656 public posts before the
--      outer LIMIT ever applied, because security_barrier disables the usual
--      "defer expensive SELECT-list expressions past LIMIT" pushdown.
--   2. Second attempt: moved the aggregates into get_post_enrichment(), kept
--      security_barrier on the thin base view. Cost estimate looked great
--      (opaque function call looks cheap to the planner) but real EXPLAIN
--      ANALYZE showed it still ran the function for all ~15,755 rows (5.1s)
--      -- security_barrier on the *base* view was still blocking the same
--      pushdown, just one layer down.
--   3. Fix: security_invoker only (no security_barrier) on the base views --
--      RLS is already enforced by FORCE ROW LEVEL SECURITY on posts/
--      followers regardless. Global feed: 7ms, function called only 10
--      times, using idx_posts_privacy_created directly. Access control
--      re-verified correct (connected follower sees a friends-only post,
--      non-connected user does not) with security_barrier removed.
--   4. Friends feed needed its own thin base (vu_friends_feed_base) joining
--      followers -> vu_posts_base directly, rather than joining followers to
--      the already-enriched vu_posts -- otherwise the enrichment function
--      still ran once per matching post system-wide before the followers
--      join/limit resolved.
-- ============================================================================

-- 1. Unschedule the old refresh job (safe no-op on a fresh database where it
--    never existed).
DO $$
BEGIN
  PERFORM cron.unschedule('refresh_mv_post_card_every_min');
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;

-- 2. Drop the materialized view. Cascades to vu_posts/vu_global_feed/
--    vu_friends_feed (recreated below) and mv_post_card's own indexes
--    (nothing else to clean up there).
DROP MATERIALIZED VIEW IF EXISTS mv_post_card CASCADE;

-- 3. Heavy per-post aggregates, computed only for the rows that make it past
--    the outer LIMIT. SECURITY DEFINER + bypasses likes/comments/
--    munro_completions/users RLS on purpose (see note above).
-- CREATE TYPE has no IF NOT EXISTS -- drop first so this migration is
-- re-runnable (CASCADE also drops get_post_enrichment() and any dependent
-- views, all of which are recreated below in the same file).
DROP TYPE IF EXISTS public.post_enrichment CASCADE;

CREATE TYPE public.post_enrichment AS (
  author_display_name text,
  author_profile_picture_url text,
  likes bigint,
  comments bigint,
  included_munro_ids int[],
  date_time_completed timestamptz,
  completion_date date,
  completion_start_time time,
  completion_duration integer,
  image_urls jsonb,
  munro_count_at_post_date_time bigint
);

CREATE OR REPLACE FUNCTION public.get_post_enrichment(p_post_id uuid, p_author_id text)
RETURNS public.post_enrichment
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT
    u.display_name,
    u.profile_picture_url,
    (SELECT COUNT(*) FROM public.likes l WHERE l.post_id = p_post_id),
    (SELECT COUNT(*) FROM public.comments c WHERE c.post_id = p_post_id),
    (
      SELECT ARRAY_AGG(DISTINCT mc.munro_id ORDER BY mc.munro_id)
      FROM public.munro_completions mc
      WHERE mc.post_id = p_post_id
    ),
    (
      SELECT (min(mc.date_time_completed))::TIMESTAMPTZ
      FROM public.munro_completions mc
      WHERE mc.post_id = p_post_id
    ),
    (
      SELECT (min(mc.completion_date))::DATE
      FROM public.munro_completions mc
      WHERE mc.post_id = p_post_id
    ),
    (
      SELECT (min(mc.completion_start_time))::TIME
      FROM public.munro_completions mc
      WHERE mc.post_id = p_post_id
    ),
    (
      SELECT (min(mc.completion_duration))::INTEGER
      FROM public.munro_completions mc
      WHERE mc.post_id = p_post_id
    ),
    (
      SELECT JSONB_OBJECT_AGG(s.munro_id, s.url_list ORDER BY s.munro_id)
      FROM (
        SELECT
          mp.munro_id,
          jsonb_agg(mp.image_url ORDER BY mp.date_time_created) AS url_list
        FROM public.munro_pictures mp
        WHERE mp.post_id = p_post_id
        GROUP BY mp.munro_id
      ) s
    ),
    (
      WITH post_cutoff AS (
        SELECT
          min(mc.date_time_completed) AS completed_at,
          max(mc.date_time_created)  AS created_cutoff
        FROM public.munro_completions mc
        WHERE mc.post_id = p_post_id
      )
      SELECT count(DISTINCT mc2.munro_id)
      FROM public.munro_completions mc2
      CROSS JOIN post_cutoff pc
      WHERE mc2.user_id = p_author_id
        AND (
          mc2.date_time_completed < pc.completed_at
          OR (
            mc2.date_time_completed = pc.completed_at
            AND mc2.date_time_created <= pc.created_cutoff
          )
        )
    )
  FROM public.users u
  WHERE u.id = p_author_id;
$$;

GRANT EXECUTE ON FUNCTION public.get_post_enrichment(uuid, text) TO anon, authenticated;

-- 4. Thin, RLS-gating base view for the global feed / single-post reads. No
--    expensive columns, no security_barrier (see header note) -- this is what
--    lets the outer LIMIT pushdown work.
CREATE OR REPLACE VIEW vu_posts_base AS
SELECT
  p.id,
  p.author_id,
  p.title,
  p.description,
  p.date_time_created,
  p.privacy
FROM posts p;

ALTER VIEW vu_posts_base SET (security_invoker = true);

-- 5. Enrichment layer. Reads only from vu_posts_base (already RLS-filtered)
--    and get_post_enrichment(); no security_barrier needed here either, since
--    it does no RLS-sensitive filtering of its own.
CREATE OR REPLACE VIEW vu_posts AS
SELECT
  b.id,
  b.author_id,
  b.title,
  b.description,
  b.date_time_created,
  b.privacy,
  e.author_display_name,
  e.author_profile_picture_url,
  e.likes,
  e.comments,
  e.included_munro_ids,
  e.date_time_completed,
  e.completion_date,
  e.completion_start_time,
  e.completion_duration,
  e.image_urls,
  e.munro_count_at_post_date_time
FROM vu_posts_base b
CROSS JOIN LATERAL public.get_post_enrichment(b.id, b.author_id) e;

ALTER VIEW vu_posts SET (security_invoker = true);

CREATE OR REPLACE VIEW vu_global_feed AS
SELECT *
FROM vu_posts
WHERE privacy = 'public';

ALTER VIEW vu_global_feed SET (security_invoker = true);

-- 6. Friends feed gets its OWN thin base, joining followers -> vu_posts_base
--    directly. Joining followers to the already-enriched vu_posts instead
--    (i.e. `FROM followers f JOIN vu_posts m ON ...`) forced the enrichment
--    function to run once per matching post system-wide (~15,806 calls,
--    5.7s) before the followers join / LIMIT resolved -- confirmed via
--    EXPLAIN ANALYZE on 282 Dev.
CREATE OR REPLACE VIEW vu_friends_feed_base AS
SELECT f.source_id AS user_id, b.*
FROM followers f
JOIN vu_posts_base b ON b.author_id = f.target_id
WHERE b.privacy IN ('public','friends');

ALTER VIEW vu_friends_feed_base SET (security_invoker = true);

CREATE OR REPLACE VIEW vu_friends_feed AS
SELECT
  b.user_id,
  b.id,
  b.author_id,
  b.title,
  b.description,
  b.date_time_created,
  b.privacy,
  e.author_display_name,
  e.author_profile_picture_url,
  e.likes,
  e.comments,
  e.included_munro_ids,
  e.date_time_completed,
  e.completion_date,
  e.completion_start_time,
  e.completion_duration,
  e.image_urls,
  e.munro_count_at_post_date_time
FROM vu_friends_feed_base b
CROSS JOIN LATERAL public.get_post_enrichment(b.id, b.author_id) e;

ALTER VIEW vu_friends_feed SET (security_invoker = true);

-- 7. Drop the dead, security_invoker-less duplicate view. Copy-paste bug in
--    20260205122351_onboarding_views.sql: it duplicates vu_onboarding_feed's
--    query, but the ALTER VIEW ... SET (security_invoker = true) right after
--    it targets vu_onboarding_feed again, not vu_. Never queried by the app
--    (only vu_onboarding_feed/vu_onboarding_totals/vu_onboarding_achievements
--    are) -- safe to drop.
DROP VIEW IF EXISTS vu_ CASCADE;
