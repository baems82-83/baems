-- ============================================================================
-- BAEMS STUDY — Supabase schema
-- Paste this whole file into Supabase → SQL Editor → New query → Run.
-- Safe to re-run: it drops and recreates everything below.
-- ============================================================================

-- Needed for password hashing (crypt/gen_salt)
create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------------
-- Clean slate
-- ---------------------------------------------------------------------------
drop table if exists resources cascade;
drop table if exists gallery cascade;
drop table if exists students cascade;
drop table if exists teachers cascade;
drop table if exists faculty cascade;
drop table if exists notices cascade;
drop table if exists settings cascade;

-- ---------------------------------------------------------------------------
-- SETTINGS (single row)
-- ---------------------------------------------------------------------------
create table settings (
  id int primary key default 1,
  portal_name text default 'BAEMS STUDY',
  school_name text default 'Bageshwari Academy E.M. School',
  tagline text default 'Bageshwari Academy E.M. School''s +2 Science stream pairs full NEB coursework with dedicated CEE, IOE and IOM entrance preparation — taught by faculty who mark the actual board papers.',
  address text default 'Kohalpur-10, Banke',
  phone text default '+977-81-XXXXXX',
  email text default 'admissions@bageshwariacademy.edu.np',
  established_bs text default '2063',
  pass_rate text default '94%',
  faculty_count text default '18',
  lab_hours text default '6',
  logo_url text default 'assets/logo.png',
  constraint single_row check (id = 1)
);
insert into settings (id) values (1);

-- ---------------------------------------------------------------------------
-- NOTICES
-- ---------------------------------------------------------------------------
create table notices (
  id bigint generated always as identity primary key,
  title text not null,
  tag text not null default 'Notice' check (tag in ('Exam','Holiday','Notice')),
  date text,
  body text,
  sort_order int default 0,
  created_at timestamptz default now()
);

-- ---------------------------------------------------------------------------
-- FACULTY (public-facing staff list)
-- ---------------------------------------------------------------------------
create table faculty (
  id bigint generated always as identity primary key,
  name text not null,
  role text,
  initials text,
  note text,
  sort_order int default 0
);

-- ---------------------------------------------------------------------------
-- GALLERY
-- ---------------------------------------------------------------------------
create table gallery (
  id bigint generated always as identity primary key,
  category text,
  event text,
  caption text,
  image_url text,
  sort_order int default 0,
  created_at timestamptz default now()
);

-- ---------------------------------------------------------------------------
-- RESOURCES (subject-wise learning materials)
-- ---------------------------------------------------------------------------
create table resources (
  id bigint generated always as identity primary key,
  subject text not null,
  title text not null,
  type text,
  url text not null,
  uploaded_by text,
  created_at timestamptz default now()
);

-- ---------------------------------------------------------------------------
-- STAFF ROLES — maps a Supabase Auth user to "admin" or "teacher"
-- After creating a login in Authentication → Users, add one row here so the
-- admin panel knows which tabs to show them.
-- ---------------------------------------------------------------------------
drop table if exists staff_roles cascade;
create table staff_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('admin','teacher')),
  name text
);
alter table staff_roles enable row level security;
create policy "read own role" on staff_roles for select using (auth.uid() = user_id);
create policy "admins manage roles" on staff_roles for all
  using (exists (select 1 from staff_roles r where r.user_id = auth.uid() and r.role = 'admin'))
  with check (exists (select 1 from staff_roles r where r.user_id = auth.uid() and r.role = 'admin'));

-- ---------------------------------------------------------------------------
-- STUDENTS (private — password_hash never exposed to the client directly)
-- ---------------------------------------------------------------------------
create table students (
  id bigint generated always as identity primary key,
  name text not null,
  roll_no text unique not null,
  class_section text,
  major text,
  guardian_phone text,
  password_hash text,
  created_at timestamptz default now()
);
-- Note: there is no separate "teachers" table. Teacher accounts are real
-- Supabase Auth users (created the same way as Admin, in Authentication →
-- Users), distinguished only by their role in staff_roles below.

-- ============================================================================
-- ROW LEVEL SECURITY
-- Public (anon) can READ: settings, notices, faculty, gallery, resources.
-- Public (anon) can NEVER read students/teachers directly (no select policy).
-- WRITES of any kind require a logged-in Supabase Auth user (admin/teacher).
-- ============================================================================
alter table settings  enable row level security;
alter table notices   enable row level security;
alter table faculty   enable row level security;
alter table gallery   enable row level security;
alter table resources enable row level security;
alter table students  enable row level security;

-- Public read access
create policy "public read settings"  on settings  for select using (true);
create policy "public read notices"   on notices   for select using (true);
create policy "public read faculty"   on faculty   for select using (true);
create policy "public read gallery"   on gallery   for select using (true);
create policy "public read resources" on resources for select using (true);

-- Admin-only write access (Notices, Faculty, Settings, Students, role management)
create policy "admin write settings" on settings for all
  using (exists (select 1 from staff_roles r where r.user_id = auth.uid() and r.role = 'admin'))
  with check (exists (select 1 from staff_roles r where r.user_id = auth.uid() and r.role = 'admin'));
