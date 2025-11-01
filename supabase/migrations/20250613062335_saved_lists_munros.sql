CREATE TABLE saved_list_munros (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  saved_list_id UUID NOT NULL REFERENCES saved_lists(id) ON DELETE CASCADE,
  munro_id INT NOT NULL,
  date_time_added TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  unique(saved_list_id, munro_id)
);

-- Enable RLS
ALTER TABLE saved_list_munros ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_list_munros FORCE ROW LEVEL SECURITY;

-- Own-row CRUD for signed-in saved_list_munros
CREATE POLICY "saved_list_munros_select_authenticated"
ON saved_list_munros
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM saved_lists sl
    WHERE sl.id = saved_list_munros.saved_list_id
      AND sl.user_id = (auth.jwt() ->> 'sub')
  )
);


CREATE POLICY "saved_list_munros_insert_authenticated"
ON saved_list_munros
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM saved_lists sl
    WHERE sl.id = saved_list_munros.saved_list_id
      AND sl.user_id = (auth.jwt() ->> 'sub')
  )
);

CREATE POLICY "saved_list_munros_update_authenticated"
ON saved_list_munros
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM saved_lists sl
    WHERE sl.id = saved_list_munros.saved_list_id
      AND sl.user_id = (auth.jwt() ->> 'sub')
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM saved_lists sl
    WHERE sl.id = saved_list_munros.saved_list_id
      AND sl.user_id = (auth.jwt() ->> 'sub')
  )
);

CREATE POLICY "saved_list_munros_delete_authenticated"
ON saved_list_munros
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM saved_lists sl
    WHERE sl.id = saved_list_munros.saved_list_id
      AND sl.user_id = (auth.jwt() ->> 'sub')
  )
);

-- Tighten GRANTS: anon no direct table access; authenticated can CRUD but still gated by RLS
REVOKE UPDATE, DELETE ON saved_list_munros FROM anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON saved_list_munros TO authenticated;