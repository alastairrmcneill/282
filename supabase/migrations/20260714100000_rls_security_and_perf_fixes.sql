-- ============================================================================
-- RLS security + performance fixes (282 Prod audit, 2026-07-14)
--
-- 1. Helper functions to break RLS recursion (posts/munro_pictures -> followers
--    -> users nested EXISTS fan-out).
-- 2. Wrap every auth.jwt()/auth.uid() call in RLS policies as (select ...) so
--    Postgres caches it once per query via an InitPlan instead of re-evaluating
--    it per row.
-- 3. Swap the friends/profile-visibility EXISTS subqueries for the new helper
--    functions on tables affected by the recursion.
-- 4. Close the app_feedbacks/reports insert spoofing hole (anon still allowed).
-- 5. Drop the duplicate users_self_select policy.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Helper functions (SECURITY DEFINER, owned by the migration role which has
--    BYPASSRLS, so calling them from inside another table's policy does not
--    re-trigger followers'/users' own RLS).
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.is_connected(user_a text, user_b text)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.followers f
    WHERE (f.source_id = user_a AND f.target_id = user_b)
       OR (f.target_id = user_a AND f.source_id = user_b)
  );
$$;

CREATE OR REPLACE FUNCTION public.is_profile_public_or_self(target_user_id text, viewer_id text)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.users u
    WHERE u.id = target_user_id
      AND (u.profile_visibility = 'public' OR u.id = viewer_id)
  );
$$;

