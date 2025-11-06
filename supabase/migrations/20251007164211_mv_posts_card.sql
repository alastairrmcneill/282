-- 1) one-time: the materialized view (no ORDER BY inside)
CREATE MATERIALIZED VIEW mv_post_card AS
SELECT 
  p.id,
  p.author_id,
  p.title,
  p.description,
  p.date_time_created,
  p.privacy,

  u.display_name        AS author_display_name,
  u.profile_picture_url AS author_profile_picture_url,

  -- cheap subselects (will be even cheaper with the indexes you add)
  (SELECT COUNT(*) FROM likes l WHERE l.post_id = p.id) AS likes,

  (SELECT ARRAY_AGG(DISTINCT mc.munro_id ORDER BY mc.munro_id)
     FROM munro_completions mc
     WHERE mc.post_id = p.id) AS included_munro_ids,

  (SELECT MIN(mc.date_time_completed)
     FROM munro_completions mc
     WHERE mc.post_id = p.id) AS summited_date_time,

  (SELECT JSONB_OBJECT_AGG(s.munro_id, s.url_list ORDER BY s.munro_id)
   FROM (
     SELECT mp.munro_id,
            JSONB_AGG(mp.image_url ORDER BY mp.date_time_created) AS url_list
     FROM munro_pictures mp
     WHERE mp.post_id = p.id
     GROUP BY mp.munro_id
   ) s) AS image_urls
FROM posts p
JOIN users u ON u.id = p.author_id;