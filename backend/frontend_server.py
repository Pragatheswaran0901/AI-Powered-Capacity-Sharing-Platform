import http.server
import os
import socketserver
import sys

PORT = 3000
DIRECTORY = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "frontend", "build", "web"))

class SPAHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def do_GET(self):
        # Resolve real path
        real_path = self.translate_path(self.path)
        # If file does not exist and doesn't have an extension, rewrite to index.html for Flutter GoRouter SPA navigation
        if not os.path.exists(real_path) and "." not in os.path.basename(self.path):
            self.path = "/index.html"
        return super().do_GET()

    def end_headers(self):
        # Add CORS and cache headers
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        super().end_headers()

if __name__ == "__main__":
    if not os.path.isdir(DIRECTORY):
        print(f"Error: Build directory not found: {DIRECTORY}", file=sys.stderr)
        sys.exit(1)
        
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("0.0.0.0", PORT), SPAHandler) as httpd:
        print(f"Mach-Hunt Frontend Web Server running at http://localhost:{PORT}")
        print(f"Serving directory: {DIRECTORY}")
        sys.stdout.flush()
        httpd.serve_forever()
