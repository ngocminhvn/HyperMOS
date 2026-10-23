/**
 * HyperMOS Telegram /b <rom-url> webhook receiver.
 * Deploy as a Cloudflare Worker; it does NOT run in GitHub Actions.
 *
 * Required Worker secrets: TELEGRAM_BOT_TOKEN, TELEGRAM_WEBHOOK_SECRET,
 * GITHUB_WORKFLOW_TOKEN. Required env: ALLOWED_TELEGRAM_USER_IDS.
 * Optional env: ALLOWED_ROM_HOSTS (comma-separated), defaults below.
 *
 * Keep authentication and the ROM download URL validation: this endpoint
 * triggers build scripts with elevated privileges on GitHub-hosted runners.
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
    if (route.pathname !== "/telegram" || request.method !== "POST") {
      return new Response("Not found", { status: 404 });
    }
    if (!env.TELEGRAM_WEBHOOK_SECRET ||
        request.headers.get("X-Telegram-Bot-Api-Secret-Token") !== env.TELEGRAM_WEBHOOK_SECRET) {
      return new Response("Forbidden", { status: 403 });
    }
    if (!env.TELEGRAM_BOT_TOKEN || !env.GITHUB_WORKFLOW_TOKEN) {
      return new Response("Worker secrets not configured", { status: 503 });
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
    // No bot commands are accepted from unauthorised Telegram accounts.
    const users = String(env.ALLOWED_TELEGRAM_USER_IDS || "").split(",").map((s) => s.trim());
    if (!users.includes(fromId)) {
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
    // Concurrency/rate limits and approval can be imposed in the Worker config.
    // Do not insert a public build endpoint without checking from.id.
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
