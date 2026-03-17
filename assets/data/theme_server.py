#!/usr/bin/env python3
"""Tiny dev server for the myMantra theme preview.

Run:  python3 assets/data/theme_server.py
Open: http://localhost:8432
"""

import http.server
import json
import os

PORT = 8432
DATA_DIR = os.path.dirname(os.path.abspath(__file__))
ALLOWED_FILES = {"icons.yml", "theme.yml"}


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *a, **kw):
        super().__init__(*a, directory=DATA_DIR, **kw)

    def do_GET(self):
        # Handle favicon silently
        if self.path == "/favicon.ico":
            self.send_response(204)
            self.end_headers()
            return
        if self.path.startswith("/api/read/"):
            fname = self.path[len("/api/read/"):]
            if fname not in ALLOWED_FILES:
                self._json(403, {"error": "not allowed"})
                return
            fpath = os.path.join(DATA_DIR, fname)
            if not os.path.isfile(fpath):
                self._json(404, {"error": "not found"})
                return
            with open(fpath, "r", encoding="utf-8") as f:
                self._json(200, {"filename": fname, "content": f.read()})
            return
        super().do_GET()

    def do_POST(self):
        if self.path.startswith("/api/write/"):
            fname = self.path[len("/api/write/"):]
            if fname not in ALLOWED_FILES:
                self._json(403, {"error": "not allowed"})
                return
            length = int(self.headers.get("Content-Length", 0))
            body = json.loads(self.rfile.read(length))
            content = body.get("content", "")
            fpath = os.path.join(DATA_DIR, fname)
            with open(fpath, "w", encoding="utf-8") as f:
                f.write(content)
            self._json(200, {"ok": True, "filename": fname})
            return
        self._json(404, {"error": "unknown endpoint"})

    def _json(self, code, data):
        payload = json.dumps(data).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, fmt, *args):
        # Quieter logs — only show API calls
        if "/api/" in (args[0] if args else ""):
            super().log_message(fmt, *args)


if __name__ == "__main__":
    url = f"http://localhost:{PORT}/theme_preview.html"
    print(f"\n  {url}\n")
    print(f"  Serving from {DATA_DIR}")
    print("  Press Ctrl+C to stop.\n")
    with http.server.HTTPServer(("", PORT), Handler) as srv:
        try:
            srv.serve_forever()
        except KeyboardInterrupt:
            print("\nStopped.")
