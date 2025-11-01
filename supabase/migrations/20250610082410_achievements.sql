-- Create Achievements
CREATE TABLE achievements (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  type TEXT NOT NULL,
  criteria_value TEXT NOT NULL,
  criteria_count INT NOT NULL,
  date_time_created TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements FORCE ROW LEVEL SECURITY;

CREATE POLICY "achievements_read_authenticated"
ON achievements
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "achievements_read_anon"
ON public.achievements
FOR SELECT
TO anon
USING (true);

REVOKE ALL ON TABLE achievements FROM anon, authenticated;
GRANT SELECT ON TABLE achievements TO anon, authenticated;
