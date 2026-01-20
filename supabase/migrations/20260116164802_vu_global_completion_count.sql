CREATE OR REPLACE VIEW vu_global_completion_count AS
SELECT
    COUNT(*) AS total_completions
FROM
    munro_completions;

ALTER VIEW vu_global_completion_count SET (security_invoker = true, security_barrier = true);