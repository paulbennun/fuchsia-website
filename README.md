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

## Editing the homepage

Edits are made visually, then saved **straight into this folder** by a tiny local
server (`edit.py`) — no downloads, nothing trapped in the browser.

1. Start the editor server:
   ```bash
   python3 edit.py
   ```
2. Open **http://localhost:8765/editor.html** and click any text to edit it.
3. Click **Save to site** — this writes `index.html` directly into this repo (on disk).
4. Publish it:
   ```bash
   ./publish.sh "what you changed"
   ```
   `publish.sh` commits, pushes, and confirms the GitHub Pages build.

Notes:
- `editor.html` is a local-only tool (gitignored, never published). Opening it as a
  plain `file://` page without the server running still works, but **Save to site**
  falls back to a download in that case — run `edit.py` for the reliable path.
- `publish.sh` refuses to publish the editor file by mistake, and you can still point
  it at a specific file: `./publish.sh ~/Downloads/index.html "message"`.

## Adding an announcement

The homepage carries a short **Latest** list — `index.html`, `<section id="latest">`. Dated
announcements, each with an optional link out to a post hosted anywhere. It is edited by hand:
no feed, no build step, nothing to keep in sync.

**To add one**, paste a new `<li>` at the *top* of `<ul class="update-list">`:

```html
      <li class="update">
        <time class="update-date" datetime="2026-09-04">4 September 2026</time>
        <p class="update-body">One sentence, in plain English. <a href="https://…">Read the post &#8594;</a></p>
      </li>
```

Drop the `<a>` for an announcement that has nowhere to point. The `datetime` attribute is the
machine-readable date (`YYYY-MM-DD`); the text between the tags is what a reader sees, so write
it however reads best.

**Then delete the fourth row.** The list is capped at **three**, deliberately. The section is
called *Latest*, and a list that only ever grows stops being that — an update log nobody prunes
reads as abandoned, which is worse than not having one at all. Pruning is one line.

⚠️ **Every row is a published claim.** Anything a row asserts about Fuchsia Studio is held to the
same standard as the product pages: say what has shipped. If a row describes something that is
still coming, say so in those words. Route new product claims through the copy grid before they
go up, exactly as the other pages' copy is routed.

If the list ever genuinely needs to be longer than three, lift the whole `<ul>` into its own
`news.html` — the markup was written so that move needs no re-authoring, only a new page shell.

© 2026 Fuchsia, LLC. All rights reserved.
