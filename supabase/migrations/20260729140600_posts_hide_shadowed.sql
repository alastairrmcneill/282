-- ============================================================================
-- Shadowed test accounts, part 7/10: posts.
--
-- Keeps anything the review account or the Robo crawler posts out of the
-- global and friends feeds (both are security_invoker views over posts).
-- ============================================================================

DROP POLICY IF EXISTS "posts_select_authenticated" ON posts;
CREATE POLICY "posts_select_authenticated"
ON posts
FOR SELECT
TO authenticated
USING (
  author_id = (select auth.jwt() ->> 'sub')
  OR (
    NOT public.is_shadowed_user(author_id)
    AND (
      privacy = 'public'
      OR (
        privacy = 'friends'
        AND public.is_connected(author_id, (select auth.jwt() ->> 'sub'))
      )
    )
  )
);
