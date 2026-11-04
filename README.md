# Portfolio site (static, GitHub Pages)

Plain HTML/CSS/JS, no build tools needed to host. Everything in this folder is the site.

## Update content
Project pages are generated from the case-study docs one level up. After editing a doc:

```bash
cd ..            # the portfolio folder
python3 build_site.py
```

`site/index.html`, `css/` and `js/` are hand-written; the build never overwrites them.

## Before publishing
- Preview locally: `python3 -m http.server 8765 --directory site`, then open http://localhost:8765
- No resume or GitHub link is on the site on purpose; add buttons in `index.html` when ready.

## Publish on GitHub Pages
1. Create a repo named `YifengWang289.github.io` (a user site is served at `https://YifengWang289.github.io`).
2. Copy the **contents of this `site/` folder** to the repo root and push.
3. Repo Settings → Pages → Source: deploy from branch `main`, folder `/ (root)`.
