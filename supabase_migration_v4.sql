-- ============================================================================
-- BAEMS STUDY — migration v4: admin-manageable Subjects, Faculty photos
-- Run in Supabase → SQL Editor. Safe — additive, doesn't delete data.
-- ============================================================================

-- Subjects shown as "periodic table" tiles on the public site
create table if not exists subjects (
  id bigint generated always as identity primary key,
  name text not null,
  symbol text not null,
  periods_per_week text,
  description text,
  sort_order int default 0
);
alter table subjects enable row level security;
create policy "public read subjects" on subjects for select using (true);
create policy "admin write subjects" on subjects for all
  using (is_admin()) with check (is_admin());

-- Seed with the current 7 subjects (safe to edit/reorder from admin afterwards)
insert into subjects (name, symbol, periods_per_week, description, sort_order) values
('Physics', 'Ph', '4 pd/wk', 'Mechanics, waves, optics, electricity and modern physics — with weekly lab sessions covering measurement, circuits and optics benches.', 1),
('Chemistry', 'Ch', '4 pd/wk', 'Organic, inorganic and physical chemistry, run alongside titration, qualitative analysis and organic synthesis practicals.', 2),
('Biology', 'Bio', '4 pd/wk', 'Botany, zoology, genetics and human physiology, with dissection and microscopy lab blocks each fortnight.', 3),
('Mathematics', 'Ma', '5 pd/wk', 'Calculus, algebra, coordinate geometry, statistics and probability — the shared backbone for both science majors.', 4),
('Computer Science', 'CS', '3 pd/wk', 'Programming fundamentals, data structures and database concepts, offered as an alternative to Biology for the CS-focused track.', 5),
('English', 'Eng', '2 pd/wk', 'Compulsory English: comprehension, grammar and writing skills carried over from board requirements.', 6),
('Nepali', 'Ne', '2 pd/wk', 'Compulsory Nepali: language and literature, assessed per the standard NEB syllabus.', 7)
on conflict do nothing;

-- Faculty photo support
alter table faculty add column if not exists photo_url text;

-- Done. Next: push the updated admin.html and index.html.
