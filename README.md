# BAEMS STUDY — Bageshwari Academy E.M. School (+2 Science)

Static website + admin panel for Bageshwari Academy E.M. School's +2 Science program, Kohalpur-10, Banke.

Live: https://baems.netlify.app
Admin: https://baems.netlify.app/admin.html

## Files
- `index.html` — the site. Reads live content from `/content/*.json` on load (falls back to the text baked into the HTML if those can't be fetched).
- `admin.html` — a single self-contained admin panel. No account system to install — it talks directly to GitHub and Cloudinary from your browser using credentials you paste in once.
- `assets/logo.png` — local fallback copy of the logo.
- `content/settings.json` — school name, portal name, tagline, address, phone, email, stats, logo URL.
- `content/notices.json` — notice board items.
- `content/faculty.json` — faculty cards.
- `robots.txt`, `sitemap.xml` — SEO. `admin.html` is excluded from indexing.
- `netlify.toml` — Netlify config.

---

## 1. One-time setup for the admin panel (~5 minutes)

**A — GitHub token** (lets the admin panel save changes to your repo)
1. GitHub → your profile photo → **Settings** → **Developer settings** → **Personal access tokens** → **Fine-grained tokens** → **Generate new token**.
2. Name it anything, e.g. `BAEMS STUDY Admin`.
3. Under **Repository access**, choose **Only select repositories** → pick `baems82-83/baems`.
4. Under **Permissions** → **Repository permissions** → set **Contents** to **Read and write**.
5. Generate the token and copy it (starts with `github_pat_...`). GitHub only shows it once.

**B — Cloudinary unsigned upload preset** (lets the admin panel upload images without exposing your Cloudinary secret)
1. Cloudinary dashboard → **Settings** (gear icon) → **Upload** tab → **Upload presets** → **Add upload preset**.
2. Set **Signing Mode** to **Unsigned**. Save, and copy the preset's name.

**C — Connect**
1. Go to `https://baems.netlify.app/admin.html`
2. Paste in your GitHub token, confirm the repo is `baems82-83/baems` and branch is `main`, confirm the Cloudinary cloud name is `tvp2hzjn`, and paste in your upload preset name.
3. Click **Connect & Load**. Your token and these settings are saved only in this browser's local storage — they aren't sent anywhere except directly to GitHub and Cloudinary.

Keep your GitHub token private — anyone who has it can edit the repo's content (nothing else, since it's scoped to this one repo).

---

## 2. Day-to-day editing
Once connected, `admin.html` has three tabs:
- **Site Settings** — portal name, school name, tagline, contact info, stats, and logo (upload a new one directly — it goes to Cloudinary and updates automatically)
- **Notices** — add, edit, reorder, or delete notice board items
- **Faculty** — add, edit, reorder, or delete faculty cards

Each tab has its own **Save** button. Saving commits straight to GitHub, and Netlify redeploys the live site automatically — usually within a minute.

---

## 3. Push everything to GitHub (only needed once, to add these new files)

**Browser method:** open your repo on GitHub → **Add file** → **Upload files** → drag in `admin.html`, the `content/` folder, and the updated `index.html`/`robots.txt`/`sitemap.xml` → **Commit changes**.

**Git method:**
```bash
git add .
git commit -m "Add BAEMS STUDY admin panel + Cloudinary + dynamic content"
git push
```
