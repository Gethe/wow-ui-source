CurrencyContainerUtil = {} 

function CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, numItems, name, texture, quality)
	local entry = C_CurrencyInfo.GetCurrencyContainerInfo(currencyID, numItems); 
	
	if (entry) then 
		return entry.name, entry.icon, entry.displayAmount, entry.quality; 
	end
	return name, texture, numItems, quality;
end
			