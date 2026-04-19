function SendDiscordLog(data)
	local content = {{
		["author"] = {
			["name"] = WEBHOOK.DiscordLog.AuthorName,
			["icon_url"] = WEBHOOK.DiscordLog.AuthorIcon,
		},
		["title"] = WEBHOOK.DiscordLog.Title,
		["color"] = WEBHOOK.DiscordLog.BotColor,
		["footer"] = {
			["text"] = WEBHOOK.DiscordLog.FooterText,
			["icon_url"] = WEBHOOK.DiscordLog.FooterIcon
		},
		["thumbnail"] = {
			["url"] = WEBHOOK.DiscordLog.ThumbnailIcon
		},
		["fields"] = {
			{name = WEBHOOK.Translations.Door, value = data.Door, inline = false},
			{name = WEBHOOK.Translations.Reward, value = data.Reward},
			{name = WEBHOOK.Translations.Character, value = data.Character, inline = false},
			{name = WEBHOOK.Translations.Name, value = data.Name, inline = false},
			{name = WEBHOOK.Translations.Identifier, value = data.Identifier, inline = false},
		},
	}}
	PerformHttpRequest(WEBHOOK.DiscordLog.Webhook.Webhook, function() end, 'POST', json.encode({
		username = WEBHOOK.DiscordLog.BotName,
		embeds = content,
		avatar_url = WEBHOOK.DiscordLog.BotAvatar
	}), {
		['Content-Type'] = 'application/json'
	})
end