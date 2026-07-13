CREATE OR REPLACE VIEW vu_onboarding_feed AS
SELECT *
FROM (
    SELECT DISTINCT ON (u.id)
           u.display_name,
           p.date_time_created,
           m.name,
           u.profile_picture_url
    FROM posts p
    LEFT JOIN users u ON u.id = p.author_id
    LEFT JOIN munro_completions mc ON mc.post_id = p.id
    LEFT JOIN munros m ON m.id = mc.munro_id
    ORDER BY u.id, p.date_time_created DESC
) t
ORDER BY date_time_created DESC
LIMIT 2;

ALTER VIEW vu_onboarding_feed SET (security_invoker = true, security_barrier = true);

CREATE OR REPLACE VIEW vu_ AS
SELECT *
FROM (
    SELECT DISTINCT ON (u.id)
           u.display_name,
           p.date_time_created,
           m.name,
           u.profile_picture_url
    FROM posts p
    LEFT JOIN users u ON u.id = p.author_id
    LEFT JOIN munro_completions mc ON mc.post_id = p.id
    LEFT JOIN munros m ON m.id = mc.munro_id
    ORDER BY u.id, p.date_time_created DESC
) t
ORDER BY date_time_created DESC
LIMIT 2;

ALTER VIEW vu_onboarding_feed SET (security_invoker = true, security_barrier = true);

CREATE OR REPLACE VIEW vu_onboarding_totals AS
SELECT
    (SELECT COUNT(*) FROM users) AS total_users,
    (SELECT COUNT(*) FROM munro_completions) AS total_munro_completions;

SELECT * FROM vu_onboarding_totals;

ALTER VIEW vu_onboarding_totals SET (security_invoker = true, security_barrier = true);


CREATE OR REPLACE VIEW vu_onboarding_achievements AS
SELECT * FROM achievements a
WHERE a.id in ('munrosCompletedAllTime001', 'munrosCompletedAllTime010', 'nameMeall', 'munrosCompletedAllTime282')
ORDER BY a.criteria_count;

ALTER VIEW vu_onboarding_achievements SET (security_invoker = true, security_barrier = true);
