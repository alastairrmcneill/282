CREATE OR REPLACE VIEW vu_posts AS
SELECT * FROM mv_post_card;

ALTER VIEW vu_posts SET (security_invoker = true, security_barrier = true);