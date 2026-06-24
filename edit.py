#!/usr/bin/env python3
"""
Local editor server for the Fuchsia site.

Why this exists: editing in the browser kept losing changes (they lived only in
browser local storage, and "Download" landed somewhere unfindable). This serves
the editor from localhost and lets the "Save to site" button write index.html
straight into this repo folder — on disk, where git (and Claude) can see it.

Run it:
    python3 edit.py
Then open:
    http://localhost:8765/editor.html
Edit, click "Save to site" (writes index.html here), then run ./publish.sh to go live.

It only listens on 127.0.0.1 (your machine), only ever writes index.html, and
refuses anything that still contains the editor's own toolbar.
"""

import http.server
import socketserver
import os
from urllib.parse import urlparse

ROOT = os.path.dirname(os.path.abspath(__file__))
PORT = 8765


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=ROOT, **kwargs)

    def do_POST(self):
        if urlparse(self.path).path != "/__save":
            self.send_error(404, "Not found")
            return
        try:
            length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(length).decode("utf-8")
        except Exception as e:  # noqa: BLE001
            self._json(400, {"ok": False, "error": f"bad body: {e}"})
            return

        # Guardrails: must look like the homepage, must NOT contain editor chrome.
        if 'id="editorbar"' in body or 'id="editorjs"' in body:
            self._json(400, {"ok": False, "error": "refused: contains editor chrome"})
            return
        if "<title" not in body or "Fuchsia" not in body:
            self._json(400, {"ok": False, "error": "refused: doesn't look like the site"})
            return

        target = os.path.join(ROOT, "index.html")
        try:
            with open(target, "w", encoding="utf-8") as f:
                f.write(body)
        except Exception as e:  # noqa: BLE001
            self._json(500, {"ok": False, "error": str(e)})
            return

        print(f"[edit] wrote index.html ({len(body)} bytes)")
        self._json(200, {"ok": True, "bytes": len(body)})

    def _json(self, code, obj):
        import json
        payload = json.dumps(obj).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def end_headers(self):
        # Never cache while editing.
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def log_message(self, *args):
        pass  # keep the console quiet


if __name__ == "__main__":
    os.chdir(ROOT)
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("127.0.0.1", PORT), Handler) as httpd:
        print("\n  Fuchsia editor is running.")
        print(f"  →  open  http://localhost:{PORT}/editor.html")
        print("     edit, click “Save to site”, then run  ./publish.sh  to go live.")
        print("     (Ctrl-C to stop)\n")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n  stopped.\n")
