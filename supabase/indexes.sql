-- quick name search (case-insensitive / partial)
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX CONCURRENTLY idx_users_search_name_trgm
ON users USING GIN (search_name gin_trgm_ops);

-- blocked lookups in both directions
CREATE INDEX CONCURRENTLY idx_blocked_user_id ON blocked_users (user_id);
CREATE INDEX CONCURRENTLY idx_blocked_blocked_user_id ON blocked_users (blocked_user_id);

-- followers: you count both "followers of X" and "following of X"
-- PK (source_id, target_id) already handles "following", add reverse for "followers"
CREATE INDEX CONCURRENTLY idx_followers_target_id ON followers (target_id);

-- paginate a user’s posts, filter by privacy, global feed
CREATE INDEX CONCURRENTLY idx_posts_privacy_created
  ON posts (privacy, date_time_created DESC);
CREATE INDEX CONCURRENTLY idx_posts_author_privacy_created
  ON posts (author_id, privacy, date_time_created DESC);
-- fast join from foreign keys
CREATE INDEX CONCURRENTLY idx_posts_author_id ON posts (author_id);

-- fast per-user tallies and distincts
CREATE INDEX CONCURRENTLY idx_mc_user_munro ON munro_completions (user_id, munro_id);
CREATE INDEX CONCURRENTLY idx_mc_user_date ON munro_completions (user_id, date_time_completed);
CREATE INDEX CONCURRENTLY idx_mc_post ON munro_completions (post_id);

-- common: count likes per post, does user X like post Y? (and prevent double-like)
CREATE UNIQUE INDEX CONCURRENTLY idx_likes_unique_post_user ON likes (post_id, user_id);
CREATE INDEX CONCURRENTLY idx_likes_post ON likes (post_id);

-- post comments pagination
CREATE INDEX CONCURRENTLY idx_comments_post_created
  ON comments (post_id, date_time_created DESC);
CREATE INDEX CONCURRENTLY idx_comments_author ON comments (author_id);

CREATE INDEX CONCURRENTLY idx_reviews_munro_created
  ON reviews (munro_id, date_time_created DESC);
CREATE INDEX CONCURRENTLY idx_reviews_author ON reviews (author_id);

-- "my unread notifications newest first"
CREATE INDEX CONCURRENTLY idx_notifications_target_read_created
  ON notifications (target_id, read, date_time_created DESC);

-- common: pictures by post, per munro, public-only
CREATE INDEX CONCURRENTLY idx_munro_pictures_post_created
  ON munro_pictures (post_id, date_time_created DESC);
CREATE INDEX CONCURRENTLY idx_munro_pictures_munro_created
  ON munro_pictures (munro_id, date_time_created DESC);
CREATE INDEX CONCURRENTLY idx_munro_pictures_privacy_post
  ON munro_pictures (privacy, post_id);

-- list contents and reverse lookup
CREATE INDEX CONCURRENTLY idx_slm_list_added ON saved_list_munros (saved_list_id, date_time_added);
CREATE INDEX CONCURRENTLY idx_slm_munro ON saved_list_munros (munro_id);

-- required for concurrent refresh
CREATE UNIQUE INDEX CONCURRENTLY mv_post_card_pkey ON mv_post_card (id);

-- feed patterns
CREATE INDEX CONCURRENTLY mv_post_card_created_desc
  ON mv_post_card (date_time_created DESC);

CREATE INDEX CONCURRENTLY mv_post_card_privacy_created
  ON mv_post_card (privacy, date_time_created DESC);

CREATE INDEX CONCURRENTLY mv_post_card_author_created
  ON mv_post_card (author_id, date_time_created DESC);

REFRESH MATERIALIZED VIEW CONCURRENTLY mv_post_card;

-- run every minute
CREATE EXTENSION IF NOT EXISTS pg_cron;
SELECT cron.schedule('refresh_mv_post_card_every_min',
                     '*/1 * * * *',
                     $$ REFRESH MATERIALIZED VIEW CONCURRENTLY mv_post_card; $$);