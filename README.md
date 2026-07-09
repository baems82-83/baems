# BAEMS STUDY — Bageshwari Academy E.M. School (+2 Science)

Static website for Bageshwari Academy E.M. School's +2 Science program, Kohalpur-10, Banke.

## Files
- `index.html` — the whole site (HTML + CSS + JS in one file)
- `assets/logo.png` — school logo
- `robots.txt`, `sitemap.xml` — SEO
- `netlify.toml` — Netlify config

Before going live, replace `https://baemsstudy.netlify.app/` in `index.html`, `robots.txt`, and `sitemap.xml` with your real final URL (your Netlify URL or custom domain, once you have it).

---

## 1. Push to GitHub

**Option A — no terminal, just the browser (easiest):**
1. Go to https://github.com and log in.
2. Click **+** (top right) → **New repository**. Name it `baems-study` → **Create repository**.
3. On the empty repo page, click **uploading an existing file**.
4. Drag in `index.html`, `robots.txt`, `sitemap.xml`, `netlify.toml`, and the whole `assets` folder.
5. Scroll down → **Commit changes**.

**Option B — using git on your computer**, from inside this folder:
```bash
git init
git add .
git commit -m "BAEMS STUDY site"
git branch -M main
git remote add origin https://github.com/<your-username>/baems-study.git
git push -u origin main
```

---

## 2. Deploy on Netlify

**Recommended — connect GitHub (auto-deploys every future push):**
1. Go to https://app.netlify.com → **Add new site** → **Import an existing project**.
2. Choose **GitHub**, authorize it, pick the `baems-study` repo.
3. Build settings: leave **Build command** empty, **Publish directory** = `.` (root).
4. Click **Deploy**.
5. Netlify gives you a URL like `random-name-123.netlify.app`. You can rename it: **Site settings → Change site name** → set it to something like `baems-study`, so your URL becomes `baems-study.netlify.app`.

**Quick alternative — drag and drop (no GitHub link, manual re-upload each time):**
1. Go to https://app.netlify.com/drop
2. Drag the whole project folder in. Done — it's live immediately.

---

## 3. After you have your real URL
Update these 4 spots in `index.html` (search for `netlify.app`):
- `<link rel="canonical" ...>`
- `<meta property="og:url" ...>`
- `<meta property="og:image" ...>`
- the `"url"` and `"logo"` fields in the JSON-LD script

Also update the same URL in `robots.txt` (Sitemap line) and `sitemap.xml`.

## 4. Get it indexed by Google (optional but recommended)
1. Go to https://search.google.com/search-console
2. Add your site (the Netlify or custom domain URL).
3. Submit `sitemap.xml` under **Sitemaps**.
4. Use **URL Inspection** → **Request Indexing** on the homepage.
