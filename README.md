# BAEMS STUDY — Bageshwari Academy E.M. School (+2 Science)

Live site: https://baems.netlify.app
Admin/Teacher login: https://baems.netlify.app/admin.html
Student portal: https://baems.netlify.app/student.html

Backend: **Supabase** (Postgres database + real authentication + file storage). No GitHub token juggling anymore — this replaces that entirely.

## What's here
- `index.html` — public site. Reads settings/notices/faculty/gallery live from Supabase.
- `admin.html` — Admin + Teacher control panel. Real login via Supabase Auth.
- `student.html` — student portal. Roll number + password, checked securely inside the database.
- `supabase_schema.sql` — the database setup script. **Already run once** in your Supabase project.
- `assets/logo.png` — local fallback only; the live logo comes from Supabase Storage once uploaded via the admin panel.
- `robots.txt`, `sitemap.xml`, `netlify.toml` — SEO / deploy config.

There's no more `content/*.json` and no GitHub token anywhere in these files — all data lives in your Supabase project (`xbmdumntkpxafswhbgvb`), and the connection is made with a public "anon" key, which is designed to be safe to embed (real protection comes from database-level rules, not from hiding the key).

## Roles at a glance

| Role | Logs in at | Account type | Sees |
|---|---|---|---|
| **Admin** | `/admin.html` | Real Supabase Auth (email + password) | Everything |
| **Teacher** | `/admin.html` | Real Supabase Auth (email + password) | Only Gallery + Resources |
| **Student** | `/student.html` | Roll number + password (checked inside the database) | Their subjects' resource files, read-only |

### Why this is meaningfully more secure than the earlier GitHub-token version
- **Admin/Teacher passwords are never visible anywhere** — Supabase Auth handles them entirely server-side. There's nothing to leak by viewing page source.
- **Who can write what is enforced by the database itself** (Row Level Security), not just hidden by which tabs the page shows. A Teacher account genuinely cannot write to Notices/Faculty/Students/Settings — Postgres rejects it, not just the UI.
- **Student passwords** are hashed with bcrypt inside Postgres and checked by a database function — the browser never sees the hash or the real password comparison.

## 1. Creating logins

**Admin / Teacher accounts** (done once per person, in the Supabase dashboard — not from the site):
1. Supabase → **Authentication → Users → Add user** → real email + password.
2. Copy that user's UUID from the Users list.
3. Supabase → **SQL Editor**, run:
   ```sql
   insert into staff_roles (user_id, role, name)
   values ('PASTE-THE-UUID-HERE', 'admin', 'Their Name');
   -- use 'teacher' instead of 'admin' for a teacher account
   ```
   (You can also do this from `admin.html` → **Staff Accounts** tab once you're logged in as an Admin — same effect, just a form instead of SQL.)

**Student accounts** — created directly from `admin.html` → **Students** tab (no Supabase dashboard needed): name, roll number, class/section, major, and a password. Saving hashes the password automatically.

## 2. Day-to-day use
- **Admin**: everything — Site Settings, Notices, Faculty, Students, Staff Accounts, Gallery, Resources.
- **Teacher**: Gallery (event/activity photos) and Resources (subject files — PDF, Word, PowerPoint, images).
- **Student**: log in at `/student.html`, pick a subject tab, Download or Share any file.

Every save writes straight to Supabase — changes appear on the live site within a few seconds (no redeploy needed, since the site reads live data on each page load).

## 3. If you ever need to touch the database directly
Supabase → **Table Editor** shows all the data as spreadsheet-like tables — useful for a quick manual fix without going through the admin panel.

## 4. Push these files to GitHub / Netlify
Same as before — this only affects the front-end files, not your data:
```bash
git add .
git commit -m "Move backend to Supabase"
git push
```
Netlify picks it up and redeploys automatically.
