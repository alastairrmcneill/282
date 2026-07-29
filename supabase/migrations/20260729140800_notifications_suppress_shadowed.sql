-- ============================================================================
-- Shadowed test accounts, part 9/10: notifications + push.
--
-- Never create a notification sourced from a shadowed account. A BEFORE INSERT
-- trigger returning NULL cancels the insert, and Supabase DB webhooks are
-- AFTER INSERT triggers -- so cancelling here also stops on-notification-
-- created from firing, i.e. no FCM push is sent either. One trigger covers
-- likes, comments and follows.
--
-- Side effect: on-like-created / on-comment-created / on-follower-created do
-- `.insert(...).select().single()`, so when the row is dropped they log an
-- error and return 500. Harmless -- the like/comment/follow itself is already
-- committed -- but expect it in the edge function logs during a review pass.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.suppress_shadowed_notifications()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF NEW.source_id IS DISTINCT FROM NEW.target_id
     AND public.is_shadowed_user(NEW.source_id) THEN
    RETURN NULL;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_suppress_shadowed_notifications ON public.notifications;
CREATE TRIGGER trg_suppress_shadowed_notifications
BEFORE INSERT ON public.notifications
FOR EACH ROW
EXECUTE FUNCTION public.suppress_shadowed_notifications();
