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