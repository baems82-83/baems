-- ============================================================================
-- BAEMS STUDY — migration v6: Faculty entries can directly grant Teacher
-- portal access (no more separate "Staff Accounts" step).
-- ============================================================================

-- Link a faculty row to a real Supabase Auth login (optional — only needed
-- if that teacher will log into /teacher.html themselves).
alter table faculty add column if not exists user_id uuid references auth.users(id) on delete set null;
alter table faculty add column if not exists teacher_subject text;

-- Done. Push the updated admin.html — the Faculty tab now has optional
-- "Teacher Login UUID" and "Subject" fields. Filling them in and saving
-- automatically grants that person /teacher.html access for that subject.
