#!/usr/bin/env python3
"""
Carrius 藥品外觀即時 POC — 本機代理伺服器
- 服務 drug-live-poc.html
- 代理 /api/drugs?q=…  → drugtw.com（解決瀏覽器 CORS）
- 代理 /img?u=<url>    → 伺服器端抓圖（解決熱連 403 / 混合內容 / referer）

僅供 POC 評估用。資料來源：藥台灣 drugtw.com（聚合食藥署 + 藥師公會 + 各醫院），
圖片版權屬各原始來源，未取得授權前不得用於正式 App。

用法：python3 drug_live_poc_server.py [port]
"""
import sys, os, json, urllib.parse, urllib.request, ssl
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 3500
HERE = os.path.dirname(os.path.abspath(__file__))
HTML = os.path.join(HERE, "drug-live-poc.html")

# 只允許這些網域被 /img 代理，避免變成開放代理（SSRF 防護）
ALLOW_HOSTS = (
    "drugtw.com", "mcp.fda.gov.tw", "lmspiq.fda.gov.tw",
    "taiwan-pharma.org.tw", "ndmctsgh.edu.tw", "blob.core.windows.net",
    "ccgh.com.tw", "cch.org.tw", "cgh.org.tw", "tygh.mohw.gov.tw",
)
UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
CTX = ssl.create_default_context()
CTX.check_hostname = False
CTX.verify_mode = ssl.CERT_NONE  # 部分醫院站憑證鏈不完整，POC 容忍


def fetch(url, referer=None, timeout=25):
    req = urllib.request.Request(url, headers={
        "User-Agent": UA,
        "Referer": referer or (url.split("/")[0] + "//" + urllib.parse.urlparse(url).netloc + "/"),
        "Accept": "*/*",
    })
    return urllib.request.urlopen(req, timeout=timeout, context=CTX)


class H(BaseHTTPRequestHandler):
    def log_message(self, *a):  # 安靜
        pass

    def _send(self, code, ctype, body, extra=None):
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Access-Control-Allow-Origin", "*")
        if extra:
            for k, v in extra.items():
                self.send_header(k, v)
        self.end_headers()
        if isinstance(body, str):
            body = body.encode("utf-8")
        if body:
            self.wfile.write(body)

    def do_GET(self):
        u = urllib.parse.urlparse(self.path)
        qs = urllib.parse.parse_qs(u.query)

        if u.path in ("/", "/index.html", "/drug-live-poc.html"):
            try:
                with open(HTML, "rb") as f:
                    self._send(200, "text/html; charset=utf-8", f.read())
            except Exception as e:
                self._send(500, "text/plain; charset=utf-8", "找不到 drug-live-poc.html：%s" % e)
            return

        if u.path == "/api/drugs":
            q = (qs.get("q") or [""])[0].strip()
            if not q:
                self._send(400, "application/json", json.dumps({"error": "missing q"}))
                return
            try:
                api = "https://drugtw.com/api/drugs?q=" + urllib.parse.quote(q)
                with fetch(api, referer="https://drugtw.com/") as r:
                    data = r.read()
                self._send(200, "application/json; charset=utf-8", data)
            except Exception as e:
                self._send(502, "application/json", json.dumps({"error": str(e)}))
            return

        if u.path == "/img":
            target = (qs.get("u") or [""])[0]
            host = urllib.parse.urlparse(target).netloc.lower()
            if not target or not any(host == h or host.endswith("." + h) for h in ALLOW_HOSTS):
                self._send(403, "text/plain; charset=utf-8", "host not allowed")
                return
            try:
                with fetch(target, timeout=8) as r:  # 死站快速失敗，讓前端換下一張
                    ctype = r.headers.get("Content-Type", "image/jpeg")
                    self._send(200, ctype, r.read(), extra={"Cache-Control": "max-age=3600"})
            except Exception as e:
                self._send(502, "text/plain; charset=utf-8", "img fetch failed: %s" % e)
            return

        self._send(404, "text/plain; charset=utf-8", "not found")


if __name__ == "__main__":
    print("Carrius 藥品 POC 代理啟動： http://localhost:%d" % PORT)
    ThreadingHTTPServer(("127.0.0.1", PORT), H).serve_forever()
