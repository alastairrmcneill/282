CREATE OR REPLACE VIEW vu_posts AS
SELECT 
  p.*,
  u.display_name              AS author_display_name,
  u.profile_picture_url       AS author_profile_picture_url,
  ARRAY_AGG(DISTINCT mc.munro_id ORDER BY mc.munro_id) AS included_munro_ids,
  lc.like_count               AS likes,
  imgs.image_urls             AS image_urls,
  MIN(mc.date_time_completed) AS summited_date_time
FROM posts p
LEFT JOIN munro_completions mc ON mc.post_id = p.id
LEFT JOIN users u ON u.id = p.author_id
LEFT JOIN LATERAL (
  SELECT COUNT(*) AS like_count
  FROM likes l
  WHERE l.post_id = p.id
) lc ON TRUE
LEFT JOIN LATERAL (
  SELECT
    JSONB_OBJECT_AGG(s.munro_id, s.url_list ORDER BY s.munro_id) AS image_urls
  FROM (
    SELECT
      mp.munro_id,
      JSONB_AGG(mp.image_url ORDER BY mp.date_time_created) AS url_list
    FROM munro_pictures mp
    WHERE mp.post_id = p.id
    GROUP BY mp.munro_id
  ) AS s
) imgs ON TRUE
GROUP BY 
  p.id, 
  u.display_name, 
  u.profile_picture_url, 
  lc.like_count, 
  imgs.image_urls
ORDER BY p.date_time_created DESC;

ALTER VIEW vu_posts SET (security_invoker = true, security_barrier = true);