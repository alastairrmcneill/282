CREATE OR REPLACE VIEW vu_munro_ratings_breakdown AS
SELECT
  r.munro_id,
  COUNT(r.*) FILTER (WHERE rating = 5) AS rating_5_count,
  COUNT(r.*) FILTER (WHERE rating = 4) AS rating_4_count,
  COUNT(r.*) FILTER (WHERE rating = 3) AS rating_3_count,
  COUNT(r.*) FILTER (WHERE rating = 2) AS rating_2_count,
  COUNT(r.*) FILTER (WHERE rating = 1) AS rating_1_count,
  COUNT(r.*) AS total_reviews_count,
  AVG(r.rating) AS average_rating
FROM reviews r
GROUP BY munro_id
ORDER BY munro_id;

ALTER VIEW vu_munro_ratings_breakdown SET (security_invoker = true, security_barrier = true);
