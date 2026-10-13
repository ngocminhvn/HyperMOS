#!/usr/bin/env python3
"""Uses the same TELEGRAM_BOT_TOKEN/TELEGRAM_CHANNEL_ID secrets as HyperMOS main."""
import html
import json
import os
from pathlib import Path
from urllib.parse import urlencode
from urllib.request import Request, urlopen

status=os.environ.get("JOB_STATUS","unknown")
url=Path("work/reports/download-url.txt")
url_text=url.read_text().strip() if url.exists() else ""
run=f"https://github.com/{os.environ.get('GITHUB_REPOSITORY','ngocminhvn/HyperMOS')}/actions/runs/{os.environ.get('GITHUB_RUN_ID','')}"
message="\n".join([
    "<b>Super IMG Editor — Xiaomi 15 Pro</b>",
    f"<b>Trạng thái:</b> {html.escape(status)}",
    f"<b>Nhánh:</b> super-img-editor",
    f"<b>Upload:</b> {html.escape(os.environ.get('UPLOAD_METHOD','unknown'))}",
    f"<b>GitHub Actions:</b> {html.escape(run)}",
    "<b>Link tải:</b>\n"+html.escape(url_text) if url_text else "<b>Link tải:</b> chưa có (xem build log).",
    "<i>Chưa xác minh tương thích AVB / boot trên máy; không coi artifact là đã được kiểm nghiệm flash.</i>"
])
token=os.environ.get("TELEGRAM_BOT_TOKEN","")
channel=os.environ.get("TELEGRAM_CHANNEL_ID","")
user=os.environ.get("BUILDER_ID","")
if not token or not channel:
    print("Telegram secrets not configured; skipping notification")
    raise SystemExit(0)
for chat in dict.fromkeys([channel,user]):
    if not chat: continue
    data=urlencode({"chat_id":chat,"text":message,"parse_mode":"HTML","disable_web_page_preview":"true"}).encode()
    req=Request(f"https://api.telegram.org/bot{token}/sendMessage",data=data)
    try:
        with urlopen(req,timeout=30) as response:
            obj=json.loads(response.read())
            if not obj.get("ok"): raise RuntimeError("Telegram API returned not ok")
            print("Telegram notification sent")
    except Exception as exc:
        print("Telegram notification failed:",type(exc).__name__,str(exc)[:150])
