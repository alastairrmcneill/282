-- ============================================================================
-- Shadowed test accounts, part 3/10: likes.
--
-- The shadowed account still sees its own likes (so the heart stays filled
-- for the reviewer); nobody else can read the row.
-- ============================================================================

DROP POLICY IF EXISTS "likes_read_authenticated_anon" ON likes;
CREATE POLICY "likes_read_authenticated_anon"
ON likes
FOR SELECT
TO anon, authenticated
USING (
  user_id = (select auth.jwt() ->> 'sub')
  OR (
    NOT public.is_shadowed_user(user_id)
    AND public.is_profile_public_or_self(user_id, (select auth.jwt() ->> 'sub'))
  )
);
