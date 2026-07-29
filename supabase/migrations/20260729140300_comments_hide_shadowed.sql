-- ============================================================================
-- Shadowed test accounts, part 4/10: comments.
-- ============================================================================

DROP POLICY IF EXISTS "comments_read_authenticated_anon" ON comments;
CREATE POLICY "comments_read_authenticated_anon"
ON comments
FOR SELECT
TO anon, authenticated
USING (
  author_id = (select auth.jwt() ->> 'sub')
  OR (
    NOT public.is_shadowed_user(author_id)
    AND public.is_profile_public_or_self(author_id, (select auth.jwt() ->> 'sub'))
  )
);
