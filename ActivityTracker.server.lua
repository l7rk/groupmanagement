local MarketplaceService = game:GetService("MarketplaceService")

local ActivityReporter = require(script.Parent:WaitForChild("ActivityReporter"))

local GAMEPASS_PRICES = {}
local PRODUCT_PRICES = {}

local function getGamepassInfo(gamepassId)
	local success, info = pcall(function()
		return MarketplaceService:GetProductInfo(gamepassId, Enum.InfoType.GamePass)
	end)
	if success then
		return info
	end
	return nil
end

local function getProductInfo(productId)
	local success, info = pcall(function()
		return MarketplaceService:GetProductInfo(productId, Enum.InfoType.Product)
	end)
	if success then
		return info
	end
	return nil
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
	if not wasPurchased then
		return
	end

	local info = GAMEPASS_PRICES[gamePassId]
	if not info then
		info = getGamepassInfo(gamePassId)
		if info then
			GAMEPASS_PRICES[gamePassId] = info
		end
	end

	local itemName = info and info.Name or ("Gamepass " .. tostring(gamePassId))
	local price = info and info.PriceInRobux or 0

	ActivityReporter.Purchase(player.UserId, player.Name, itemName, "gamepass", price)
end)

MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, wasPurchased)
	if not wasPurchased then
		return
	end

	local player = game.Players:GetPlayerByUserId(userId)
	if not player then
		return
	end

	local info = PRODUCT_PRICES[productId]
	if not info then
		info = getProductInfo(productId)
		if info then
			PRODUCT_PRICES[productId] = info
		end
	end

	local itemName = info and info.Name or ("Product " .. tostring(productId))
	local price = info and info.PriceInRobux or 0

	ActivityReporter.Purchase(player.UserId, player.Name, itemName, "developer_product", price)
end)
