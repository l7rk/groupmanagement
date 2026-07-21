# Roblox-side scripts

These report playtime, chat activity, AFK status, and purchases from your game to the bot's
built-in activity server (`src/handlers/activityServer.js`). Nothing here grants ranks or
touches your group — that's all handled bot-side over the Roblox API.

## Install in Roblox Studio

1. Open your game in Studio.
2. In **ServerScriptService**, create:
   - A `ModuleScript` named `ActivityConfig`, paste in `ServerScriptService/ActivityConfig.lua`.
   - A `ModuleScript` named `ActivityReporter`, paste in `ServerScriptService/ActivityReporter.lua`.
   - A `Script` named `ActivityTracker`, paste in `ServerScriptService/ActivityTracker.server.lua`.
   - A `Script` named `AFKDetector`, paste in `ServerScriptService/AFKDetector.server.lua`.
   - A `Script` named `PurchaseLogger`, paste in `ServerScriptService/PurchaseLogger.server.lua`.
3. In **StarterPlayer → StarterPlayerScripts**, create a `LocalScript` named `AFKClient`,
   paste in `StarterPlayerScripts/AFKClient.client.lua`.
4. Open **Game Settings → Security** and turn on **Allow HTTP Requests**.
5. Edit `ActivityConfig` and fill in:
   - `BOT_SERVER_URL` — where your bot's activity server is reachable from the internet
     (e.g. `http://your-domain.com:3000` or a tunnel URL). It must be publicly reachable —
     Roblox's servers can't reach `localhost` or a machine behind NAT without port forwarding
     or a tunnel.
   - `ACTIVITY_SECRET` — must exactly match `ACTIVITY_SERVER_SECRET` in the bot's `.env`.
   - `GUILD_ID` — your Discord server ID.

That's it — `AFKDetector` creates its own `RemoteEvent` (`PlayerActivityPing`) under
`ReplicatedStorage` automatically the first time it runs, no manual setup needed there.

## What each script does

- **ActivityTracker** — every `HEARTBEAT_INTERVAL_SECONDS` (default 60s), reports each online
  player's playtime and chat message count since the last heartbeat. Backs `/playerstats`,
  `/staffleaderboard`, `/requirementslist`.
- **AFKDetector** + **AFKClient** — the client pings the server on any input or character
  movement (throttled to once per 10s). The server checks every `AFK_CHECK_INTERVAL_SECONDS`
  whether a player has gone quiet for longer than `AFK_THRESHOLD_SECONDS`, and only reports
  when a player's AFK state actually changes.
- **PurchaseLogger** — hooks `PromptGamePassPurchaseFinished` and
  `PromptProductPurchaseFinished` to log completed purchases with their real Robux price. This
  only *logs* purchases for `/purchase` mod-log messages — it doesn't grant anything, so it's
  safe to run alongside your existing `ProcessReceipt` callback if you already grant products
  that way.

## Notes

- `PromptProductPurchaseFinished` fires when the purchase prompt closes, which is fine for
  logging but isn't the guaranteed-delivery hook Roblox recommends for actually granting
  items — if you're not already using `ProcessReceipt` for that, keep doing so separately;
  this script is log-only.
- If `BOT_SERVER_URL` is unreachable, requests fail silently (a warning is printed in the
  server output) — gameplay is never blocked waiting on the bot.
