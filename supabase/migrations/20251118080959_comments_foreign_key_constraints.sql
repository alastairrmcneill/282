-- 1. Drop the existing foreign key constraint
ALTER TABLE comments
  DROP CONSTRAINT IF EXISTS comments_author_id_fkey;
ALTER TABLE comments
  DROP CONSTRAINT IF EXISTS comments_post_id_fkey;

-- 2. Add new foreign key with ON DELETE CASCADE
ALTER TABLE comments
  ADD CONSTRAINT comments_author_id_fkey
  FOREIGN KEY (author_id)
  REFERENCES users(id)
  ON DELETE CASCADE;

ALTER TABLE comments
  ADD CONSTRAINT comments_post_id_fkey
  FOREIGN KEY (post_id)
  REFERENCES posts(id)
  ON DELETE CASCADE;