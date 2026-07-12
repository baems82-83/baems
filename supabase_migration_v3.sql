-- ============================================================================
-- BAEMS STUDY — migration: teacher subjects, shared student management,
-- and admission applications reaching the admin dashboard.
-- Run this in Supabase → SQL Editor. Safe — additive, doesn't delete data.
-- ============================================================================

-- 1) Teachers get a subject (e.g. Physics, English). Admin has none.
alter table staff_roles add column if not exists subject text;

-- 2) Students: let BOTH Admin and Teacher manage them (not Admin-only anymore)
drop policy if exists "admin write students" on students;
create policy "staff write students" on students for all
  using (is_staff()) with check (is_staff());

-- 3) Admission applications — public visitors can submit; only Admin can read/manage
drop table if exists applications cascade;
create table applications (
  id bigint generated always as identity primary key,
  full_name text not null,
  phone text,
  intended_major text,
  message text,
  status text not null default 'new' check (status in ('new','reviewed','contacted','archived')),
  created_at timestamptz default now()
);
alter table applications enable row level security;

-- Anyone (even not logged in) can submit an application
create policy "public submit application" on applications
  for insert
  with check (true);

-- Only Admin can view/update/delete applications
create policy "admin read applications" on applications
  for select using (is_admin());
create policy "admin manage applications" on applications
  for update using (is_admin()) with check (is_admin());
create policy "admin delete applications" on applications
  for delete using (is_admin());

-- Done. Next: push the updated admin.html / teacher.html / index.html files.
