-- ============================================================================
-- Shadowed test accounts, part 2/10: users.
--
-- A shadowed profile is only selectable by itself, so it never turns up in
-- user search (vu_user_search is security_invoker over users) or on anyone
-- else's profile screen. This also acts as a second layer under
-- vu_notifications, which drops rows whose source user has no display_name.
-- ============================================================================

DROP POLICY IF EXISTS "users_public_or_self_selectable" ON users;
CREATE POLICY "users_public_or_self_selectable"
ON users
FOR SELECT
TO anon, authenticated
USING (
  (profile_visibility = 'public' AND NOT is_shadowed)
  OR id = (select auth.jwt() ->> 'sub')
);
