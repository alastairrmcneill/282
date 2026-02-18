-- Update munro_completions to add date and time summited columns
ALTER TABLE munro_completions
ADD COLUMN date_time_created TIMESTAMPTZ,
ADD COLUMN completion_date DATE,
ADD COLUMN completion_start_time TIME,
ADD COLUMN completion_duration INTEGER;

UPDATE munro_completions
SET date_time_created = date_time_completed;

ALTER TABLE munro_completions
ALTER COLUMN date_time_created SET NOT NULL,
ALTER COLUMN date_time_created SET DEFAULT NOW();

CREATE INDEX IF NOT EXISTS idx_mc_user_completed_created_munro
ON munro_completions (user_id, date_time_completed, date_time_created, munro_id);

-- Recreate materialized view mv_post_card to include munro completion date, time and counts
DROP MATERIALIZED VIEW IF EXISTS mv_post_card CASCADE;

CREATE MATERIALIZED VIEW mv_post_card AS
SELECT
  p.id,
  p.author_id,
  p.title,
  p.description,
  p.date_time_created,
  p.privacy,
  u.display_name AS author_display_name,
  u.profile_picture_url AS author_profile_picture_url,

  (SELECT COUNT(*) FROM likes l WHERE l.post_id = p.id) AS likes,

  (
    SELECT ARRAY_AGG(DISTINCT mc.munro_id ORDER BY mc.munro_id)
    FROM munro_completions mc
    WHERE mc.post_id = p.id
  ) AS included_munro_ids,

  (
    SELECT (min(mc.date_time_completed))::TIMESTAMPTZ
    FROM munro_completions mc
    WHERE mc.post_id = p.id
  ) AS date_time_completed,

  (
    SELECT (min(mc.completion_date))::DATE
    FROM munro_completions mc
    WHERE mc.post_id = p.id
  ) AS completion_date,

  (
    SELECT (min(mc.completion_start_time))::TIME
    FROM munro_completions mc
    WHERE mc.post_id = p.id
  ) AS completion_start_time,

    (
    SELECT (min(mc.completion_duration))::INTEGER
    FROM munro_completions mc
    WHERE mc.post_id = p.id
  ) AS completion_duration,

  (
    SELECT JSONB_OBJECT_AGG(s.munro_id, s.url_list ORDER BY s.munro_id)
    FROM (
      SELECT
        mp.munro_id,
        jsonb_agg(mp.image_url ORDER BY mp.date_time_created) AS url_list
      FROM munro_pictures mp
      WHERE mp.post_id = p.id
      GROUP BY mp.munro_id
    ) s
  ) AS image_urls,

  (
    WITH post_cutoff AS (
      SELECT
        min(mc.date_time_completed) AS completed_at,
        max(mc.date_time_created)  AS created_cutoff
      FROM munro_completions mc
      WHERE mc.post_id = p.id
    )
    SELECT count(distinct mc2.munro_id)
    FROM munro_completions mc2
    CROSS JOIN post_cutoff pc
    WHERE mc2.user_id = p.author_id
      AND (
        mc2.date_time_completed < pc.completed_at
        OR (
          mc2.date_time_completed = pc.completed_at
          AND mc2.date_time_created <= pc.created_cutoff
        )
      )
  ) AS munro_count_at_post_date_time

FROM posts p
JOIN users u ON u.id = p.author_id;

-- Remaking the views for posts and feeds

CREATE OR REPLACE VIEW vu_posts AS
SELECT * FROM mv_post_card;

ALTER VIEW vu_posts SET (security_invoker = true, security_barrier = true);

CREATE OR REPLACE VIEW vu_global_feed AS
SELECT 
  * 
FROM 
  mv_post_card mpc 
WHERE 
  mpc.privacy = 'public';

ALTER VIEW vu_global_feed SET (security_invoker = true, security_barrier = true);

CREATE OR REPLACE VIEW vu_friends_feed AS
SELECT
  f.source_id AS user_id,
  m.*
FROM followers f
JOIN mv_post_card m
  ON m.author_id = f.target_id
WHERE m.privacy IN ('public','friends');

ALTER VIEW vu_friends_feed SET (security_invoker = true, security_barrier = true);