create policy "admin write notices" on notices for all
  using (exists (select 1 from staff_roles r where r.user_id = auth.uid() and r.role = 'admin'))
  with check (exists (select 1 from staff_roles r where r.user_id = auth.uid() and r.role = 'admin'));
create policy "admin write faculty" on faculty for all
  using (exists (select 1 from staff_roles r where r.user_id = auth.uid() and r.role = 'admin'))
  with check (exists (select 1 from staff_roles r where r.user_id = auth.uid() and r.role = 'admin'));
create policy "admin write students" on students for all
  using (exists (select 1 from staff_roles r where r.user_id = auth.uid() and r.role = 'admin'))
  with check (exists (select 1 from staff_roles r where r.user_id = auth.uid() and r.role = 'admin'));

-- Admin OR Teacher write access (Gallery, Resources — the two "teacher" tabs)
create policy "staff write gallery" on gallery for all
  using (exists (select 1 from staff_roles r where r.user_id = auth.uid()))
  with check (exists (select 1 from staff_roles r where r.user_id = auth.uid()));
create policy "staff write resources" on resources for all
  using (exists (select 1 from staff_roles r where r.user_id = auth.uid()))
  with check (exists (select 1 from staff_roles r where r.user_id = auth.uid()));

-- No select policy on students for anon — direct reads of that table are blocked.

-- ============================================================================
-- SECURE LOGIN FUNCTION (students only — teachers/admin use real Supabase Auth)
-- Runs with the table owner's privileges (SECURITY DEFINER), so it can check
-- the password hash internally without ever exposing it to the client.
-- ============================================================================

create or replace function verify_student_login(p_roll_no text, p_password text)
returns table (id bigint, name text, roll_no text, class_section text, major text)
language plpgsql
security definer
set search_path = public
as $$
begin
  return query
    select s.id, s.name, s.roll_no, s.class_section, s.major
    from students s
    where s.roll_no = p_roll_no
      and s.password_hash = crypt(p_password, s.password_hash);
end;
$$;

-- Helper to hash a password the same way (used by the admin panel when saving)
create or replace function hash_password(p_password text)
returns text
language sql
security definer
as $$
  select crypt(p_password, gen_salt('bf'));
$$;


-- Let anon (not-logged-in visitors) call the login-check functions, but NOT
-- read the tables directly — this is what makes login work from student.html
-- without a Supabase Auth session.
grant execute on function verify_student_login(text, text) to anon;
-- hash_password is only needed by the logged-in admin panel:
grant execute on function hash_password(text) to authenticated;

-- ============================================================================
-- STORAGE (run once — creates a public bucket for logo/gallery/resource files)
-- If this errors saying the bucket exists already, that's fine, ignore it.
-- ============================================================================
insert into storage.buckets (id, name, public)
values ('baems-files', 'baems-files', true)
on conflict (id) do nothing;

create policy "public read baems-files"
on storage.objects for select
using (bucket_id = 'baems-files');

create policy "auth upload baems-files"
on storage.objects for insert
to authenticated
with check (bucket_id = 'baems-files');

create policy "auth update baems-files"
on storage.objects for update
to authenticated
using (bucket_id = 'baems-files');

create policy "auth delete baems-files"
on storage.objects for delete
to authenticated
using (bucket_id = 'baems-files');

-- ============================================================================
-- SEED DATA (safe to edit/delete afterwards from the admin panel)
-- ============================================================================
insert into notices (title, tag, date, body, sort_order) values
('First Terminal Routine', 'Exam', 'Posted 02 Jul 2026', 'Grade 11 & 12 first terminal exams begin 20 Shrawan. Full routine posted outside Room 4.', 1),
('School closed — Naag Panchami', 'Holiday', 'Posted 29 Jun 2026', 'No classes on the public holiday. Regular routine resumes the following day.', 2),
('Lab fee — second installment', 'Notice', 'Posted 27 Jun 2026', 'Due at the accounts window by the 15th. Late payments carry a NPR 200 surcharge.', 3);

insert into faculty (name, role, initials, note, sort_order) values
('R. Sharma', 'Physics · Dept. Head', 'RS', '18 years teaching Grade 11–12 Physics; NEB paper-setter, 2019–2023.', 1),
('A. Thapa', 'Chemistry', 'AT', 'Runs the organic chemistry lab block and the Saturday CEE chemistry clinic.', 2),
('P. K.C.', 'Biology', 'PK', 'Coordinates dissection labs and the annual field biology trip to Bardiya.', 3),
('S. Bista', 'Mathematics', 'SB', 'Leads the entrance-prep calculus track for CEE and IOE aspirants.', 4);

-- Resources start empty — add real files from the admin panel (Resources tab).

-- Done. Next steps:
--
-- 1) Supabase → Authentication → Users → Add user
--    Create your Admin account (real email + a strong password).
--    Copy the new user's UUID from the Users list.
--
-- 2) Come back here and run (replace the UUID and name):
--    insert into staff_roles (user_id, role, name)
--    values ('PASTE-THE-USER-UUID-HERE', 'admin', 'Your Name');
--
-- 3) Repeat both steps for any Teacher accounts, using role = 'teacher' instead.
--
-- Do this part in the SQL Editor (not from the site) — the SQL Editor runs
-- with full privileges, so it can create the very first admin role row even
-- before any admin role exists yet.
