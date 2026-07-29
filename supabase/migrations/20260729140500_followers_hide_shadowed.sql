-- ============================================================================
-- Shadowed test accounts, part 6/10: followers.
--
-- This is the one that actually caused the reported spam. The previous policy
-- let the *target* read any row where target_id = them, unconditionally --
-- which is exactly how the review account's follows showed up on real users'
-- follower lists (and, via vu_profiles' security_invoker count, in their
-- follower count).
--
-- New rule:
--   - a shadowed account always sees its own outgoing follows;
--   - a shadowed account still sees its own incoming followers;
--   - everyone else only sees rows where neither side is shadowed.
-- ============================================================================

DROP POLICY IF EXISTS "followers_select_policy" ON followers;
CREATE POLICY "followers_select_policy"
ON followers
FOR SELECT
TO authenticated
USING (
  source_id = (select auth.jwt() ->> 'sub')
  OR (
    NOT public.is_shadowed_user(source_id)
    AND (
      NOT public.is_shadowed_user(target_id)
      OR target_id = (select auth.jwt() ->> 'sub')
    )
    AND (
      target_id = (select auth.jwt() ->> 'sub')
      OR (
        EXISTS (
          SELECT 1 FROM users us
          WHERE us.id = followers.source_id AND us.profile_visibility = 'public'
        )
        AND EXISTS (
          SELECT 1 FROM users ut
          WHERE ut.id = followers.target_id AND ut.profile_visibility = 'public'
        )
      )
    )
  )
);
