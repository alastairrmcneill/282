CREATE OR REPLACE VIEW vu_saved_lists AS
SELECT
  l.*,
  coalesce(
    array_agg(m.munro_id ORDER BY m.date_time_added) FILTER (WHERE m.munro_id IS NOT NULL),
    '{}'::int[]
  )                                AS munro_ids
FROM saved_lists l
LEFT JOIN saved_list_munros m
  ON m.saved_list_id = l.id
GROUP BY l.id
ORDER BY l.date_time_created;
