-- Fix: teachers table is missing the "subject" column
alter table teachers add column if not exists subject text;
alter table teachers add column if not exists password_hash text;
alter table teachers add column if not exists name text;
alter table teachers add column if not exists created_at timestamptz default now();

-- Force Supabase's API layer to notice the schema change immediately
notify pgrst, 'reload schema';

-- Confirm the columns are all there now
select column_name, data_type
from information_schema.columns
where table_name = 'teachers'
order by ordinal_position;
