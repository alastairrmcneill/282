-- Read policy for authenticated users
CREATE POLICY "munro_pictures_select_anon"
ON munro_pictures
FOR SELECT
TO anon
USING (
    privacy = 'public'
);
