
RuneforgeSystemMixin = {};

function RuneforgeSystemMixin:GetRuneforgeFrame()
	return self:GetParent();
end


RuneforgeUtil = {};

function RuneforgeUtil.GetCostsString(costs)
	local resultString = "";
	for i, cost in ipairs(costs) do
		local currencyInfo = C_CurrencyInfo.GetBasicCurrencyInfo(cost.currencyID);
		if currencyInfo then
			local currencyMarkup = CreateTextureMarkup(currencyInfo.icon, 64, 64, 14, 14, 0, 1, 0, 1);
			resultString = resultString.." "..cost.amount.." "..currencyMarkup;
		end
	end

	return resultString;
end

function RuneforgeUtil.GetRuneforgeCurrencies()
	-- TODO:: Hardcoded for now.
	return { 1767, 1716 };
end
