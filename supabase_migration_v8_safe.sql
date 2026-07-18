-- ============================================================================
-- BAEMS STUDY — migration v8 (safe re-run version). Drops each policy first
-- so this can be run again even if it partially succeeded before.
-- ============================================================================

create table if not exists teachers (
  id bigint generated always as identity primary key,
  name text not null,
  username text unique not null,
  subject text,
  password_hash text,
  created_at timestamptz default now()
);
alter table teachers enable row level security;

drop policy if exists "admin write teachers" on teachers;
create policy "admin write teachers" on teachers for all
  using (is_admin()) with check (is_admin());

drop function if exists verify_teacher_login(text, text);
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

drop policy if exists "staff write gallery" on gallery;
drop policy if exists "anyone can add gallery photos" on gallery;
create policy "anyone can add gallery photos" on gallery
  for insert with check (true);

drop policy if exists "admin update gallery" on gallery;
create policy "admin update gallery" on gallery
  for update using (is_admin()) with check (is_admin());

drop policy if exists "admin delete gallery" on gallery;
create policy "admin delete gallery" on gallery
  for delete using (is_admin());

drop policy if exists "staff delete resources" on resources;
drop policy if exists "admin delete resources" on resources;
create policy "admin delete resources" on resources
  for delete using (is_admin());

alter table faculty add column if not exists teacher_username text;

-- Confirm — should list "teachers" and its policy without error
select tablename, policyname from pg_policies where tablename = 'teachers';
