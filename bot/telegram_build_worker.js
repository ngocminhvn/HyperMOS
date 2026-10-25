/**
 * HyperMOS Telegram /b <rom-url> webhook receiver.
 * Deploy as a Cloudflare Worker; it does NOT run in GitHub Actions.
 *
 * Required Worker secrets: TELEGRAM_BOT_TOKEN, GITHUB_WORKFLOW_TOKEN.
 * Webhook authentication is SHA-256-derived from TELEGRAM_BOT_TOKEN.
 * Visit /setup-webhook to register the Telegram webhook using the existing bot token.
 * Optional env: ALLOWED_ROM_HOSTS (comma-separated), defaults below.
 *
 * Keep webhook authentication and ROM URL validation: this bot is public
 * and can trigger GitHub Actions for any Telegram sender.
 */
const REPO = "ngocminhvn/HyperMOS";
const WORKFLOW = "build.yml";
const DEFAULT_HOSTS = [
  "sourceforge.net",
  "*.sourceforge.net",
  "drive.google.com",
  "bkt-sgp-miui-ota-update-alisgp.oss-ap-southeast-1.aliyuncs.com",
];

function allowedHost(host, pattern) {
  const h = host.toLowerCase();
  const p = pattern.trim().toLowerCase();
  if (!p) return false;
  if (p.startsWith("*.")) {
    const base = p.slice(2);
    return h.endsWith("." + base) && h !== base;
  }
  return h === p;
}

function validateRomUrl(raw, hostPatterns) {
  if (typeof raw !== "string" || raw.length < 12 || raw.length > 2048) return null;
  if (/[\s\u0000-\u001f]/u.test(raw)) return null;
  let parsed;
  try {
    parsed = new URL(raw);
  } catch {
    return null;
  }
  if (parsed.protocol !== "https:" || parsed.username || parsed.password) return null;
  const hostname = parsed.hostname.toLowerCase();
  if (!hostPatterns.some((pattern) => allowedHost(hostname, pattern))) return null;
  if (parsed.port && parsed.port !== "443") return null;
  return parsed.toString();
}


// A domain-separated SHA-256 digest is a Telegram-compatible 64-character
// webhook header secret. It avoids storing a separate Cloudflare secret.
// Keep the bot token itself secret: anyone holding it controls the Telegram bot.
async function telegramWebhookSecret(botToken) {
  const encoded = new TextEncoder().encode("hypermos-telegram-webhook-v1:" + botToken);
  const digest = await crypto.subtle.digest("SHA-256", encoded);
  return Array.from(new Uint8Array(digest), (byte) =>
    byte.toString(16).padStart(2, "0")
  ).join("");
}

function setupForm() {
  return new Response(`<!doctype html>
<html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>HyperMOS Telegram webhook</title></head>
<body style="max-width:540px;margin:50px auto;padding:20px;font:16px system-ui,sans-serif">
<h2>HyperMOS - Kích hoạt Telegram webhook</h2>
<p>Dán token của Minh BOT từ BotFather. Token được gửi bằng HTTPS tới chính Worker HyperMOS để kiểm tra và đăng ký webhook. Không ghi token vào URL.</p>
<form method="post" action="/setup-webhook">
<label for="bot_token">Telegram Bot Token</label><br>
<input id="bot_token" type="password" name="bot_token" autocomplete="off" required style="width:100%;padding:10px;box-sizing:border-box;margin:10px 0">
<button type="submit" style="padding:10px 16px">Kích hoạt webhook</button>
</form>
<p><small>Việc kích hoạt sẽ xóa các cập nhật Telegram cũ đang chờ để tránh kích hoạt build trùng.</small></p>
</body></html>`, {
    headers: {
      "Content-Type": "text/html; charset=utf-8",
      "Cache-Control": "no-store",
      "X-Robots-Tag": "noindex",
      "Content-Security-Policy": "default-src 'none'; style-src 'unsafe-inline'; form-action 'self'; base-uri 'none'; frame-ancestors 'none'",
    },
  });
}

