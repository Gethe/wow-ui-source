CurrencyContainerUtil = {};

function CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, numItems, name, texture, quality)
	local entry = C_CurrencyInfo.GetCurrencyContainerInfo(currencyID, numItems); 
	
	-- by default, the display amount we want to return is 1 for currencies
	local displayAmount = entry.displayAmount;

	if currencyID == C_CurrencyInfo.GetAzeriteCurrencyID() then
	-- but for Azerite, we need the ACTUAL amount so that we can pick an appropriate texture to display
		displayAmount = entry.actualAmount;
	end

	if (entry) then 
		return entry.name, entry.icon, displayAmount, entry.quality; 
	end
	return name, texture, numItems, quality;
end

function CurrencyContainerUtil.GetCurrencyContainerInfoForAlert(currencyID, quantity, name, texture, quality)

	if (C_CurrencyInfo.IsCurrencyContainer(currencyID, quantity)) then
		return CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, quantity, name, texture, quality);
	end

	return name, texture, quantity, quality;
end