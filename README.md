# Roblox-Discord Staff Management Bot

[github.com/l7rk/groupmanagement](https://github.com/l7rk/groupmanagement)

A full staff-management system for Roblox roleplay groups — moderation, LOA, strikes,
weekly requirements, and live Roblox rank sync, all through Discord slash commands.

## Requirements

- Node.js 18 or newer
- A Discord bot application ([discord.com/developers/applications](https://discord.com/developers/applications))
- A Roblox account with rank-management permissions in your group (only needed if you want
  `/promote`, `/demote`, and `/setrank` to actually change ranks)

## 1. Install

```bash
git clone https://github.com/l7rk/groupmanagement.git
cd groupmanagement
npm install
cp .env.example .env
```

## 2. Discord bot setup

1. Create an application at the Discord Developer Portal, then add a Bot user.
2. Under **Bot**, enable these Privileged Gateway Intents: **Server Members Intent** and
   **Message Content Intent**.
3. Copy the bot token into `DISCORD_TOKEN` in `.env`, and the Application ID into
   `DISCORD_CLIENT_ID`.
4. Invite the bot to your server with the `applications.commands` and `bot` scopes, and at
   minimum these permissions: Manage Roles, Kick Members, Ban Members, Moderate Members,
   Manage Messages, Manage Threads, Send Messages, Read Message History, Add Reactions.

## 3. Roblox setup (optional but recommended)

To let the bot actually change ranks on your Roblox group:

1. Log in to a Roblox account that has permission to manage ranks in your group.
2. Get that account's `.ROBLOSECURITY` cookie (browser dev tools → Application → Cookies)
   and put it in `ROBLOX_COOKIE` in `.env`. **Treat this like a password — never commit it,
   never share it.**
3. Put your group's numeric ID in `ROBLOX_GROUP_ID` in `.env` (visible in your group's URL).

If you skip this, the bot still runs — `/promote`, `/demote`, and `/setrank` will just fail
until it's configured, and everything else works normally.

## 4. In-game activity reporting (optional)

Playtime, chat activity, AFK detection, and purchase logging are all driven by your Roblox
game server reporting to the bot's built-in HTTP endpoint, not by the bot polling Roblox.
Ready-made scripts for this are included in [`/roblox`](./roblox) — see
[`roblox/README.md`](./roblox/README.md) for the Studio install steps. They call these
endpoints:

- `POST /report/heartbeat` — body: `{ guildId, robloxUserId, minutes, chatMessages }`
- `POST /report/afk` — body: `{ guildId, robloxUserId, afk: true|false }`
- `POST /report/purchase` — body: `{ guildId, robloxUserId, robloxUsername, itemName, itemType, robuxAmount }`

Every request needs an `X-Activity-Secret` header matching `ACTIVITY_SERVER_SECRET` in `.env`.
This server needs to be reachable from Roblox's servers — if you're running the bot on a home
machine, you'll need to port-forward or tunnel (e.g. with a reverse proxy) `ACTIVITY_SERVER_PORT`.

If you don't wire this up, `/playerstats`, `/staffleaderboard`, and `/requirementslist` will
just show zero activity — nothing else breaks.

## 5. Deploy slash commands

```bash
npm run deploy               # registers commands globally (takes up to 1 hour to show up)
npm run deploy -- <guildId>  # registers commands instantly to one server, good for testing
```

## 6. Run the bot

```bash
npm start
```

## 7. Configure your server

Once the bot is running and commands are registered, an Owner (server Administrator, or
whoever you set as the owner role/user in `.env`) should run:

```
/config roles staff:@Staff staffmanager:@StaffManager moderator:@Moderator
/config channels modlog:#mod-log auditlog:#audit-log sessions:#sessions loaapproval:#loa-requests
/config roblox groupid:1234567
/config requirements minutes:60
```

Run `/config view` any time to see current settings. Everything else has sane defaults —
see `src/db/database.js` for the full list of configurable fields.

Members should run `/linkroblox <username>` to connect their Discord account to their Roblox
account — this is what `/playerstats`, `/promote`, `/demote`, and `/setrank` use when you
target a Discord member instead of typing a Roblox username directly.

## Permission tiers

**Everyone → Staff → Staff Manager → Moderator**, each tier inherits everything below it. A
hidden Owner tier (Administrator permission, or the role/user IDs set via `/config` or
`OWNER_ROLE_ID`/`OWNER_USER_IDS` in `.env`) sits above all of them and is the only tier that
can run `/config`.

## Notes

- Data is stored locally in `data/bot.sqlite` (SQLite via better-sqlite3) — back this file up
  if you care about strike/warning/LOA history.
- This project has no external database or hosting dependency — it runs anywhere Node.js runs.
