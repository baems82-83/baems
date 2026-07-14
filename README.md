# BAEMS STUDY — Bageshwari Academy E.M. School (+2 Science)

Live site: https://baems.netlify.app
Admin login (Admin only): https://baems.netlify.app/admin.html
Teacher login (Teacher only): https://baems.netlify.app/teacher.html
Student portal: https://baems.netlify.app/student.html

Backend: **Supabase** (Postgres database + real authentication + file storage).

## ⚠️ If you're still getting errors right now
1. Run `supabase_fix_v2_policies.sql` in Supabase → SQL Editor. It wipes and cleanly recreates every security rule (fixes the "row-level security" / recursion errors seen while setting this up). Safe — doesn't touch your data.
2. Push the latest `admin.html`, `teacher.html`, `student.html`, `index.html` to GitHub (see bottom of this file) — the Admin/Teacher split and the Gallery multi-photo upload are new files.
3. After both of those, hard-refresh (Ctrl+Shift+R) before testing again.

## What's here
- `index.html` — public site. Reads settings/notices/faculty/gallery live from Supabase.
- `admin.html` — **Admin-only**. Site Settings, Notices, Faculty, Students, Staff Accounts, Gallery, Resources.
- `teacher.html` — **Teacher-only**, separate page. Just Gallery and Resources.
- `student.html` — student portal. Roll number + password, checked securely inside the database.
- `supabase_schema.sql` — original full database setup (already run once).
- `supabase_fix_v2_policies.sql` — the recursion/RLS fix (run this now if you haven't).
- `assets/logo.png` — local fallback only; the live logo comes from Supabase Storage once uploaded via the admin panel.

## Roles at a glance

| Role | Logs in at | Account type | Sees |
|---|---|---|---|
| **Admin** | `/admin.html` | Real Supabase Auth (email + password) | Everything |
| **Teacher** | `/teacher.html` | Real Supabase Auth (email + password) | Only Gallery + Resources, on its own page |
| **Student** | `/student.html` | Roll number + password (checked inside the database) | Their subjects' resource files, read-only |

An Admin account trying to log into `/teacher.html` is rejected (told to use `/admin.html` instead), and vice versa — the two are now fully separate portals, not one page with hidden tabs.

## 1. Creating logins

**Admin / Teacher accounts** (done once per person, in the Supabase dashboard):
1. Supabase → **Authentication → Users → Add user** → real email + password (tick "Auto Confirm User" if shown).
2. Copy that user's UUID from the Users list.
3. Supabase → **SQL Editor**, run:
   ```sql
   insert into staff_roles (user_id, role, name)
   values ('PASTE-THE-UUID-HERE', 'admin', 'Their Name');
   -- use 'teacher' instead of 'admin' for a teacher account
   ```
   (Or from `admin.html` → **Staff Accounts** tab once logged in as Admin — same effect, just a form instead of SQL.)

**Student accounts** — created directly from `admin.html` → **Students** tab: name, roll number, class/section, major, and a password. Saving hashes the password automatically.

## 2. Day-to-day use
- **Admin** (`/admin.html`): everything.
- **Teacher** (`/teacher.html`):
  - **Gallery** — "Add photos from one event": fill in Category/Event/Caption once, then choose *multiple* photos at once — one row is created per photo, all sharing that category/event. Individual photos below can still be edited/reordered/deleted one at a time.
  - **Resources** — pick a subject, upload PDF/Word/PowerPoint/image files for it.
- **Student** (`/student.html`): log in, pick a subject tab, Download or Share any file.

Every save writes straight to Supabase — changes appear on the live site within seconds.

## 3. If something looks broken
Run this in Supabase SQL Editor to see exactly which security rules are active:
```sql
select tablename, policyname, qual, with_check from pg_policies
where schemaname = 'public' order by tablename;
```
Every row should reference `is_admin()`, `is_staff()`, `true`, or `auth.uid() = user_id`. If any row shows the raw text `select 1 from staff_roles` directly, that one is the old broken version — re-run `supabase_fix_v2_policies.sql`.

## 4. Push these files to GitHub / Netlify
```bash
git add .
git commit -m "Split Admin/Teacher portals, add gallery bulk upload, fix RLS recursion"
git push
```
Netlify picks it up and redeploys automatically.

## New in this update
- **Teachers now have a subject** (Physics, Chemistry, etc.) set in `admin.html` → Staff Accounts. Their `/teacher.html` Resources tab is locked to that subject only.
- **Students can be managed by both Admin and Teacher** — added a Students tab to `/teacher.html` too.
- **Admission applications go to the Admin dashboard** — the public "Apply for Admission" form now saves straight into Supabase; view/manage them in `admin.html` → Applications tab (mark as reviewed/contacted/archived, or delete).
- Run `supabase_migration_v3.sql` once (adds the `subject` column, opens Students up to Teachers, and creates the `applications` table).

## Update: Subjects editable, Faculty photos, admission button removed
- Removed the header "Apply for Admission" button (the Contact section form + Applications tab still work).
- **Subjects on Offer** (the periodic-table tiles) are now editable from `admin.html` → new **Subjects** tab: name, symbol, periods/week, description, reorderable.
- **Faculty photos** — upload a real photo per faculty member in `admin.html` → Faculty tab; falls back to the initials avatar if no photo is set.
- Run `supabase_migration_v4.sql` once (creates the `subjects` table seeded with your current 7 subjects, and adds a `photo_url` column to `faculty`).

## Login "Invalid login credentials" fix
If a newly created Admin/Teacher account can't log in with the right password, it's almost always unconfirmed email. Fix once for the whole project:
Supabase → **Authentication → Sign In / Providers → Email** → turn **off** "Confirm email". Then recreate the user (or it'll work for existing ones on next login attempt, depending on Supabase's caching).

## Update: Staff Accounts merged into Faculty
The separate "Staff Accounts" tab is gone. Instead, each entry in `admin.html` → **Faculty** has an optional **"Teacher Portal Access"** box at the bottom:
- **Supabase Auth User UUID** — paste this only if that person should log into `/teacher.html`.
- **Subject** — controls which Resources tab they can upload to.

Leave both blank for faculty who are just listed on the site (no login). This still requires creating the person's account once in Supabase → Authentication → Users → Add user (unavoidable — that's what a real login is) — but there's no more separate table/tab to duplicate their info into.

Run `supabase_migration_v6.sql` once (adds the linking columns to `faculty`).

Note: removing a faculty member from the Faculty tab does **not** automatically revoke their teacher login (to avoid ever accidentally deleting the Admin's own access by mistake) — if you need to fully revoke someone's access, delete their row directly from the `staff_roles` table in Supabase's Table Editor.
