-- Created commonly climbed with materialized view. Refreshes in the index.sql
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_munros_commonly_climbed_with AS
WITH post_sizes AS (
  SELECT
    post_id,
    COUNT(*) AS post_count
  FROM munro_completions
  WHERE post_id IS NOT NULL
  GROUP BY post_id
),
trip_dedup AS (
  SELECT DISTINCT
         mc.user_id,
         mc.post_id,
         mc.munro_id
  FROM munro_completions mc
  JOIN post_sizes ps
    ON ps.post_id = mc.post_id
  WHERE mc.post_id IS NOT NULL
    AND ps.post_count <= 7          -- only "reasonable-sized" posts
),
pair_counts AS (
  SELECT
    LEAST(a.munro_id, b.munro_id)    AS munro1_id,
    GREATEST(a.munro_id, b.munro_id) AS munro2_id,
    COUNT(*) AS together_count,
    ARRAY_AGG(DISTINCT a.post_id) AS debug_post_ids
  FROM trip_dedup a
  JOIN trip_dedup b
    ON a.user_id = b.user_id
   AND a.post_id = b.post_id
   AND a.munro_id < b.munro_id
  GROUP BY 1, 2
),
directional AS (
  SELECT
    munro1_id        AS munro_id,
    munro2_id        AS climbed_with_id,
    together_count,
    debug_post_ids
  FROM pair_counts
  UNION ALL
  SELECT
    munro2_id        AS munro_id,
    munro1_id        AS climbed_with_id,
    together_count,
    debug_post_ids
  FROM pair_counts
),
max_counts AS (
  SELECT
    munro_id,
    MAX(together_count) AS max_together
  FROM directional
  GROUP BY munro_id
)
SELECT
  d.munro_id,
  m1.name AS munro_name,
  d.climbed_with_id,
  m2.name AS climbed_with_name,
  d.together_count,
  d.debug_post_ids
FROM directional d
JOIN max_counts mc
  ON mc.munro_id = d.munro_id
JOIN munros m1 ON m1.id = d.munro_id
JOIN munros m2 ON m2.id = d.climbed_with_id
WHERE
  d.together_count * 5 > mc.max_together    -- at least 20% of max
  AND d.together_count > 1
ORDER BY
  d.munro_id,
  d.together_count DESC,
  d.climbed_with_id;

-- Updated vu_munros to include commonly_climbed_with
CREATE OR REPLACE VIEW vu_munros AS
SELECT 
  m.*,
  COUNT(r.id)         AS reviews_count,
  AVG(r.rating)       AS average_rating,
  COALESCE(
    (
      SELECT json_agg(
        json_build_object(
          'munro_id', mccw.munro_id,
          'climbed_with_id', mccw.climbed_with_id,
          'together_count', mccw.together_count
        )
        ORDER BY mccw.together_count DESC, mccw.climbed_with_id
      )
      FROM mv_munros_commonly_climbed_with mccw
      WHERE mccw.munro_id = m.id
    ),
    '[]'::json
  ) AS commonly_climbed_with
FROM munros m
LEFT JOIN reviews r
  ON m.id = r.munro_id
GROUP BY
  m.id;

ALTER VIEW vu_munros SET (security_invoker = true, security_barrier = true);