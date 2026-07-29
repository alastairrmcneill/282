-- ============================================================================
-- Shadowed test accounts, part 8/10: get_post_enrichment() like/comment counts.
--
-- get_post_enrichment is SECURITY DEFINER and deliberately bypasses RLS on
-- likes/comments/munro_completions/users (see the header of
-- 20260714100300_replace_mv_post_card_with_live_view.sql for why). That means
-- the RLS changes in parts 3 and 4 of this batch do NOT reach the counts --
-- without this file a real user would see "1 like" on a post with no visible
-- liker. Filter has to be written out explicitly.
--
-- NOT EXISTS against users (PK lookup) rather than is_shadowed_user() to avoid
-- a per-row function call on posts with many likes. auth.jwt() still resolves
-- inside a SECURITY DEFINER function -- it reads a session GUC, not the
-- current role -- so the shadowed account still sees its own like counted.
--
-- Everything else in the function body is unchanged from
-- 20260714100300_replace_mv_post_card_with_live_view.sql.
-- ============================================================================

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
    (
      SELECT COUNT(*) FROM public.likes l
      WHERE l.post_id = p_post_id
        AND (
          l.user_id = (auth.jwt() ->> 'sub')
          OR NOT EXISTS (
            SELECT 1 FROM public.users su
            WHERE su.id = l.user_id AND su.is_shadowed
          )
        )
    ),
    (
      SELECT COUNT(*) FROM public.comments c
      WHERE c.post_id = p_post_id
        AND (
          c.author_id = (auth.jwt() ->> 'sub')
          OR NOT EXISTS (
            SELECT 1 FROM public.users su
            WHERE su.id = c.author_id AND su.is_shadowed
          )
        )
    ),
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
