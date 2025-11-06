CREATE OR REPLACE VIEW vu_global_feed AS
SELECT 
  * 
FROM 
  mv_post_card mpc 
WHERE 
  mpc.privacy = 'public';

ALTER VIEW vu_global_feed SET (security_invoker = true, security_barrier = true);