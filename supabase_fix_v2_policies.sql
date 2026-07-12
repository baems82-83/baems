-- ============================================================================
-- FIX v2: fully reset all RLS policies (removes any stale/duplicate ones
-- that might still be causing recursion), then recreates them cleanly.
-- Safe — does not touch your data, only the security rules.
-- ============================================================================

-- 1) Remove every existing policy on the affected tables, whatever they're named
do $$
declare pol record;
begin
  for pol in
    select policyname, tablename from pg_policies
    where schemaname = 'public'
      and tablename in ('settings','notices','faculty','students','gallery','resources','staff_roles')
  loop
    execute format('drop policy if exists %I on %I', pol.policyname, pol.tablename);
  end loop;
end $$;

-- 2) Recreate the helper functions (safe to re-run)
create or replace function is_admin()
returns boolean
language sql
security definer
stable
as $$
  select exists (
    select 1 from staff_roles where user_id = auth.uid() and role = 'admin'
  );
$$;

create or replace function is_staff()
returns boolean
language sql
security definer
stable
as $$
  select exists (
    select 1 from staff_roles where user_id = auth.uid()
  );
$$;

-- 3) Recreate every policy fresh, from scratch

-- Public read
create policy "public read settings"  on settings  for select using (true);
create policy "public read notices"   on notices   for select using (true);
create policy "public read faculty"   on faculty   for select using (true);
create policy "public read gallery"   on gallery   for select using (true);
create policy "public read resources" on resources for select using (true);

-- staff_roles: read your own row; admins manage all rows
create policy "read own role" on staff_roles for select using (auth.uid() = user_id);
create policy "admins manage roles" on staff_roles for all
  using (is_admin()) with check (is_admin());

-- Admin-only write
create policy "admin write settings" on settings for all
  using (is_admin()) with check (is_admin());
create policy "admin write notices" on notices for all
  using (is_admin()) with check (is_admin());
create policy "admin write faculty" on faculty for all
  using (is_admin()) with check (is_admin());
create policy "admin write students" on students for all
  using (is_admin()) with check (is_admin());

-- Admin OR Teacher write
create policy "staff write gallery" on gallery for all
  using (is_staff()) with check (is_staff());
create policy "staff write resources" on resources for all
  using (is_staff()) with check (is_staff());

-- ============================================================================
-- 4) Diagnostic — run this separately afterwards to confirm what's active:
--    select tablename, policyname, qual, with_check from pg_policies
--    where schemaname = 'public' order by tablename;
-- Every row should show is_admin() or is_staff() or true/auth.uid()=user_id —
-- if you see anything mentioning "select 1 from staff_roles" directly inside
-- another table's policy, that row is still the old broken version.
-- ============================================================================
