DROP VIEW IF EXISTS vu_munros;

CREATE OR REPLACE VIEW vu_munros AS
SELECT 
  m.*,
  COUNT(DISTINCT r.id)   AS reviews_count,
  AVG(r.rating)          AS average_rating,
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
  ) AS commonly_climbed_with,
  COUNT(DISTINCT mc.id) AS total_summit_count
FROM munros m
LEFT JOIN reviews r
  ON m.id = r.munro_id
LEFT JOIN munro_completions mc
  ON m.id = mc.munro_id
GROUP BY
  m.id;

ALTER VIEW vu_munros SET (security_invoker = true, security_barrier = true);