-- ============================================================================
-- BAEMS STUDY — migration v8: Teacher login becomes as easy as Student login.
-- No more Supabase Auth accounts, UUIDs, or email/SMTP for teachers — just a
-- username + password typed directly into admin.html, exactly like Students.
-- ============================================================================

-- Bring back a simple teachers table (username + hashed password)
create table if not exists teachers (
  id bigint generated always as identity primary key,
  name text not null,
  username text unique not null,
  subject text,
  password_hash text,
  created_at timestamptz default now()
);
alter table teachers enable row level security;

-- Public (anon) can never read the teachers table directly — only via the
-- login-check function below, same pattern as students.
create policy "admin write teachers" on teachers for all
  using (is_admin()) with check (is_admin());

-- Secure login check (same pattern as verify_student_login)
create or replace function verify_teacher_login(p_username text, p_password text)
returns table (id bigint, name text, username text, subject text)
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
  return query
    select t.id, t.name, t.username, t.subject
    from teachers t
    where t.username = p_username
      and t.password_hash = extensions.crypt(p_password, t.password_hash);
end;
$$;
grant execute on function verify_teacher_login(text, text) to anon;

-- ----------------------------------------------------------------------------
-- Since teachers no longer have a real Supabase Auth session, they act as
-- "anon" when saving Gallery/Resources — same as how Students already upload
-- Resources. Open Gallery INSERT to anon too (matching Resources' existing
-- policy). DELETE stays Admin-only for both, as a safety backstop.
-- ----------------------------------------------------------------------------
drop policy if exists "staff write gallery" on gallery;

create policy "anyone can add gallery photos" on gallery
  for insert with check (true);

create policy "admin update gallery" on gallery
  for update using (is_admin()) with check (is_admin());

create policy "admin delete gallery" on gallery
  for delete using (is_admin());

-- Resources: tighten delete to Admin-only too (previously "staff", which no
-- longer means anything for teachers specifically since they're anon now)
drop policy if exists "staff delete resources" on resources;
create policy "admin delete resources" on resources
  for delete using (is_admin());

-- Done. Push the updated admin.html and teacher.html.

-- Faculty needs a place to remember which teacher-login username it's linked to
alter table faculty add column if not exists teacher_username text;
