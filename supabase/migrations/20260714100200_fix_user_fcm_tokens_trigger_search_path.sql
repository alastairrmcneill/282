-- Fix mutable search_path on the user_fcm_tokens updated_at trigger function
-- (282 Prod security advisor: function_search_path_mutable). Safe -- its only
-- unqualified call is NOW(), resolved via pg_catalog regardless of search_path.
ALTER FUNCTION public.update_user_fcm_tokens_updated_at() SET search_path = '';
