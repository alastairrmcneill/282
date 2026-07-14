-- ============================================================================
-- Keyset-paginated feed RPCs (282 feed performance work, 2026-07-14).
--
-- Why (measured on 282 Dev):
--   - OFFSET pagination on vu_global_feed: the LATERAL get_post_enrichment()
--     call runs for every skipped row before OFFSET discards it. Page at
--     OFFSET 500 = 510 enrichment calls = 1,127ms (vs 163ms at OFFSET 0).
--   - vu_friends_feed with an outer ORDER BY + LIMIT relies on the planner
--     choosing an index-ordered nested loop to stop early. For a user
--     following ~2,000 people it instead chose bitmap scan + top-N sort,
--     which forces enrichment for every candidate row first: 15,806 calls,
--     5,608ms for page 1.
--
-- Fix: RPCs that apply the keyset cursor + LIMIT in an inner subquery over
-- the thin *_base views, and only then CROSS JOIN LATERAL the enrichment
-- function. The LIMIT sits structurally below the lateral join, so
-- enrichment runs exactly `limit` times regardless of what plan the base
-- scan gets. Same queries re-measured with this shape: global feed at depth
-- 500 = 7ms, friends feed page 1 (heavy user) = 42ms.
--
-- Keyset cursor = (date_time_created, id) of the last post of the previous
-- page. Composite on purpose: date_time_created alone skips/duplicates posts
-- on timestamp ties. First page: both cursor params NULL.
--
-- Security: all three functions are SECURITY INVOKER (the default) -- row
-- visibility is enforced by FORCE ROW LEVEL SECURITY on posts/followers,
-- propagated through the security_invoker *_base views, exactly as for the
-- existing vu_* feed views. get_post_enrichment() stays the only SECURITY
-- DEFINER piece (see 20260714100300 for why).
--
-- Note: functions return explicit TABLE column lists (not SETOF vu_posts) so
-- they carry no pg_depend edge on the views -- a later DROP ... CASCADE of
-- vu_posts/post_enrichment won't silently drop these RPCs.
-- ============================================================================

-- --------------------------------------------------------------------------
-- 1. Indexes matching the keyset sort order (privacy/author leading column,
--    then the exact ORDER BY date_time_created DESC, id DESC). The existing
--    idx_posts_privacy_created / idx_posts_author_privacy_created stay in
--    place (kept per no-drop constraint; the old privacy index remains in
--    use by the RLS-era plans and single-post lookups).
-- --------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_posts_privacy_created_id
  ON posts (privacy, date_time_created DESC, id DESC);

CREATE INDEX IF NOT EXISTS idx_posts_author_created_id
  ON posts (author_id, date_time_created DESC, id DESC);

-- --------------------------------------------------------------------------
-- 2. Global feed: public posts, newest first, keyset-paginated.
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_global_feed(
  p_limit int DEFAULT 10,
  p_before_date_time timestamptz DEFAULT NULL,
  p_before_id uuid DEFAULT NULL,
  p_excluded_author_ids text[] DEFAULT NULL
)
RETURNS TABLE (
  id uuid,
  author_id text,
  title text,
  description text,
  date_time_created timestamptz,
  privacy text,
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
)
LANGUAGE sql
STABLE
SET search_path = ''
AS $$
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
  FROM (
    SELECT *
    FROM public.vu_posts_base p
    WHERE p.privacy = 'public'
      AND (
        p_excluded_author_ids IS NULL
        OR NOT (p.author_id = ANY (p_excluded_author_ids))
      )
      AND (
        p_before_date_time IS NULL
        OR (p_before_id IS NULL AND p.date_time_created < p_before_date_time)
        OR (p.date_time_created, p.id) < (p_before_date_time, p_before_id)
      )
    ORDER BY p.date_time_created DESC, p.id DESC
    LIMIT p_limit
  ) b
  CROSS JOIN LATERAL public.get_post_enrichment(b.id, b.author_id) e
  ORDER BY b.date_time_created DESC, b.id DESC;
$$;

-- --------------------------------------------------------------------------
-- 3. Friends feed: posts from people the caller follows. Caller identity
--    comes from the JWT, not a parameter -- no way to page someone else's
--    friends feed. vu_friends_feed_base already restricts to
--    privacy IN ('public','friends') and joins followers under RLS.
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_friends_feed(
  p_limit int DEFAULT 10,
  p_before_date_time timestamptz DEFAULT NULL,
  p_before_id uuid DEFAULT NULL,
  p_excluded_author_ids text[] DEFAULT NULL
)
RETURNS TABLE (
  id uuid,
  author_id text,
  title text,
  description text,
  date_time_created timestamptz,
  privacy text,
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
)
LANGUAGE sql
STABLE
SET search_path = ''
AS $$
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
  FROM (
    SELECT f.id, f.author_id, f.title, f.description, f.date_time_created, f.privacy
    FROM public.vu_friends_feed_base f
    WHERE f.user_id = (SELECT auth.jwt() ->> 'sub')
      AND (
        p_excluded_author_ids IS NULL
        OR NOT (f.author_id = ANY (p_excluded_author_ids))
      )
      AND (
        p_before_date_time IS NULL
        OR (p_before_id IS NULL AND f.date_time_created < p_before_date_time)
        OR (f.date_time_created, f.id) < (p_before_date_time, p_before_id)
      )
    ORDER BY f.date_time_created DESC, f.id DESC
    LIMIT p_limit
  ) b
  CROSS JOIN LATERAL public.get_post_enrichment(b.id, b.author_id) e
  ORDER BY b.date_time_created DESC, b.id DESC;
$$;

-- --------------------------------------------------------------------------
-- 4. A user's posts (profile page), keyset-paginated. Which of the author's
--    posts the caller may see (own/public/friends-connected) is decided by
--    the posts RLS policy through vu_posts_base -- no privacy filter here.
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_user_posts(
  p_user_id text,
  p_limit int DEFAULT 10,
  p_before_date_time timestamptz DEFAULT NULL,
  p_before_id uuid DEFAULT NULL
)
RETURNS TABLE (
  id uuid,
  author_id text,
  title text,
  description text,
  date_time_created timestamptz,
  privacy text,
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
)
LANGUAGE sql
STABLE
SET search_path = ''
AS $$
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
  FROM (
    SELECT *
    FROM public.vu_posts_base p
    WHERE p.author_id = p_user_id
      AND (
        p_before_date_time IS NULL
        OR (p_before_id IS NULL AND p.date_time_created < p_before_date_time)
        OR (p.date_time_created, p.id) < (p_before_date_time, p_before_id)
      )
    ORDER BY p.date_time_created DESC, p.id DESC
    LIMIT p_limit
  ) b
  CROSS JOIN LATERAL public.get_post_enrichment(b.id, b.author_id) e
  ORDER BY b.date_time_created DESC, b.id DESC;
$$;

-- --------------------------------------------------------------------------
-- 5. Grants. Friends feed is meaningless without a JWT sub -> authenticated
--    only. Global feed and profile posts follow the posts table grants
--    (anon may read public posts).
-- --------------------------------------------------------------------------
REVOKE ALL ON FUNCTION public.get_global_feed(int, timestamptz, uuid, text[]) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.get_friends_feed(int, timestamptz, uuid, text[]) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.get_user_posts(text, int, timestamptz, uuid) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.get_global_feed(int, timestamptz, uuid, text[]) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_friends_feed(int, timestamptz, uuid, text[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_posts(text, int, timestamptz, uuid) TO anon, authenticated;
