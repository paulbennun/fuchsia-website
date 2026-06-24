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

## Publishing homepage edits

The homepage can be edited visually in `editor.html` (a local-only tool, not published).
To push those edits live in one step:

1. Open `editor.html`, make changes, click **Download site** (saves `index.html` to `~/Downloads`).
2. From this folder, run:
   ```bash
   ./publish.sh "what you changed"
   ```

`publish.sh` grabs the freshly downloaded `index.html`, drops it into the repo, commits,
and pushes — GitHub Pages rebuilds automatically (once Pages is enabled). It refuses to
publish the editor file by mistake. You can also point it at a specific file:
`./publish.sh ~/Downloads/index.html "message"`.

© 2026 Fuchsia, LLC. All rights reserved.
