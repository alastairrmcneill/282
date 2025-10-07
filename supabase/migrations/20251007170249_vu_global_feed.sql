CREATE OR REPLACE VIEW vu_global_feed AS
SELECT
  vp.*
FROM
  vu_posts vp
WHERE
  vp.privacy = 'public';
