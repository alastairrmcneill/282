CREATE TABLE saved_list_munros (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  saved_list_id UUID NOT NULL REFERENCES saved_lists(id) ON DELETE CASCADE,
  munro_id INT NOT NULL,
  date_time_added TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  unique(saved_list_id, munro_id)
);
