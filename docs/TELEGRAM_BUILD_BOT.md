# HyperMOS Telegram build command: /b <rom-zip-URL>

## How it works

The Cloudflare Worker in `bot/telegram_build_worker.js` receives Telegram webhooks
and dispatches `.github/workflows/build.yml` on `main` in root mode. Existing
`notify.py` handles build progress and final results.

The Worker verifies Telegram's webhook authentication header and the ROM URL
host allowlist. There is **no Telegram user-ID allowlist**: anyone who can
message the bot may request a build. Introduce rate limiting and deduplication
before sharing the bot publicly.

## Deploy using Cloudflare dashboard (no local tools needed)

- Create/connect a Cloudflare Worker to GitHub repository `ngocminhvn/HyperMOS`.
- Worker name: `hypermos`; production branch: `main`.
- Root directory: `bot`; leave Build command empty.
- Deploy command: `npx wrangler deploy`.
- Confirm the new deployment reports **Ready**.

## Exactly two Cloudflare Worker secrets

Configure these under Worker > Settings > Variables and Secrets:

- `TELEGRAM_BOT_TOKEN`: existing bot token from Telegram BotFather.
- `GITHUB_WORKFLOW_TOKEN`: GitHub fine-grained personal access token scoped
  to `ngocminhvn/HyperMOS`, with Actions: Read and write.

`TELEGRAM_WEBHOOK_SECRET` is **no longer needed**. The Worker securely derives
a 64-character hexadecimal Telegram webhook secret from
`TELEGRAM_BOT_TOKEN` using a domain-separated SHA-256 hash. It never exposes
the raw token or derived secret in a URL. `ALLOWED_TELEGRAM_USER_IDS` is also
unused and may be removed from Cloudflare settings.

## Register the Telegram webhook from your browser

1. Once the Cloudflare deployment is **Ready**, visit
   `https://hypermos.minhtn3092007.workers.dev/setup-webhook`.
2. Enter the **existing Telegram BotFather token** and click
   **Kích hoạt webhook**. This posts the token over HTTPS to your own Worker,
   not to a third-party website.
3. The Worker checks that the token matches the Cloudflare secret, calculates
   the allowed Telegram webhook secret automatically, and calls Telegram's
   `setWebhook` API for `/telegram`.
4. The setup deliberately sets `drop_pending_updates: true` to discard old
   queued commands and avoid duplicate builds.
5. In a private message to the bot, send
   `/b https://sourceforge.net/projects/.../files/.../rom.zip/download`.

The setup page requires the exact bot token, which acts as the credential.
Avoid sharing that token or screenshots of it. Do not include the token in a
URL or paste it into a third-party hash website. If the bot token is rotated
in BotFather, update the Cloudflare secret and run the setup page again.

A successful webhook setup does not guarantee that a ROM build succeeds. The
bot confirms when GitHub accepts the workflow dispatch, and `notify.py`
reports its final result.

## Security considerations

Two secrets are sufficient because the webhook header token is derived from
the bot token. Forged HTTP requests lacking the correct header get 403.
Allow only trusted ROM download hosts; `ALLOWED_ROM_HOSTS` is an optional
comma-separated variable to narrow the default list. A public `/b` command
can consume GitHub Actions minutes and storage; add Cloudflare rate limits
and duplicate-command protection before publishing the bot widely.
