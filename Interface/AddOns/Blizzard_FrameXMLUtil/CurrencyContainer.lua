CurrencyContainerUtil = {};

function CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, numItems, name, texture, quality)
	local entry = C_CurrencyInfo.GetCurrencyContainerInfo(currencyID, numItems); 
	if (entry) then 
		return entry.name, entry.icon, entry.displayAmount, entry.quality; 
	end
	return name, texture, numItems, quality;
end

function CurrencyContainerUtil.GetCurrencyContainerInfoForAlert(currencyID, quantity, name, texture, quality)

	if (C_CurrencyInfo.IsCurrencyContainer(currencyID, quantity)) then
		return CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, quantity, name, texture, quality);
	end

	return name, texture, quantity, quality;
end

function WillCurrencyRewardOverflow(currencyID, rewardQuantity)
	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID);
	local quantity = currencyInfo.useTotalEarnedForMaxQty and currencyInfo.totalEarned or currencyInfo.quantity;
	return currencyInfo.maxQuantity > 0 and rewardQuantity + quantity > currencyInfo.maxQuantity;
end

function GetColorForCurrencyReward(currencyID, rewardQuantity, defaultColor)
	if WillCurrencyRewardOverflow(currencyID, rewardQuantity) then
		return RED_FONT_COLOR;
	elseif defaultColor then
		return defaultColor;
	else
		return HIGHLIGHT_FONT_COLOR;
	end
end