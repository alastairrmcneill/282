CREATE OR REPLACE VIEW vu_friends_feed AS
SELECT
  f.source_id AS user_id,
  vp.*
FROM followers f
JOIN vu_posts vp
  ON vp.author_id = f.target_id
WHERE vp.privacy IN ('public', 'friends');

ALTER VIEW vu_friends_feed SET (security_invoker = true, security_barrier = true);