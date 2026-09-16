import http.server
import socketserver
import os
import sys
import urllib.parse

PORT = 5050
DIRECTORY = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'docs')

class ThreadedHTTPServer(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True
    allow_reuse_address = True

class SanctuaryHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', '*')
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path

        # Redirect root to /allinone/
        if path in ('', '/'):
            self.send_response(302)
            self.send_header('Location', '/allinone/')
            self.end_headers()
            return

        # Handle /allinone prefix
        if path.startswith('/allinone'):
            rel_path = path[len('/allinone'):]
            if not rel_path or rel_path == '/':
                self.path = '/index.html'
            else:
                self.path = rel_path + (f"?{parsed.query}" if parsed.query else "")
        
        return super().do_GET()

    def guess_type(self, path):
        if path.endswith('.wasm'):
            return 'application/wasm'
        if path.endswith('.json'):
            return 'application/json'
        if path.endswith('.js'):
            return 'application/javascript'
        return super().guess_type(path)

if __name__ == '__main__':
    with ThreadedHTTPServer(("", PORT), SanctuaryHandler) as httpd:
        print(f"[Sanctuary] Flutter Web Server running at http://localhost:{PORT}/allinone/")
        sys.stdout.flush()
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            pass
