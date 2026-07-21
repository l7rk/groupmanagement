local ActivityConfig = {}

ActivityConfig.BOT_SERVER_URL = "http://YOUR-BOT-SERVER-ADDRESS:3000"
ActivityConfig.ACTIVITY_SECRET = "change-me-to-a-long-random-string"
ActivityConfig.GUILD_ID = "YOUR-DISCORD-SERVER-ID"

ActivityConfig.HEARTBEAT_INTERVAL_SECONDS = 60
ActivityConfig.AFK_CHECK_INTERVAL_SECONDS = 30
ActivityConfig.AFK_THRESHOLD_SECONDS = 1200

return ActivityConfig
