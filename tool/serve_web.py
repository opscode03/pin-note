"""本地静态服务器（带 SPA 回退）：用于 Flutter Web 构建产物的预览验证。

用法：python3 tool/serve_web.py [port] [root]
所有未知路径都回退到 index.html，使 /notes 等路由可直接打开。
"""

import http.server
import os
import sys

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8137
ROOT = sys.argv[2] if len(sys.argv) > 2 else 'build/web'


class SPAHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=ROOT, **kwargs)

    def send_response(self, code, message=None):
        # 禁用缓存，便于热更验证
        super().send_response(code, message)

    def end_headers(self):
        self.send_header('Cache-Control', 'no-store')
        super().end_headers()

    def do_GET(self):  # noqa: N802
        path = self.translate_path(self.path)
        if not os.path.exists(path) and not self.path.startswith('/assets'):
            self.path = '/index.html'
        super().do_GET()


if __name__ == '__main__':
    server = http.server.ThreadingHTTPServer(('127.0.0.1', PORT), SPAHandler)
    print(f'serving {ROOT} at http://127.0.0.1:{PORT}')
    server.serve_forever()
