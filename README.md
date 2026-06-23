# Fuchsia website

The website for **Fuchsia, LLC** (`fuchsiaprojects.com`) and its app, **Fuchsia Studio**.
A hand-built static site — no framework, no build step. Open any `.html` file directly,
or serve the folder.

## Pages

| File | Purpose |
|------|---------|
| `index.html` | Company homepage (Fuchsia) |
| `studio.html` | Fuchsia Studio landing page (optional App Store "Marketing URL") |
| `support.html` | Fuchsia Studio support page (Apple "Support URL") |
| `privacy.html` | Fuchsia Studio privacy policy (Apple "Privacy Policy URL") |
| `editor.html` | In-browser content editor for the homepage (not linked publicly) |
| `assets/` | Logos and brand images |
| `icon.svg` | Favicon |

## Local preview

Just open `index.html` in a browser, or run a tiny static server:

```bash
python3 -m http.server 8000
# then visit http://localhost:8000
```

## Hosting (GitHub Pages)

This repo is deployed with GitHub Pages from the `main` branch (root). The `.nojekyll`
file tells Pages to serve all files as-is. A custom domain is configured via the
repository's **Settings → Pages** and a `CNAME` file (added when the domain is wired up).

© 2026 Fuchsia, LLC. All rights reserved.
