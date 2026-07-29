-- ============================================================================
-- Shadowed test accounts, part 1/10: the flag + helper function.
--
-- Problem: the App Store review account and Google Play's automated Robo
-- crawler sign in as a real user ("Tester 1") and then follow people, like
-- posts and comment. Real users get push notifications and see the activity
-- every time a build is uploaded.
--
-- Fix: a per-user `is_shadowed` flag. A shadowed user's social activity stays
-- fully visible to *themselves* (so the reviewer/crawler sees a normal,
-- working app) and is invisible to everyone else. Subsequent migrations in
-- this batch apply the flag to users/likes/comments/reviews/followers/posts,
-- to the post enrichment counts, and to notification creation.
-- ============================================================================

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS is_shadowed boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN public.users.is_shadowed IS
  'Test/review account. Social activity is visible only to the account itself.';

-- SECURITY DEFINER so calling this from inside another table's RLS policy does
-- not re-trigger users' own RLS (same pattern as is_profile_public_or_self in
-- 20260714100000_rls_security_and_perf_fixes.sql).
CREATE OR REPLACE FUNCTION public.is_shadowed_user(p_user_id text)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.users u
    WHERE u.id = p_user_id AND u.is_shadowed
  );
$$;

GRANT EXECUTE ON FUNCTION public.is_shadowed_user(text) TO anon, authenticated;
