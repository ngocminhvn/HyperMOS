# HyperMOS Telegram workflow commands

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

## Telegram commands and suggestions

Telegram's slash-command suggestion menu includes only `start`. The other
commands remain available when typed manually. Webhook setup also registers this menu with `setMyCommands`.
Use `/help` or `/start` for syntax and examples.

- `/b <URL>`: dispatch build.yml on main, root mode, Drive upload.
- `/dump <URL> [base|full] [artifact|drive]`: dispatch dump.yml on main.
  Defaults: base and artifact. Example: `/dump <URL> full drive`.
- `/fastbootd <URL> [partitions]`: dispatch build-fastbootd.yml on main.
  Defaults: system,system_ext,product,mi_ext.
  Partitions are comma-separated with no spaces; valid names are system,
  system_ext,product,mi_ext,vendor,odm.
  Example: `/fastbootd <URL> system,system_ext`.

The same HTTPS source-host validation applies to all three commands. Invalid
arguments display help without dispatching a workflow. Commands addressed to
the bot, such as `/dump@trinhngocminh_bot`, are supported. Confirmation means
GitHub accepted the request; follow the workflow link for results. FastbootD
results are GitHub Actions artifacts. The workflow sends progress and final
notifications to the repo channel and requester.

## Interactive buttons

Send `/start` (or `/menu`) to open Build ROM, Dump and FastbootD buttons.
Select a task, send a trusted HTTPS ROM URL, choose options and press **Chạy**.
Dump has Base/Full and Artifact/Drive buttons. FastbootD has individual
partition toggles; at least one partition is required. **Hủy** cancels.
Opening /start cancels your current selection.

Selections are isolated by chat and Telegram user, persist in the
BOT_SESSIONS SQLite Durable Object, and expire after 5 minutes.
Old revision buttons and repeated confirmations are rejected. A confirmation
is consumed before GitHub dispatch; uncertain network outcomes require checking
Actions manually before creating another request. Existing slash commands
still dispatch immediately.

The webhook must include message and callback_query in allowed_updates.
The deployed webhook enables both without dropping queued updates.
The session binding and bot-ui-v1 class migration are defined in
bot/wrangler.toml.

## Repo and requester notifications

All bot commands pass the Telegram sender ID as builder_id. Notifications
continue to reach TELEGRAM_CHANNEL_ID (the configured repo owner/channel),
and also reach the requesting Telegram user in a private message.

- Standard build: notify.py mirrors progress and final results, with separate
  progress message IDs for the channel and builder. Failure logs remain private
  to the builder.
- FastbootD: bot/notify_workflow.py sends start, packaging, upload and final
  status, with the exact run link and artifact link on success.
- Dump: the existing final result (including Drive/artifact link) is delivered
  to both recipients.

Recipients are deduplicated when the owner/channel ID equals builder_id.
Delivery failures are isolated so one recipient cannot block the other.
The requester must have started the bot privately and must not block it.
GitHub's TELEGRAM_BOT_TOKEN secret must belong to the bot they started.
Workflow changes apply to new runs, not jobs already running an older commit.

Interactive selection messages are cleaned up after Run, Cancel or five-minute
expiry. The ROM prompt is edited into the options panel. The supplied ROM URL
message is deleted when the selection ends; Success + Info is preserved across
later menus. A Durable Object alarm cleans expired selections automatically.
Telegram deletion permission errors do not block dispatch.

## Workflow options in the bot

After sending /start or pressing the persistent 🏠 Menu keyboard button,
choose a task and provide a ROM URL. Build ROM and FastbootD also offer the
current workflow's default ROM URL as a button.

- Build ROM: Root/Stock, Drive/Pixeldrain, Debug on/off.
- Dump: Base/Full, Artifact/Drive, optional 32-hex-character MD5 (editable/clearable).
- FastbootD: independently select system, system_ext, product, mi_ext, vendor, odm.

Use Change ROM URL to replace the source before confirming. builder_id is
always the actual Telegram sender; no manual override is exposed.
