CREATE OR REPLACE view vu_munros AS
SELECT 
  m.*,
  COUNT(r.id)         AS reviews_count,
  AVG(r.rating)       AS average_rating
FROM munros m
LEFT JOIN reviews r
  ON m.id = r.munro_id
GROUP BY
  m.id;

ALTER VIEW vu_munros SET (security_invoker = true, security_barrier = true);