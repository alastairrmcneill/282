-- CREATEING THE MUNRO TABLE SAME AS THE JSON FILE
CREATE TABLE munros (
  id INT PRIMARY KEY NOT NULL,
  name TEXT NOT NULL,
  extra TEXT NOT NULL,
  area TEXT NOT NULL,
  meters INT NOT NULL,
  section TEXT NOT NULL,
  region TEXT NOT NULL,
  feet INT NOT NULL,
  lat DOUBLE PRECISION NOT NULL,
  lng DOUBLE PRECISION NOT NULL,
  link TEXT NOT NULL,
  description TEXT NOT NULL,
  picture_url TEXT NOT NULL,
  starting_point_url TEXT NOT NULL
);

ALTER TABLE munros ENABLE ROW LEVEL SECURITY;
ALTER TABLE munros FORCE ROW LEVEL SECURITY;

CREATE POLICY "munros_read_authenticated"
ON munros
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "munros_read_anon"
ON public.munros
FOR SELECT
TO anon
USING (true);

REVOKE ALL ON TABLE munros FROM anon, authenticated;
GRANT SELECT ON TABLE munros TO anon, authenticated;
