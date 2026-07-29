-- ============================================================================
-- Shadowed test accounts, part 5/10: munro reviews.
--
-- vu_munro_ratings_breakdown is security_invoker over reviews, so hiding the
-- row here also keeps a review-account rating out of every munro's average.
-- ============================================================================

DROP POLICY IF EXISTS "reviews_read_authenticated_anon" ON reviews;
CREATE POLICY "reviews_read_authenticated_anon"
ON reviews
FOR SELECT
TO anon, authenticated
USING (
  author_id = (select auth.jwt() ->> 'sub')
  OR (
    NOT public.is_shadowed_user(author_id)
    AND public.is_profile_public_or_self(author_id, (select auth.jwt() ->> 'sub'))
  )
);
