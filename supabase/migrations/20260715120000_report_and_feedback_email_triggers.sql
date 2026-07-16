-- Email notifications: fire an edge function via pg_net whenever a row is
-- inserted into reports or app_feedbacks. This is a new pattern for this
-- repo (previous fan-out functions are wired via Dashboard Database
-- Webhooks) -- see 20260714100200_fix_user_fcm_tokens_trigger_search_path.sql
-- for why search_path is pinned on every SECURITY DEFINER trigger function.
--
-- Requires two one-off manual steps per environment (not run here, so no
-- secrets are committed to git): in the Supabase SQL editor, run
--   select vault.create_secret('<anon key>', 'edge_function_invoke_key');
--   select vault.create_secret('https://<project-ref>.supabase.co', 'edge_function_base_url');
-- so these triggers can authenticate against and reach the right project's
-- edge functions (base URL differs between the dev and prod projects).

CREATE EXTENSION IF NOT EXISTS pg_net;

CREATE OR REPLACE FUNCTION notify_report_created()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  invoke_key TEXT;
  base_url TEXT;
BEGIN
  SELECT decrypted_secret INTO invoke_key
  FROM vault.decrypted_secrets
  WHERE name = 'edge_function_invoke_key';

  SELECT decrypted_secret INTO base_url
  FROM vault.decrypted_secrets
  WHERE name = 'edge_function_base_url';

  PERFORM net.http_post(
    url := base_url || '/functions/v1/on-report-created',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || invoke_key
    ),
    body := jsonb_build_object(
      'type', 'INSERT',
      'table', 'reports',
      'schema', 'public',
      'record', row_to_json(NEW)
    )
  );

  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION notify_app_feedback_created()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  invoke_key TEXT;
  base_url TEXT;
BEGIN
  SELECT decrypted_secret INTO invoke_key
  FROM vault.decrypted_secrets
  WHERE name = 'edge_function_invoke_key';

  SELECT decrypted_secret INTO base_url
  FROM vault.decrypted_secrets
  WHERE name = 'edge_function_base_url';

  PERFORM net.http_post(
    url := base_url || '/functions/v1/on-app-feedback-created',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || invoke_key
    ),
    body := jsonb_build_object(
      'type', 'INSERT',
      'table', 'app_feedbacks',
      'schema', 'public',
      'record', row_to_json(NEW)
    )
  );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS report_created_notify ON reports;
CREATE TRIGGER report_created_notify
AFTER INSERT ON reports
FOR EACH ROW
EXECUTE FUNCTION notify_report_created();

DROP TRIGGER IF EXISTS app_feedback_created_notify ON app_feedbacks;
CREATE TRIGGER app_feedback_created_notify
AFTER INSERT ON app_feedbacks
FOR EACH ROW
EXECUTE FUNCTION notify_app_feedback_created();
