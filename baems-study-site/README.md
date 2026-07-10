# BAEMS STUDY — Bageshwari Academy E.M. School (+2 Science)

Static website + admin panel for Bageshwari Academy E.M. School's +2 Science program, Kohalpur-10, Banke.

Live: https://baems.netlify.app

## Files
- `index.html` — the site. Reads live content from `/content/*.json` on load (falls back to the text baked into the HTML if those can't be fetched).
- `assets/logo.png` — local copy of the logo (kept as a fallback; the live logo comes from Cloudinary once set up).
- `content/settings.json` — school name, portal name, tagline, address, phone, email, stats, logo URL.
- `content/notices.json` — notice board items.
- `content/faculty.json` — faculty cards.
- `admin/index.html` + `admin/config.yml` — the admin panel (Sveltia CMS). Edit content at **/admin/** without touching code.
- `robots.txt`, `sitemap.xml` — SEO. `/admin/` is excluded from indexing.
- `netlify.toml` — Netlify config.

---

## 1. Turn on the admin panel (one-time setup, ~10 minutes)

The admin panel needs a way to log in and save changes to your GitHub repo (`baems82-83/baems`). Since your site is already on Netlify, this is the simplest path — no extra services needed.

**Step A — Register a GitHub OAuth App**
1. GitHub → click your profile photo → **Settings** → **Developer settings** → **OAuth Apps** → **New OAuth App**.
2. Fill in:
   - Application name: `BAEMS STUDY Admin`
   - Homepage URL: `https://baems.netlify.app`
   - Authorization callback URL: `https://api.netlify.com/auth/done`
3. Click **Register application**, then **Generate a new client secret**.
4. Copy the **Client ID** and **Client Secret** — you'll paste these into Netlify next.

**Step B — Add them to Netlify**
1. Go to your site on Netlify → **Project configuration** → **Access & security** (sometimes labelled **Security**) → find the **OAuth** section.
2. Add a provider: choose **GitHub**, paste in the Client ID and Client Secret from Step A.
3. Save.

**Step C — Log in**
1. Push all these files to GitHub (see section 3 below) and let Netlify redeploy.
2. Go to `https://baems.netlify.app/admin/`
3. Click **Sign in with GitHub** then authorize. You're in.

Only people with write access to the `baems82-83/baems` GitHub repo will be able to log in and save changes — that's controlled entirely by your GitHub repo's Collaborators settings.

---

## 2. Connect Cloudinary for images

Your Cloudinary cloud name is `tvp2hzjn` (already wired into `admin/config.yml`). One thing left to do:

1. Go to your Cloudinary dashboard, Settings (gear icon), API Keys.
2. Copy your API Key (the public one, not the API Secret).
3. Open `admin/config.yml`, find this line:
   ```
   api_key: YOUR_CLOUDINARY_API_KEY
   ```
   and replace `YOUR_CLOUDINARY_API_KEY` with the key you copied.

**To move the logo to Cloudinary:**
1. In Cloudinary, Media Library, Upload, upload `logo.png` into a folder, e.g. `baems/logo`.
2. Click the uploaded image, copy its Secure URL (looks like `https://res.cloudinary.com/tvp2hzjn/image/upload/v.../baems/logo.png`).
3. Open `content/settings.json` and set:
   ```
   "logo": "https://res.cloudinary.com/tvp2hzjn/image/upload/.../baems/logo.png"
   ```
   Or, once the admin panel (`/admin/`) is working, just open Site Settings, Logo, and re-upload it there — that field is already wired to Cloudinary.

From then on, any image you upload in the admin panel goes to Cloudinary automatically.

---

## 3. Push everything to GitHub

Same repo as before (`baems82-83/baems`), just add these new files/folders on top: `admin/`, `content/`, and the updated `index.html`, `robots.txt`, `sitemap.xml`.

**Browser method:** open your repo on GitHub, Add file, Upload files, drag in the new/changed files and folders, Commit changes. Netlify redeploys automatically within a minute or two.

**Git method:**
```bash
git add .
git commit -m "Add BAEMS STUDY admin panel + Cloudinary"
git push
```

---

## 4. Day-to-day editing (no code needed)
Go to `https://baems.netlify.app/admin/`, sign in with GitHub, and you'll see three sections:
- **Site Settings** — portal name, school name, tagline, contact info, stats, logo
- **Notices** — add/edit/remove notice board items
- **Faculty** — add/edit/remove faculty cards

Every save creates a commit on GitHub and Netlify redeploys the live site automatically, usually live within a minute.
