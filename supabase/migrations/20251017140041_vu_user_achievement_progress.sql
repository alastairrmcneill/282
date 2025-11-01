CREATE OR REPLACE VIEW vu_user_achievement_progress AS
WITH base AS (
  SELECT
    u.id  AS user_id,
    a.id  AS achievement_id,
    a.date_time_created,
    a.name,
    a.description,
    a.type,
    a.criteria_value,
    a.criteria_count,
    ua.annual_target,
    ua.acknowledged_at
  FROM users u
  CROSS JOIN achievements a
  LEFT JOIN user_achievements ua
    ON ua.user_id = u.id AND ua.achievement_id = a.id
),
progressed AS (
  SELECT
    b.*,
    CASE b.type
      WHEN 'totalCount' THEN (
        SELECT COUNT(DISTINCT mc.munro_id)
        FROM munro_completions mc
        WHERE mc.user_id = b.user_id
      )
      WHEN 'annualGoal' THEN (
        SELECT COUNT(*)
        FROM munro_completions mc
        WHERE mc.user_id = b.user_id
          AND EXTRACT(YEAR FROM mc.date_time_completed)::int = b.criteria_value::int
      )
      WHEN 'areaGoal' THEN (
        SELECT COUNT(DISTINCT mc.munro_id)
        FROM munro_completions mc
        JOIN munros m ON m.id = mc.munro_id
        WHERE mc.user_id = b.user_id
          AND m.area = b.criteria_value
      )
      WHEN 'tallestMunros' THEN (
        SELECT COUNT(DISTINCT mc.munro_id)
        FROM munro_completions mc
        JOIN vu_munros_by_height h ON h.id = mc.munro_id
        WHERE mc.user_id = b.user_id
          AND h.height_rank_desc <= b.criteria_count
      )
      WHEN 'lowestMunros' THEN (
        SELECT COUNT(DISTINCT mc.munro_id)
        FROM munro_completions mc
        JOIN vu_munros_by_height h ON h.id = mc.munro_id
        WHERE mc.user_id = b.user_id
          AND h.height_rank_asc <= b.criteria_count
      )
      WHEN 'monthlyMunro' THEN (
        SELECT COUNT(DISTINCT DATE_TRUNC('month', mc.date_time_completed))
        FROM munro_completions mc
        WHERE mc.user_id = b.user_id
      )
      WHEN 'multiMunroDay' THEN (
        SELECT COUNT(*)
        FROM (
          SELECT DATE_TRUNC('day', mc.date_time_completed)::date AS day,
                 COUNT(mc.munro_id) AS c
          FROM munro_completions mc
          WHERE mc.user_id = b.user_id
          GROUP BY 1
        ) d
        WHERE d.c = b.criteria_count
      )
      WHEN 'nameGoal' THEN (
        SELECT COUNT(DISTINCT mc.munro_id)
        FROM munro_completions mc
        JOIN munros m ON m.id = mc.munro_id
        JOIN LATERAL UNNEST(STRING_TO_ARRAY(b.criteria_value, ', ')) AS t(term) ON TRUE
        WHERE mc.user_id = b.user_id
          AND LOWER(m.name) LIKE '%' || LOWER(t.term) || '%'
      )
      ELSE 0
    END::int AS progress
  FROM base b
)
SELECT
  p.*,
  COALESCE(
    CASE p.type
      WHEN 'monthlyMunro'  THEN (p.progress >= 12)       -- 12 distinct months overall
      WHEN 'multiMunroDay' THEN (p.progress >= 1)        -- at least one day with exactly N
      WHEN 'annualGoal'    THEN CASE
                                  WHEN p.annual_target IS NULL OR p.annual_target = 0 THEN NULL
                                  ELSE (p.progress >= p.annual_target)
                                END
      ELSE (p.progress >= p.criteria_count)
    END,
    FALSE
  ) AS completed
FROM progressed p;

ALTER VIEW vu_user_achievement_progress SET (security_invoker = true, security_barrier = true);