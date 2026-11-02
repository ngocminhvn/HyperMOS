"""Small Telegram workflow notifications using only the Python standard library."""
import html
import json
import os
import urllib.request


def send(status):
    token = os.environ.get("TELEGRAM_BOT_TOKEN", "").strip()
    recipients = list(dict.fromkeys(
        value.strip() for value in (
            os.environ.get("TELEGRAM_CHANNEL_ID", ""),
            os.environ.get("BUILDER_ID", ""),
        ) if value.strip()
    ))
    if not token or not recipients:
        print("::warning::Telegram token or recipients missing; notification skipped.")
        return
    repo = os.environ.get("GITHUB_REPOSITORY", "")
    run_id = os.environ.get("GITHUB_RUN_ID", "")
    run_url = f"https://github.com/{repo}/actions/runs/{run_id}"
    labels = {"start": "⏳ Bắt đầu", "pack": "📦 Đóng gói", "upload": "⬆️ Tải lên",
              "success": "✅ Hoàn tất", "failure": "❌ Thất bại", "cancelled": "✖ Đã hủy"}
    title = os.environ.get("NOTIFY_TITLE", "FastbootD")
    text = f"<b>{html.escape(title)} — {labels.get(status, html.escape(status))}</b>"
    text += f'\n<a href="{html.escape(run_url, quote=True)}">Info ↗</a>'
    if status == "success":
        text += f' · <a href="{html.escape(run_url, quote=True)}#artifacts">Tải kết quả ↗</a>'
    for chat_id in recipients:
        payload = json.dumps({"chat_id": chat_id, "text": text, "parse_mode": "HTML",
                              "disable_web_page_preview": True}).encode("utf-8")
        request = urllib.request.Request(f"https://api.telegram.org/bot{token}/sendMessage",
                                         data=payload, headers={"Content-Type": "application/json"})
        try:
            with urllib.request.urlopen(request, timeout=25) as response:
                result = json.load(response)
            if not result.get("ok"):
                raise RuntimeError("Telegram rejected notification")
            print("Telegram notification sent.")
        except Exception:
            # Keep each recipient independent; never log a token-bearing request URL.
            print("::warning::Could not deliver Telegram notification to a recipient.")


if __name__ == "__main__":
    send(os.environ.get("NOTIFY_STATUS", "start"))
