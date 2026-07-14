-- ============================================================================
-- BAEMS STUDY — migration v7: Resources become a shared "file manager" —
-- Admin, Teacher, AND Student can all add files per subject.
-- Delete stays restricted to Admin/Teacher (see note below on why).
-- ============================================================================

-- Students authenticate via a custom roll+password check (not real Supabase
-- Auth), so from the database's point of view they're just "anon". To let
-- them upload, we open INSERT on resources to anon — but NOT update/delete,
-- so a student can add a file but can't wipe out others' files.
drop policy if exists "staff write resources" on resources;

create policy "anyone can add resources" on resources
  for insert
  with check (true);

create policy "staff update resources" on resources
  for update using (is_staff()) with check (is_staff());

create policy "staff delete resources" on resources
  for delete using (is_staff());

-- (select/read policy "public read resources" from before is unchanged)

-- Track who uploaded each file (optional but useful — already has a column
-- from earlier; just making sure it's there)
alter table resources add column if not exists uploaded_by text;

-- Storage: students need to be able to upload the actual file too (not just
-- the database row referencing it). Same tradeoff as above — anon can add,
-- only staff can remove.
drop policy if exists "auth upload baems-files" on storage.objects;
create policy "anyone upload baems-files"
on storage.objects for insert
with check (bucket_id = 'baems-files');
