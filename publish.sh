#!/usr/bin/env bash
#
# publish.sh — commit & push the current homepage, then confirm the Pages build.
#
# Normal flow (with the local editor server):
#   1. python3 edit.py                      # serves the editor on localhost
#   2. open http://localhost:8765/editor.html, edit, click "Save to site"
#      (this writes index.html straight into THIS repo — on disk)
#   3. ./publish.sh "optional commit message"
#
# You can also hand it an exported file:
#   ./publish.sh ~/Downloads/index.html "new homepage copy"

set -euo pipefail
cd "$(dirname "$0")"

SRC=""
if [[ $# -gt 0 && -f "$1" ]]; then SRC="$1"; shift; fi
MSG="$*"

# If an explicit file was given, drop it in as index.html first.
if [[ -n "$SRC" ]]; then
  if grep -q 'id="editorbar"\|id="editorjs"' "$SRC"; then
    echo "✗ \"$SRC\" is the EDITOR, not an exported site. Aborting."; exit 1
  fi
  cp "$SRC" index.html
  echo "→ Source: $SRC"
fi

# Sanity-check what we're about to publish (the repo's index.html).
if [[ ! -f index.html ]] || ! grep -qi '<title>[^<]*Fuchsia' index.html; then
  echo "✗ index.html is missing or doesn't look like the Fuchsia homepage. Aborting."; exit 1
fi
if grep -q 'id="editorbar"\|id="editorjs"' index.html; then
  echo "✗ index.html still contains editor chrome. Aborting."; exit 1
fi

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

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "• No git remote set — committed locally only."
  exit 0
fi

git push -q
echo "✓ Pushed."

# Confirm GitHub Pages actually rebuilds from THIS commit. The auto-build
# trigger occasionally skips a push (it did on 2026-06-24, right after Pages
# was first enabled), leaving the live site a commit behind. So we verify, and
# nudge a rebuild ourselves if the latest finished build is on an older commit.
if ! { command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; }; then
  echo "• Install + auth the 'gh' CLI to auto-verify the Pages build (skipped)."
  echo "  GitHub Pages should still rebuild on its own in ~1 min."
  exit 0
fi

SLUG="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)"
TARGET="$(git rev-parse HEAD)"
echo "→ Waiting for GitHub Pages to publish ${TARGET:0:7}…"

NUDGED=0
BUILT=""
STATUS=""; COMMIT=""
for i in $(seq 1 30); do
  read -r STATUS COMMIT < <(gh api "/repos/$SLUG/pages/builds/latest" \
      --jq '.status + " " + (.commit // "")' 2>/dev/null || echo "unknown ")
  if [[ "$STATUS" == "built" && "$COMMIT" == "$TARGET" ]]; then
    BUILT=1; break
  fi
  # Latest finished build is on an older commit and nothing's building → the
  # auto-trigger missed this push. Request one rebuild (once).
  if [[ "$NUDGED" -eq 0 && "$STATUS" == "built" && "$COMMIT" != "$TARGET" && "$i" -ge 3 ]]; then
    if gh api -X POST "/repos/$SLUG/pages/builds" >/dev/null 2>&1; then
      echo "• Auto-build skipped this push — requested a rebuild."
    fi
    NUDGED=1
  fi
  sleep 6
done

if [[ -n "$BUILT" ]]; then
  URL="$(gh api "/repos/$SLUG/pages" --jq .html_url 2>/dev/null || true)"
  echo "✓ Live: GitHub Pages published ${TARGET:0:7} → ${URL:-https://$SLUG.github.io/}"
else
  echo "⚠ Pages didn't confirm ${TARGET:0:7} in ~3 min (last build: ${STATUS:-?} ${COMMIT:0:7})."
  echo "  Check https://github.com/$SLUG/deployments — or re-run publish.sh to retry."
fi
