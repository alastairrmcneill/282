CREATE OR REPLACE VIEW vu_munros_by_height AS
SELECT m.*,
       DENSE_RANK() OVER (ORDER BY m.feet DESC) AS height_rank_desc,
       DENSE_RANK() OVER (ORDER BY m.feet ASC)  AS height_rank_asc
FROM munros m;

ALTER VIEW vu_munros_by_height SET (security_invoker = true, security_barrier = true);