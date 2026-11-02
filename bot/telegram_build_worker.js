import { DurableObject } from "cloudflare:workers";
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

const COMMANDS = [
 {command:"b",description:"Build ROM root: /b <URL>"},
 {command:"dump",description:"Dump ROM: /dump <URL> [base|full] [artifact|drive]"},
 {command:"fastbootd",description:"Build ảnh FastbootD: /fastbootd <URL> [phân_vùng]"},
 {command:"help",description:"Hướng dẫn và ví dụ các lệnh"},
 {command:"start",description:"Mở menu nút bấm"}
];
const HELP = [
 "HyperMOS — các lệnh:",
 "/b <URL> — build ROM root, tải lên Drive.",
 "/dump <URL> [base|full] [artifact|drive] — mặc định base, artifact.",
 "/fastbootd <URL> [phân_vùng] — mặc định system,system_ext,product,mi_ext.",
 "Phân vùng hợp lệ: system,system_ext,product,mi_ext,vendor,odm; ngăn cách bằng dấu phẩy.",
 "Ví dụ: /dump https://sourceforge.net/.../rom.zip/download full drive",
 "Ví dụ: /fastbootd https://sourceforge.net/.../rom.zip/download system,system_ext",
 "URL phải dùng HTTPS và thuộc nguồn được cho phép.",
 "Kết quả: https://github.com/" + REPO + "/actions",
 "/help — xem lại hướng dẫn."
].join("\n");

async function registerCommands(env) {
 const response = await fetch("https://api.telegram.org/bot" + env.TELEGRAM_BOT_TOKEN + "/setMyCommands", {
  method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({commands:COMMANDS})
 });
 const result = await response.json();
 if(!response.ok || result.ok !== true) throw new Error("Telegram command registration failed");
}

function parseBuildCommand(text, fromId, hosts) {
 const match = /^\/([a-z]+)(?:@[A-Za-z0-9_]+)?(?:\s+([\s\S]*))?$/iu.exec(text);
 if (!match) return {error: HELP};
 const command = match[1].toLowerCase();
 if (["start","help"].includes(command)) return {help:true};
 if (!["b","dump","fastbootd"].includes(command)) return {error:HELP};
 const args = (match[2] || "").trim().split(/\s+/u).filter(Boolean);
 const romUrl = validateRomUrl(args[0], hosts);
 if (!romUrl) return {error:"Link ROM phải dùng HTTPS và thuộc nguồn ROM đã cho phép.\n\n" + HELP};
 if(command === "b") {
  if(args.length !== 1) return {error:"Cú pháp: /b <URL>"};
  return {workflow:"build.yml",label:"build ROM (root mode)",inputs:{input_url:romUrl,builder_id:fromId,root_mode:"root",upload_method:"drive",debug:"false"}};
 }
 if(command === "dump") {
  const mode = args[1] || "base", upload = args[2] || "artifact";
  if(args.length > 3 || !["base","full"].includes(mode) || !["artifact","drive"].includes(upload))
   return {error:"Cú pháp: /dump <URL> [base|full] [artifact|drive]"};
  return {workflow:"dump.yml",label:"Dump ("+mode+", "+upload+")",inputs:{rom_url:romUrl,dump_mode:mode,upload_method:upload}};
 }
 const all = ["system","system_ext","product","mi_ext","vendor","odm"];
 const selected = (args[1] || "system,system_ext,product,mi_ext").split(",");
 if(args.length > 2 || selected.some(p=>!all.includes(p)) || new Set(selected).size !== selected.length)
  return {error:"Cú pháp: /fastbootd <URL> [system,system_ext,product,mi_ext,vendor,odm]\nChỉ liệt kê phân vùng muốn xuất, ngăn cách bằng dấu phẩy."};
 const inputs = {input_url:romUrl,builder_id:fromId};
 for(const p of all) inputs["export_"+p] = selected.includes(p) ? "true" : "false";
 return {workflow:"build-fastbootd.yml",label:"FastbootD ("+selected.join(", ")+")",inputs};
}

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
  await registerCommands(env);
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
    const msg = update.callback_query?.message || update.message;
    const user = update.callback_query?.from || msg?.from;
    if(!msg?.chat?.id || !user?.id || !Number.isSafeInteger(update.update_id)) return new Response("ok");
    await env.BOT_SESSIONS.getByName(msg.chat.id+":"+user.id).handle(update);
    return new Response("ok");
  },
};