async function setupWebhook(request, env) {
  if (!env.TELEGRAM_BOT_TOKEN) {
    return new Response("TELEGRAM_BOT_TOKEN is not configured", { status: 503 });
  }
  if (request.method === "GET") return setupForm();
  if (request.method !== "POST") return new Response("Method not allowed", { status: 405 });
  if (Number(request.headers.get("content-length") || "0") > 4096) {
    return new Response("Request too large", { status: 413 });
  }

  let candidate;
  try {
    const form = await request.formData();
    candidate = form.get("bot_token");
  } catch {
    return new Response("Invalid form", { status: 400 });
  }
  if (typeof candidate !== "string" || candidate.trim() !== env.TELEGRAM_BOT_TOKEN) {
    return new Response("Sai Telegram Bot Token", { status: 403 });
  }

  const webhookUrl = new URL("/telegram", request.url).toString();
  const response = await fetch("https://api.telegram.org/bot" + env.TELEGRAM_BOT_TOKEN + "/setWebhook", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      url: webhookUrl,
      secret_token: await telegramWebhookSecret(env.TELEGRAM_BOT_TOKEN),
      drop_pending_updates: true,
    }),
  });
  let result;
  try {
    result = await response.json();
  } catch {
    return new Response("Telegram API did not return JSON", { status: 502 });
  }
  if (!response.ok || result.ok !== true || result.result !== true) {
    return new Response("Telegram webhook setup failed (HTTP " + response.status + ")", { status: 502 });
  }
  return new Response("Da kich hoat webhook: " + webhookUrl + "\\nBay gio gui /b https://ROM-URL trong Telegram.", {
    headers: { "Content-Type": "text/plain; charset=utf-8", "Cache-Control": "no-store" },
  });
}

async function say(env, chatId, text) {
  await fetch("https://api.telegram.org/bot" + env.TELEGRAM_BOT_TOKEN + "/sendMessage", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      chat_id: chatId,
      text,
      disable_web_page_preview: true,
    }),
  });
}

export default {
  async fetch(request, env) {
    const route = new URL(request.url);
    if (route.pathname === "/setup-webhook") {
      return setupWebhook(request, env);
    }
    if (route.pathname !== "/telegram" || request.method !== "POST") {
      return new Response("Not found", { status: 404 });
    }
    if (!env.TELEGRAM_BOT_TOKEN || !env.GITHUB_WORKFLOW_TOKEN) {
      return new Response("Worker secrets not configured", { status: 503 });
    }
    const expectedSecret = await telegramWebhookSecret(env.TELEGRAM_BOT_TOKEN);
    if (request.headers.get("X-Telegram-Bot-Api-Secret-Token") !== expectedSecret) {
      return new Response("Forbidden", { status: 403 });
    }
    let update;
    try {
      update = await request.json();
    } catch {
      return new Response("Bad JSON", { status: 400 });
    }
    const msg = update?.message;
    const fromId = String(msg?.from?.id ?? "");
    const chatId = msg?.chat?.id;
    if (!fromId || !chatId || typeof msg.text !== "string") {
      return new Response("ok", { status: 200 });
    }
    const text = msg.text.trim();
    const match = /^\/b(?:@[A-Za-z0-9_]+)?\s+(https:\/\/\S+)$/iu.exec(text);
    if (!text.startsWith("/b")) {
      return new Response("ok", { status: 200 });
    }
    if (!match) {
      await say(env, chatId, "Cú pháp: /b https://link-ROM.zip");
      return new Response("ok", { status: 200 });
    }
    const hosts = String(env.ALLOWED_ROM_HOSTS || "").split(",")
      .map((s) => s.trim()).filter(Boolean);
    const romUrl = validateRomUrl(match[1], hosts.length ? hosts : DEFAULT_HOSTS);
    if (!romUrl) {
      await say(env, chatId, "Link ROM phải dùng HTTPS và thuộc nguồn ROM đã cho phép.");
      return new Response("ok", { status: 200 });
    }
    // Public command: configure abuse protection before sharing the bot widely.
    const response = await fetch(
      "https://api.github.com/repos/" + REPO + "/actions/workflows/" + WORKFLOW + "/dispatches",
      {
        method: "POST",
        headers: {
          "Authorization": "Bearer " + env.GITHUB_WORKFLOW_TOKEN,
          "Accept": "application/vnd.github+json",
          "X-GitHub-Api-Version": "2022-11-28",
          "User-Agent": "HyperMOS-Telegram-Build-Bot",
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          ref: "main",
          inputs: {
            input_url: romUrl,
            builder_id: fromId,
            root_mode: "root",
            upload_method: "drive",
            debug: "false",
          },
        }),
      }
    );
    if (response.status === 204) {
      await say(env, chatId, "Đã gửi yêu cầu build vào GitHub Actions (root mode). Xem: https://github.com/" + REPO + "/actions/workflows/" + WORKFLOW);
    } else {
      await say(env, chatId, "Không thể tạo build: GitHub API trả về HTTP " + response.status + ". Kiểm tra quyền Actions: write của token.");
    }
    return new Response("ok", { status: 200 });
  },
};
