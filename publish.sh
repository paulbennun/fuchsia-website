#!/usr/bin/env bash
#
# publish.sh — push editor changes live in one step.
#
# Workflow:
#   1. Edit in editor.html, click "Download site" (saves index.html to ~/Downloads)
#   2. Run:  ./publish.sh "optional commit message"
#
# It grabs the freshly downloaded index.html, drops it into this repo,
# commits, and pushes. GitHub Pages rebuilds automatically (once Pages is on).
#
# You can also point it at a specific file:
#   ./publish.sh ~/Downloads/index.html "new homepage copy"

set -euo pipefail

# Always operate on the repo this script lives in.
cd "$(dirname "$0")"

DOWNLOADS="${HOME}/Downloads"
SRC=""

# If the first argument is an existing file, treat it as the source.
if [[ $# -gt 0 && -f "$1" ]]; then
  SRC="$1"; shift
fi
MSG="$*"

# Otherwise use the newest index*.html in ~/Downloads (handles "index (1).html").
if [[ -z "$SRC" ]]; then
  SRC="$(ls -t "$DOWNLOADS"/index*.html 2>/dev/null | head -n1 || true)"
fi

if [[ -z "$SRC" || ! -f "$SRC" ]]; then
  echo "✗ Couldn't find an exported index.html."
  echo "  Export from editor.html (Download site), or pass the path:"
  echo "    ./publish.sh ~/Downloads/index.html \"my message\""
  exit 1
fi

# Safety net 1: never publish the editor itself.
if grep -q 'id="editorbar"\|id="editorjs"' "$SRC"; then
  echo "✗ \"$SRC\" is the EDITOR (editor.html), not an exported site. Aborting."
  exit 1
fi
# Safety net 2: make sure it actually looks like the Fuchsia homepage.
if ! grep -qi '<title>[^<]*Fuchsia' "$SRC"; then
  echo "✗ \"$SRC\" doesn't look like the Fuchsia homepage. Aborting to be safe."
  exit 1
fi

echo "→ Source: $SRC"
cp "$SRC" index.html

if git diff --quiet -- index.html; then
  echo "• No changes to index.html — nothing to publish."
  exit 0
fi

echo "→ Changes detected:"
git --no-pager diff --stat -- index.html

git add index.html
[[ -z "$MSG" ]] && MSG="Update homepage content (via editor) — $(date '+%Y-%m-%d %H:%M')"
git commit -q -m "$MSG"
echo "✓ Committed: $MSG"

if git remote get-url origin >/dev/null 2>&1; then
  git push -q
  echo "✓ Pushed. GitHub Pages rebuilds in ~1 min (once Pages is enabled)."
else
  echo "• No git remote set — committed locally only."
fi