const PARTITIONS = ["system","system_ext","product","mi_ext","vendor","odm"];
function romHosts(env) {
 const hosts = String(env.ALLOWED_ROM_HOSTS || "").split(",").map(s=>s.trim()).filter(Boolean);
 return hosts.length ? hosts : DEFAULT_HOSTS;
}
async function telegram(env, method, payload) {
 const r = await fetch("https://api.telegram.org/bot"+env.TELEGRAM_BOT_TOKEN+"/"+method,{
  method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify(payload),signal:AbortSignal.timeout(12000)
 });
 const data=await r.json();
 if(!r.ok || !data.ok) throw new Error("Telegram "+method+" failed: "+r.status);
 return data.result;
}
function homeKeyboard(user) {
 const button=(text,action)=>({text,callback_data:"ui:"+user+":home:"+action});
 return {inline_keyboard:[[button("🔨 Build ROM","b"),button("📦 Dump","dump")],[button("⚡ FastbootD","fastbootd")],[button("❓ Hướng dẫn","help")]]};
}
async function home(env,chat,user,text="HyperMOS — chọn tác vụ bên dưới:") {
 return telegram(env,"sendMessage",{chat_id:chat,text,reply_markup:homeKeyboard(user)});
}
function sessionView(s,user) {
 const btn=(text,action)=>({text,callback_data:["ui",user,s.id,s.rev,action].join(":")});
 const rows=[];
 let text="HyperMOS — "+({b:"🔨 Build ROM",dump:"📦 Dump",fastbootd:"⚡ FastbootD"}[s.kind]);
 if(!s.url) text+="\nGửi link ROM HTTPS vào cuộc trò chuyện này.\nPhiên chọn hết hạn sau 30 phút.";
 else {
  text+="\nROM: "+s.url;
  if(s.kind==="b") text+="\nRoot mode • tải lên Drive";
  if(s.kind==="dump") {
   text+="\nChế độ: "+s.mode+" • lưu: "+s.upload;
   rows.push([btn((s.mode==="base"?"✅ ":"")+"Base","base"),btn((s.mode==="full"?"✅ ":"")+"Full","full")]);
   rows.push([btn((s.upload==="artifact"?"✅ ":"")+"Artifact","artifact"),btn((s.upload==="drive"?"✅ ":"")+"Drive","drive")]);
  }
  if(s.kind==="fastbootd") {
   text+="\nChọn phân vùng cần xuất:";
   for(let i=0;i<PARTITIONS.length;i+=2) rows.push(PARTITIONS.slice(i,i+2).map(p=>btn((s.parts.includes(p)?"✅ ":"⬜ ")+p,p)));
  }
  text+="\nKiểm tra cấu hình rồi bấm Chạy.";
  rows.push([btn("🚀 Chạy","run")]);
 }
 rows.push([btn("✖ Hủy","cancel")]);
 return {text,reply_markup:{inline_keyboard:rows}};
}
async function dispatchTask(env,chat,task) {
 let response;
 try {
  response=await fetch("https://api.github.com/repos/"+REPO+"/actions/workflows/"+task.workflow+"/dispatches",{
   method:"POST",headers:{"Authorization":"Bearer "+env.GITHUB_WORKFLOW_TOKEN,"Accept":"application/vnd.github+json","X-GitHub-Api-Version":"2022-11-28","User-Agent":"HyperMOS-Telegram-Build-Bot","Content-Type":"application/json"},
   body:JSON.stringify({ref:"main",inputs:task.inputs}),signal:AbortSignal.timeout(15000)
  });
 } catch {
  await say(env,chat,"Chưa xác định GitHub đã nhận yêu cầu hay chưa. Kiểm tra Actions trước khi tạo lại để tránh chạy trùng: https://github.com/"+REPO+"/actions");
  return;
 }
 await say(env,chat,response.status===204
  ? "Đã gửi yêu cầu "+task.label+" vào GitHub Actions. Xem: https://github.com/"+REPO+"/actions/workflows/"+task.workflow
  : "GitHub từ chối yêu cầu (HTTP "+response.status+"). Kiểm tra token và workflow rồi mở /start để thử lại.");
}
export class BotSession extends DurableObject {
 constructor(ctx,env) {
  super(ctx,env);
  ctx.storage.sql.exec("CREATE TABLE IF NOT EXISTS session (id INTEGER PRIMARY KEY, data TEXT)");
  ctx.storage.sql.exec("CREATE TABLE IF NOT EXISTS seen (id INTEGER PRIMARY KEY)");
 }
 read() {
  const row=this.ctx.storage.sql.exec("SELECT data FROM session WHERE id=1").toArray()[0];
  return row ? JSON.parse(row.data) : null;
 }
 save(s) { this.ctx.storage.sql.exec("INSERT OR REPLACE INTO session VALUES (1,?)",JSON.stringify(s)); }
 async handle(update) {
  const q=update.callback_query, msg=q?.message || update.message;
  const chat=msg?.chat?.id, user=String((q?.from || msg?.from)?.id || "");
  if(!chat || !user) return;
  if(this.ctx.storage.sql.exec("SELECT id FROM seen WHERE id=?",update.update_id).toArray().length) {
   if(q) await telegram(this.env,"answerCallbackQuery",{callback_query_id:q.id,text:"Yêu cầu này đã được xử lý."});
   return;
  }
  // Synchronous writes consume each update and confirmation before external I/O.
  this.ctx.storage.sql.exec("INSERT INTO seen VALUES (?)",update.update_id);
  this.ctx.storage.sql.exec("DELETE FROM seen WHERE id NOT IN (SELECT id FROM seen ORDER BY id DESC LIMIT 200)");
  if(q) {
   const data=String(q.data||"").split(":");
   if(data[0]!=="ui" || data[1]!==user) {
    await telegram(this.env,"answerCallbackQuery",{callback_query_id:q.id,text:"Menu này thuộc người khác. Gửi /start để mở menu riêng."}); return;
   }
   let s=this.read(), action;
   if(data[2]==="home") {
    action=data[3];
    if(action==="help") {
     await telegram(this.env,"answerCallbackQuery",{callback_query_id:q.id});
     await home(this.env,chat,user,HELP); return;
    }
    if(!["b","dump","fastbootd"].includes(action)) return;
    s={id:crypto.randomUUID().slice(0,8),rev:0,kind:action,url:null,mode:"base",upload:"artifact",parts:PARTITIONS.slice(0,4),expires:Date.now()+1800000,status:"editing"};
    this.save(s);
    await telegram(this.env,"answerCallbackQuery",{callback_query_id:q.id});
    await telegram(this.env,"sendMessage",{chat_id:chat,...sessionView(s,user)}); return;
   }
   action=data[4];
   if(!s || s.id!==data[2] || String(s.rev)!==data[3] || s.expires<Date.now() || s.status!=="editing") {
    await telegram(this.env,"answerCallbackQuery",{callback_query_id:q.id,text:"Nút đã cũ hoặc phiên đã kết thúc. Dùng menu mới nhất hoặc /start."}); return;
   }
   if(action==="cancel") {
    s.status="cancelled";s.rev++;this.save(s);
    await telegram(this.env,"answerCallbackQuery",{callback_query_id:q.id,text:"Đã hủy."});
    await telegram(this.env,"editMessageText",{chat_id:chat,message_id:msg.message_id,text:"Đã hủy tác vụ.",reply_markup:{inline_keyboard:[]}});
    await home(this.env,chat,user);return;
   }
   if(action==="run") {
    if(!s.url || (s.kind==="fastbootd"&&!s.parts.length)) {
     await telegram(this.env,"answerCallbackQuery",{callback_query_id:q.id,text:"Hãy gửi link ROM và chọn ít nhất một phân vùng."});return;
    }
    const command="/"+s.kind+" "+s.url+(s.kind==="dump"?" "+s.mode+" "+s.upload:s.kind==="fastbootd"?" "+s.parts.join(","):"");
    const task=parseBuildCommand(command,user,romHosts(this.env));
    if(task.error) {
     await telegram(this.env,"answerCallbackQuery",{callback_query_id:q.id,text:"Cấu hình không hợp lệ. Mở /start để tạo lại."});return;
    }
    s.status="submitted";s.rev++;this.save(s);
    await telegram(this.env,"answerCallbackQuery",{callback_query_id:q.id,text:"Đang gửi yêu cầu…"});
    // Confirmation is consumed even if the network result is uncertain.
    await dispatchTask(this.env,chat,task);
    await telegram(this.env,"editMessageText",{chat_id:chat,message_id:msg.message_id,text:"Đã xử lý xác nhận. Xem thông báo kết quả gửi yêu cầu bên dưới.",reply_markup:{inline_keyboard:[]}});
    return;
   }
   if(s.kind==="dump"&&["base","full"].includes(action)) s.mode=action;
   else if(s.kind==="dump"&&["artifact","drive"].includes(action)) s.upload=action;
   else if(s.kind==="fastbootd"&&PARTITIONS.includes(action)) s.parts=s.parts.includes(action)?s.parts.filter(p=>p!==action):[...s.parts,action];
   else return;
   s.rev++;this.save(s);
   await telegram(this.env,"answerCallbackQuery",{callback_query_id:q.id});
   await telegram(this.env,"editMessageText",{chat_id:chat,message_id:msg.message_id,...sessionView(s,user)});return;
  }
  const text=msg.text?.trim();
  if(!text) return;
  if(/^\/(start|menu)(?:@[A-Za-z0-9_]+)?$/iu.test(text)) {
   const s=this.read();if(s){s.status="cancelled";this.save(s);}
   await home(this.env,chat,user);return;
  }
  if(/^\/help(?:@[A-Za-z0-9_]+)?$/iu.test(text)) {await home(this.env,chat,user,HELP);return;}
  if(text.startsWith("/")) {
   const task=parseBuildCommand(text,user,romHosts(this.env));
   if(task.error || task.help) {await home(this.env,chat,user,task.error||HELP);return;}
   await dispatchTask(this.env,chat,task);return;
  }
  const s=this.read();
  if(!s || s.status!=="editing" || s.expires<Date.now()) {await home(this.env,chat,user,"Chọn tác vụ trước khi gửi link ROM:");return;}
  const url=validateRomUrl(text,romHosts(this.env));
  if(!url) {await say(this.env,chat,"Link không hợp lệ. Gửi URL HTTPS thuộc nguồn ROM đã cho phép.");return;}
  s.url=url;s.rev++;this.save(s);
  await telegram(this.env,"sendMessage",{chat_id:chat,...sessionView(s,user)});
 }
}
