# BAEMS STUDY — Bageshwari Academy E.M. School (+2 Science)

Live site: https://baems.netlify.app
Admin (Admin + Teacher login): https://baems.netlify.app/admin.html
Student portal: https://baems.netlify.app/student.html

## What's here
- `index.html` — public site: about, subjects, faculty, **Gallery** (photos, downloadable/shareable), notices, contact.
- `admin.html` — single login-gated control panel for **Admin** and **Teacher** roles.
- `student.html` — separate, read-only portal for students: browse and download/share subject resources.
- `content/*.json` — all editable data (see below). `assets/logo.png` — logo fallback.
- `robots.txt`, `sitemap.xml`, `netlify.toml` — SEO / deploy config.

## Roles at a glance

| Role | Logs in at | Sees | Can write? |
|---|---|---|---|
| **Admin** | `/admin.html` → Admin tab | Everything: Site Settings, Notices, Faculty, Students, Staff Accounts, Gallery, Resources | Yes, via GitHub token |
| **Teacher** | `/admin.html` → Teacher tab | Only Gallery + Resources | Yes, via the same GitHub token mechanism |
| **Student** | `/student.html` | Their subjects' resource files only | No — view/download/share only |

### ⚠️ Be honest with yourself about what this actually protects
This is a fully static site — there's no real server checking passwords. Practically, that means:
- **Admin/Teacher password check** happens in the browser. It stops casual visitors, not a determined technical person.
- **"Teacher has less access than Admin"** is a UI convenience. Under the hood a teacher uses the same GitHub-connected token to save, which technically has full write access to the whole repo. Only hand out teacher logins to people you'd trust with the admin login too.
- **Student passwords** are hashed (SHA-256) before being saved, so they aren't stored as plain text — but the file they're hashed into (`content/students.json`) has to be fetched directly by the public `student.html` page, so it's served publicly by Netlify regardless of whether your GitHub repo is public or private. Don't put anything more sensitive than name / roll number / class / major in there.

If you ever need real security (e.g. protecting actual grades or sensitive records), that needs a proper backend with server-side authentication — a good next step if the school outgrows this setup.

---

## 1. Log in

**Admin:** `/admin.html` → keep "Admin" selected → username `admin`, password `baems2063`.
**Change this password**: open `admin.html`, search for `u === 'admin' && p === 'baems2063'`, and edit it.

**Teacher:** created by an Admin under the **Staff Accounts** tab (name, username, password). Teachers then log in at `/admin.html` → "Teacher" tab.

**Student:** created by an Admin under the **Students** tab (name, roll number, class/section, major, password). Students log in at `/student.html` with roll number + password.

## 2. One-time connection setup (per device, Admin/Teacher only)
The first time anyone logs into `/admin.html` on a given browser, a **Connection Setup** panel appears:

**GitHub token:**
1. GitHub → profile photo → **Settings** → **Developer settings** → **Personal access tokens** → **Fine-grained tokens** → **Generate new token**.
2. **Repository access** → **Only select repositories** → `baems82-83/baems`.
3. **Permissions** → **Contents** → **Read and write**.
4. Generate, copy (starts with `github_pat_...`), paste into the setup panel.

**Cloudinary:** cloud name `tvp2hzjn` and preset `ml_default` are pre-filled. Confirm in Cloudinary → Settings → Upload → Upload presets that `ml_default` is **Unsigned**. For PDF/Word/PowerPoint uploads (used in Resources), Cloudinary may also require enabling **unsigned uploads of raw file types** — if a non-image upload fails, check Cloudinary → Settings → Upload → Security for that toggle.

Click **Save Connection & Load**. The browser remembers this — after that, just username/password is needed. Use **⚙** to reconfigure, **Log out** to end the session.

## 3. Day-to-day use
- **Admin**: manage everything, plus create Teacher and Student accounts.
- **Teacher**: **Gallery** tab (add event/activity photos by category) and **Resources** tab (upload subject files — pick a subject, click **+ Upload File**, choose a PDF/DOCX/PPTX/image).
- **Student**: log in at `/student.html`, pick a subject tab, **Download** or **Share** any file.

Every Save commits to GitHub; Netlify redeploys automatically, usually live within a minute.

---

## 4. Push these files to GitHub (only needed once, to add what's new)
**Browser method:** open your repo on GitHub → **Add file** → **Upload files** → drag in `admin.html`, `student.html`, the `content/` folder, and the updated `index.html` / `robots.txt` / `sitemap.xml` → **Commit changes**.

**Git method:**
```bash
git add .
git commit -m "Add Gallery, Student Portal, Teacher role, and Resources"
git push
```
