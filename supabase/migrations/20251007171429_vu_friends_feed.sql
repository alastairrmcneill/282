CREATE OR REPLACE VIEW vu_friends_feed AS
SELECT
  f.source_id AS user_id,
  m.*
FROM followers f
JOIN mv_post_card m
  ON m.author_id = f.target_id
WHERE m.privacy IN ('public','friends');

ALTER VIEW vu_friends_feed SET (security_invoker = true, security_barrier = true);