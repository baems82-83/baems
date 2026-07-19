-- ============================================================================
-- BAEMS STUDY — migration v9: Discussion/Q&A board + Teacher availability
-- ============================================================================

-- Teacher "online/available" status
alter table teachers add column if not exists is_available boolean default false;
alter table teachers add column if not exists status_note text;

-- Discussion board — one thread system per subject. Students, Teachers and
-- Admin can all post. Replies reference parent_id.
create table if not exists discussions (
  id bigint generated always as identity primary key,
  subject text not null,
  parent_id bigint references discussions(id) on delete cascade,
  author_name text not null,
  author_role text not null check (author_role in ('student','teacher','admin')),
  message text not null,
  created_at timestamptz default now()
);
alter table discussions enable row level security;

drop policy if exists "public read discussions" on discussions;
create policy "public read discussions" on discussions for select using (true);

drop policy if exists "anyone can post discussions" on discussions;
create policy "anyone can post discussions" on discussions for insert with check (true);

drop policy if exists "admin delete discussions" on discussions;
create policy "admin delete discussions" on discussions for delete using (is_admin());

-- Done. Push the updated admin.html, teacher.html, student.html.