GRANT EXECUTE ON FUNCTION public.is_connected(text, text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.is_profile_public_or_self(text, text) TO anon, authenticated;

-- ---------------------------------------------------------------------------
-- 2a. users -- wrap + drop duplicate select policy
-- ---------------------------------------------------------------------------

DROP POLICY IF EXISTS "users_self_select" ON users;

DROP POLICY IF EXISTS "users_self_insert" ON users;
CREATE POLICY "users_self_insert"
ON users
FOR INSERT
TO authenticated
WITH CHECK (id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "users_self_update" ON users;
CREATE POLICY "users_self_update"
ON users
FOR UPDATE
TO authenticated
USING (id = (select auth.jwt() ->> 'sub'))
WITH CHECK (id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "users_self_delete" ON users;
CREATE POLICY "users_self_delete"
ON users
FOR DELETE
TO authenticated
USING (id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "users_public_or_self_selectable" ON users;
CREATE POLICY "users_public_or_self_selectable"
ON users
FOR SELECT
TO anon, authenticated
USING (
  profile_visibility = 'public'
  OR id = (select auth.jwt() ->> 'sub')
);

-- ---------------------------------------------------------------------------
-- 2b. blocked_users -- wrap
-- ---------------------------------------------------------------------------

DROP POLICY IF EXISTS "users_self_insert" ON blocked_users;
CREATE POLICY "users_self_insert"
ON blocked_users
FOR INSERT
TO authenticated
WITH CHECK (user_id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "users_self_update" ON blocked_users;
CREATE POLICY "users_self_update"
ON blocked_users
FOR UPDATE
TO authenticated
USING (user_id = (select auth.jwt() ->> 'sub'))
WITH CHECK (user_id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "users_self_delete" ON blocked_users;
CREATE POLICY "users_self_delete"
ON blocked_users
FOR DELETE
TO authenticated
USING (user_id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "blocked_users_visible_to_both" ON blocked_users;
CREATE POLICY "blocked_users_visible_to_both"
ON blocked_users
FOR SELECT
TO authenticated
USING (
  user_id = (select auth.jwt() ->> 'sub')
  OR blocked_user_id = (select auth.jwt() ->> 'sub')
);

-- ---------------------------------------------------------------------------
-- 2c. followers -- wrap (internal both-sides-public EXISTS kept as-is, not
--     part of the recursion chain being fixed below)
-- ---------------------------------------------------------------------------

DROP POLICY IF EXISTS "followers_select_policy" ON followers;
CREATE POLICY "followers_select_policy"
ON followers
FOR SELECT
TO authenticated
USING (
  source_id = (select auth.jwt() ->> 'sub')
  OR target_id = (select auth.jwt() ->> 'sub')
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
);

DROP POLICY IF EXISTS "followers_insert_policy" ON followers;
CREATE POLICY "followers_insert_policy"
ON followers
FOR INSERT
TO authenticated
WITH CHECK (source_id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "followers_delete_policy" ON followers;
CREATE POLICY "followers_delete_policy"
ON followers
FOR DELETE
TO authenticated
USING (source_id = (select auth.jwt() ->> 'sub'));

-- ---------------------------------------------------------------------------
-- 2d. notifications -- wrap (blocked_users NOT EXISTS logic kept as-is)
-- ---------------------------------------------------------------------------

DROP POLICY IF EXISTS "notifications_read_authenticated" ON notifications;
CREATE POLICY "notifications_read_authenticated"
ON notifications
FOR SELECT
TO authenticated
USING (
  target_id = (select auth.jwt() ->> 'sub')
  AND NOT EXISTS (
    SELECT 1
    FROM blocked_users b
    WHERE
      (b.user_id = target_id AND b.blocked_user_id = source_id)
      OR
      (b.user_id = source_id AND b.blocked_user_id = target_id)
  )
);

DROP POLICY IF EXISTS "notifications_update_authenticated" ON notifications;
CREATE POLICY "notifications_update_authenticated"
ON notifications
FOR UPDATE
TO authenticated
USING (
  target_id = (select auth.jwt() ->> 'sub')
  AND NOT EXISTS (
    SELECT 1
    FROM blocked_users b
    WHERE
      (b.user_id = target_id AND b.blocked_user_id = source_id)
      OR
      (b.user_id = source_id AND b.blocked_user_id = target_id)
  )
)
WITH CHECK (
  target_id = (select auth.jwt() ->> 'sub')
  AND NOT EXISTS (
    SELECT 1
    FROM blocked_users b
    WHERE
      (b.user_id = target_id AND b.blocked_user_id = source_id)
      OR
      (b.user_id = source_id AND b.blocked_user_id = target_id)
  )
);

-- ---------------------------------------------------------------------------
-- 2e. user_fcm_tokens -- wrap
-- ---------------------------------------------------------------------------

DROP POLICY IF EXISTS "user_fcm_tokens_self_select" ON user_fcm_tokens;
CREATE POLICY "user_fcm_tokens_self_select"
ON user_fcm_tokens
FOR SELECT
TO authenticated
USING (user_id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "user_fcm_tokens_self_insert" ON user_fcm_tokens;
CREATE POLICY "user_fcm_tokens_self_insert"
ON user_fcm_tokens
FOR INSERT
TO authenticated
WITH CHECK (user_id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "user_fcm_tokens_self_update" ON user_fcm_tokens;
CREATE POLICY "user_fcm_tokens_self_update"
ON user_fcm_tokens
FOR UPDATE
TO authenticated
USING (user_id = (select auth.jwt() ->> 'sub'))
WITH CHECK (user_id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "user_fcm_tokens_self_delete" ON user_fcm_tokens;
CREATE POLICY "user_fcm_tokens_self_delete"
ON user_fcm_tokens
FOR DELETE
TO authenticated
USING (user_id = (select auth.jwt() ->> 'sub'));

-- ---------------------------------------------------------------------------
-- 2f. saved_lists -- wrap
-- ---------------------------------------------------------------------------

DROP POLICY IF EXISTS "saved_lists_select_authenticated" ON saved_lists;
CREATE POLICY "saved_lists_select_authenticated"
ON saved_lists
FOR SELECT
TO authenticated
USING (user_id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "saved_lists_insert_authenticated" ON saved_lists;
CREATE POLICY "saved_lists_insert_authenticated"
ON saved_lists
FOR INSERT
TO authenticated
WITH CHECK (user_id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "saved_lists_update_authenticated" ON saved_lists;
CREATE POLICY "saved_lists_update_authenticated"
ON saved_lists
FOR UPDATE
TO authenticated
USING (user_id = (select auth.jwt() ->> 'sub'))
WITH CHECK (user_id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "saved_lists_delete_authenticated" ON saved_lists;
CREATE POLICY "saved_lists_delete_authenticated"
ON saved_lists
FOR DELETE
TO authenticated
USING (user_id = (select auth.jwt() ->> 'sub'));

-- ---------------------------------------------------------------------------
-- 2g. saved_list_munros -- wrap (ownership-via-saved_lists EXISTS kept as-is)
-- ---------------------------------------------------------------------------

DROP POLICY IF EXISTS "saved_list_munros_select_authenticated" ON saved_list_munros;
CREATE POLICY "saved_list_munros_select_authenticated"
ON saved_list_munros
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM saved_lists sl
    WHERE sl.id = saved_list_munros.saved_list_id
      AND sl.user_id = (select auth.jwt() ->> 'sub')
  )
);

DROP POLICY IF EXISTS "saved_list_munros_insert_authenticated" ON saved_list_munros;
CREATE POLICY "saved_list_munros_insert_authenticated"
ON saved_list_munros
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM saved_lists sl
    WHERE sl.id = saved_list_munros.saved_list_id
      AND sl.user_id = (select auth.jwt() ->> 'sub')
  )
);

DROP POLICY IF EXISTS "saved_list_munros_update_authenticated" ON saved_list_munros;
CREATE POLICY "saved_list_munros_update_authenticated"
ON saved_list_munros
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM saved_lists sl
    WHERE sl.id = saved_list_munros.saved_list_id
      AND sl.user_id = (select auth.jwt() ->> 'sub')
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM saved_lists sl
    WHERE sl.id = saved_list_munros.saved_list_id
      AND sl.user_id = (select auth.jwt() ->> 'sub')
  )
);

DROP POLICY IF EXISTS "saved_list_munros_delete_authenticated" ON saved_list_munros;
CREATE POLICY "saved_list_munros_delete_authenticated"
ON saved_list_munros
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM saved_lists sl
    WHERE sl.id = saved_list_munros.saved_list_id
      AND sl.user_id = (select auth.jwt() ->> 'sub')
  )
);

-- ---------------------------------------------------------------------------
-- 3a. posts -- wrap + recursion fix via is_connected()
-- ---------------------------------------------------------------------------

DROP POLICY IF EXISTS "posts_select_authenticated" ON posts;
CREATE POLICY "posts_select_authenticated"
ON posts
FOR SELECT
TO authenticated
USING (
  author_id = (select auth.jwt() ->> 'sub')
  OR privacy = 'public'
  OR (
    privacy = 'friends'
    AND public.is_connected(author_id, (select auth.jwt() ->> 'sub'))
  )
);

DROP POLICY IF EXISTS "posts_insert_authenticated" ON posts;
CREATE POLICY "posts_insert_authenticated"
ON posts
FOR INSERT
TO authenticated
WITH CHECK (author_id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "posts_update_authenticated" ON posts;
CREATE POLICY "posts_update_authenticated"
ON posts
FOR UPDATE
TO authenticated
USING (author_id = (select auth.jwt() ->> 'sub'))
WITH CHECK (author_id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "posts_delete_authenticated" ON posts;
CREATE POLICY "posts_delete_authenticated"
ON posts
FOR DELETE
TO authenticated
USING (author_id = (select auth.jwt() ->> 'sub'));

-- ---------------------------------------------------------------------------
-- 3b. munro_pictures -- wrap + recursion fix via is_connected()
-- ---------------------------------------------------------------------------

DROP POLICY IF EXISTS "munro_pictures_select_authenticated" ON munro_pictures;
CREATE POLICY "munro_pictures_select_authenticated"
ON munro_pictures
FOR SELECT
TO authenticated
USING (
  author_id = (select auth.jwt() ->> 'sub')
  OR privacy = 'public'
  OR (
    privacy = 'friends'
    AND public.is_connected(author_id, (select auth.jwt() ->> 'sub'))
  )
);

DROP POLICY IF EXISTS "munro_pictures_insert_authenticated" ON munro_pictures;
CREATE POLICY "munro_pictures_insert_authenticated"
ON munro_pictures
FOR INSERT
TO authenticated
WITH CHECK (author_id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "munro_pictures_update_authenticated" ON munro_pictures;
CREATE POLICY "munro_pictures_update_authenticated"
ON munro_pictures
FOR UPDATE
TO authenticated
USING (author_id = (select auth.jwt() ->> 'sub'))
WITH CHECK (author_id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "munro_pictures_delete_authenticated" ON munro_pictures;
CREATE POLICY "munro_pictures_delete_authenticated"
ON munro_pictures
FOR DELETE
TO authenticated
USING (author_id = (select auth.jwt() ->> 'sub'));

-- ---------------------------------------------------------------------------
-- 3c. likes -- wrap + recursion fix via is_profile_public_or_self()
-- ---------------------------------------------------------------------------

DROP POLICY IF EXISTS "likes_read_authenticated_anon" ON likes;
CREATE POLICY "likes_read_authenticated_anon"
ON likes
FOR SELECT
TO anon, authenticated
USING (
  user_id = (select auth.jwt() ->> 'sub')
  OR public.is_profile_public_or_self(user_id, (select auth.jwt() ->> 'sub'))
);

DROP POLICY IF EXISTS "likes_insert_authenticated" ON likes;
CREATE POLICY "likes_insert_authenticated"
ON likes
FOR INSERT
TO authenticated
WITH CHECK (user_id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "likes_delete_authenticated" ON likes;
CREATE POLICY "likes_delete_authenticated"
ON likes
FOR DELETE
TO authenticated
USING (user_id = (select auth.jwt() ->> 'sub'));

-- ---------------------------------------------------------------------------
-- 3d. comments -- wrap + recursion fix via is_profile_public_or_self()
-- ---------------------------------------------------------------------------

DROP POLICY IF EXISTS "comments_read_authenticated_anon" ON comments;
CREATE POLICY "comments_read_authenticated_anon"
ON comments
FOR SELECT
TO anon, authenticated
USING (
  author_id = (select auth.jwt() ->> 'sub')
  OR public.is_profile_public_or_self(author_id, (select auth.jwt() ->> 'sub'))
);

DROP POLICY IF EXISTS "comments_insert_authenticated" ON comments;
CREATE POLICY "comments_insert_authenticated"
ON comments
FOR INSERT
TO authenticated
WITH CHECK (author_id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "comments_update_authenticated" ON comments;
CREATE POLICY "comments_update_authenticated"
ON comments
FOR UPDATE
TO authenticated
USING (author_id = (select auth.jwt() ->> 'sub'))
WITH CHECK (author_id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "comments_delete_authenticated" ON comments;
CREATE POLICY "comments_delete_authenticated"
ON comments
FOR DELETE
TO authenticated
USING (author_id = (select auth.jwt() ->> 'sub'));

-- ---------------------------------------------------------------------------
-- 3e. reviews -- wrap + recursion fix via is_profile_public_or_self()
-- ---------------------------------------------------------------------------

DROP POLICY IF EXISTS "reviews_read_authenticated_anon" ON reviews;
CREATE POLICY "reviews_read_authenticated_anon"
ON reviews
FOR SELECT
TO anon, authenticated
USING (
  author_id = (select auth.jwt() ->> 'sub')
  OR public.is_profile_public_or_self(author_id, (select auth.jwt() ->> 'sub'))
);

DROP POLICY IF EXISTS "reviews_insert_authenticated" ON reviews;
CREATE POLICY "reviews_insert_authenticated"
ON reviews
FOR INSERT
TO authenticated
WITH CHECK (author_id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "reviews_update_authenticated" ON reviews;
CREATE POLICY "reviews_update_authenticated"
ON reviews
FOR UPDATE
TO authenticated
USING (author_id = (select auth.jwt() ->> 'sub'))
WITH CHECK (author_id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "reviews_delete_authenticated" ON reviews;
CREATE POLICY "reviews_delete_authenticated"
ON reviews
FOR DELETE
TO authenticated
USING (author_id = (select auth.jwt() ->> 'sub'));

-- ---------------------------------------------------------------------------
-- 3f. munro_completions -- wrap + recursion fix via is_profile_public_or_self()
-- ---------------------------------------------------------------------------

DROP POLICY IF EXISTS "munro_completions_read_authenticated_anon" ON munro_completions;
CREATE POLICY "munro_completions_read_authenticated_anon"
ON munro_completions
FOR SELECT
TO anon, authenticated
USING (
  user_id = (select auth.jwt() ->> 'sub')
  OR public.is_profile_public_or_self(user_id, (select auth.jwt() ->> 'sub'))
);

DROP POLICY IF EXISTS "munro_completions_insert_authenticated" ON munro_completions;
CREATE POLICY "munro_completions_insert_authenticated"
ON munro_completions
FOR INSERT
TO authenticated
WITH CHECK (user_id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "munro_completions_update_authenticated" ON munro_completions;
CREATE POLICY "munro_completions_update_authenticated"
ON munro_completions
FOR UPDATE
TO authenticated
USING (user_id = (select auth.jwt() ->> 'sub'))
WITH CHECK (user_id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "munro_completions_delete_authenticated" ON munro_completions;
CREATE POLICY "munro_completions_delete_authenticated"
ON munro_completions
FOR DELETE
TO authenticated
USING (user_id = (select auth.jwt() ->> 'sub'));

-- ---------------------------------------------------------------------------
-- 3g. user_achievements -- wrap + recursion fix via is_profile_public_or_self()
--     (no delete policy exists on this table)
-- ---------------------------------------------------------------------------

DROP POLICY IF EXISTS "user_achievements_read_authenticated" ON user_achievements;
CREATE POLICY "user_achievements_read_authenticated"
ON user_achievements
FOR SELECT
TO authenticated
USING (
  user_id = (select auth.jwt() ->> 'sub')
  OR public.is_profile_public_or_self(user_id, (select auth.jwt() ->> 'sub'))
);

DROP POLICY IF EXISTS "user_achievements_insert_authenticated" ON user_achievements;
CREATE POLICY "user_achievements_insert_authenticated"
ON user_achievements
FOR INSERT
TO authenticated
WITH CHECK (user_id = (select auth.jwt() ->> 'sub'));

DROP POLICY IF EXISTS "user_achievements_update_authenticated" ON user_achievements;
CREATE POLICY "user_achievements_update_authenticated"
ON user_achievements
FOR UPDATE
TO authenticated
USING (user_id = (select auth.jwt() ->> 'sub'))
WITH CHECK (user_id = (select auth.jwt() ->> 'sub'));

-- ---------------------------------------------------------------------------
-- 4. Close app_feedbacks/reports insert spoofing (anon stays allowed)
-- ---------------------------------------------------------------------------

DROP POLICY IF EXISTS "app_feedbacks_insert" ON app_feedbacks;
CREATE POLICY "app_feedbacks_insert"
ON app_feedbacks
FOR INSERT
TO anon, authenticated
WITH CHECK (
  user_id = (select auth.jwt() ->> 'sub')
  OR (user_id IS NULL AND (select auth.jwt() ->> 'sub') IS NULL)
);

DROP POLICY IF EXISTS "reports_insert" ON reports;
CREATE POLICY "reports_insert"
ON reports
FOR INSERT
TO anon, authenticated
WITH CHECK (reporter_id = (select auth.jwt() ->> 'sub'));
