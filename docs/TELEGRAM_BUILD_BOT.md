# HyperMOS Telegram build command: /b <rom-zip-URL>

## Why a new receiver is needed

notify.py currently sends progress/results *out* of GitHub Actions; it never
receives Telegram updates. A GitHub Actions workflow cannot by itself serve
Telegram webhooks between workflow runs.

bot/telegram_build_worker.js is a minimal Cloudflare Worker HTTPS webhook that:
- verifies Telegram's secret header;
- accepts valid /b commands without Telegram user-ID filtering;
- parses exactly "/b https://ROM-LINK";
- validates HTTPS URLs against a configurable download-host allowlist;
- dispatches the existing .github/workflows/build.yml on main, root mode;
- supplies builder_id=<Telegram sender ID> so notify.py can send completion
  messages and redacted failure logs directly to the builder.

No bot daemon, always-on computer, private ROM server or new GitHub workflow is
required. However, the HTTPS receiver must be deployed before /b can work.

## One-time setup (Cloudflare Worker, GitHub, Telegram)

1. Install Wrangler from Cloudflare, enter the bot/ directory and deploy
   using "npx wrangler deploy". Save the Worker URL (https://<worker>.workers.dev).
2. Create a GitHub fine-grained personal token restricted to
   ngocminhvn/HyperMOS with Actions: Read and write permissions. Do not
   commit, print or share it.
3. From bot/, set these Cloudflare Worker secrets via Wrangler:
   - TELEGRAM_BOT_TOKEN: existing Telegram bot token, held only as a secret.
   - GITHUB_WORKFLOW_TOKEN: GitHub Actions token from step 2.
   - TELEGRAM_WEBHOOK_SECRET: a unique unpredictable value containing only
     A-Z, a-z, 0-9, underscore or hyphen.
   Optional: ALLOWED_ROM_HOSTS (comma-separated exact domains, or *.domain).
4. Telegram setWebhook (run locally, with your real values in environment
   variables rather than in source code):
   curl -fsS -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/setWebhook" \
     --data-urlencode "url=${WORKER_URL}/telegram" \
     --data-urlencode "secret_token=${TELEGRAM_WEBHOOK_SECRET}"
5. Open a DM with the bot and send /start once. Then send:

   /b https://sourceforge.net/projects/.../files/.../rom.zip/download

The Worker replies once GitHub accepts the dispatch; this is NOT proof that the
ROM build succeeded. The existing notify.py will report the final result.

## Security and limitations

Anyone able to message the Telegram bot can trigger builds. This is intentionally
public and can exhaust GitHub Actions quota or incur cost. Telegram secrets and
GitHub tokens stay in Worker secrets, not in the repo or ROM output. Keep the
ROM download-host allowlist strict; add rate limiting and deduplication before
sharing the bot widely.

GitHub Actions workflow_dispatch returns an acknowledgement but usually no run
ID; the bot links to the build workflow page rather than inventing a run number.
The basic Worker does not contain durable rate limiting or deduplication. If
using it publicly, add Cloudflare KV/Durable Object deduplication and
rate limits. Root mode still fails closed on unsupported kernel/partition layouts.
