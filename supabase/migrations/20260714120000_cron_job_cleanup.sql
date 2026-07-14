-- ============================================================================
-- Consolidate matview refresh cron jobs to two canonical names (2026-07-14).
--
-- What went wrong: 20260714100100 assumed cron.schedule() would upsert the
-- existing jobs by name, but the long-lived environments had jobs under
-- DIFFERENT names than the migration used, so it created duplicates instead:
--
--   Prod before this migration (cron.job):
--     7  refresh_mv_post_card                               */5 min  ACTIVE
--        -> failing every 5 minutes since 20260714100300 deployed:
--           "ERROR: relation mv_post_card does not exist" (that migration
--           unscheduled 'refresh_mv_post_card_every_min', but the prod job
--           was named 'refresh_mv_post_card')
--     8  refresh_vu_munros                                  every 5m INACTIVE
--     9  refresh_mv_munros_climbed                          every 5m ACTIVE
--     13 refresh_mv_munros_commonly_climbed_with_every_min  hourly   ACTIVE
--     14 refresh_vu_munros_every_min                        hourly   ACTIVE
--   Dev: only the two *_every_min jobs (hourly).
--
-- End state everywhere: exactly two jobs, canonical names, hourly --
--   refresh_mv_munros_commonly_climbed_with  (minute 0)
--   refresh_vu_munros                        (minute 30, staggered so the
--                                             two refreshes never coincide)
--
-- The canonical names are unscheduled and recreated too (not just upserted):
-- cron.schedule() on an existing name updates schedule/command but leaves the
-- job's `active` flag alone -- prod's existing 'refresh_vu_munros' is
-- INACTIVE and would have stayed dormant under a plain upsert.
-- ============================================================================

DO $$
DECLARE
  job_name text;
BEGIN
  FOREACH job_name IN ARRAY ARRAY[
    -- stale post_card refreshers (matview dropped in 20260714100300)
    'refresh_mv_post_card',
    'refresh_mv_post_card_every_min',
    -- legacy / misnamed munro refreshers
    'refresh_mv_munros_climbed',
    'refresh_mv_munros_commonly_climbed_with_every_min',
    'refresh_vu_munros_every_min',
    -- canonical names: drop and recreate below so they come back ACTIVE
    'refresh_mv_munros_commonly_climbed_with',
    'refresh_vu_munros'
  ] LOOP
    BEGIN
      PERFORM cron.unschedule(job_name);
    EXCEPTION WHEN OTHERS THEN
      NULL; -- job doesn't exist in this environment
    END;
  END LOOP;
END $$;

SELECT cron.schedule(
  'refresh_mv_munros_commonly_climbed_with',
  '0 * * * *',
  'REFRESH MATERIALIZED VIEW CONCURRENTLY mv_munros_commonly_climbed_with;'
);

SELECT cron.schedule(
  'refresh_vu_munros',
  '30 * * * *',
  'REFRESH MATERIALIZED VIEW CONCURRENTLY vu_munros;'
);
