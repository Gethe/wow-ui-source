
local AccountStoreWarningThresholdPercentage = 0.66;
local AlertIconTexture = [[Interface\DialogFrame\UI-Dialog-Icon-AlertNew]];

local function PrependWarning(text)
	return CreateSimpleTextureMarkup(AlertIconTexture, 12, 12) .. " " .. text;
end

AccountStoreUtil = {};

function AccountStoreUtil.SetAccountStoreShown(shown)
	if AccountStoreFrame:IsShown() == shown then
		return;
	end

	if shown then
		if ShowUIPanel then
			ShowUIPanel(AccountStoreFrame);
		else
			AccountStoreFrame:Show();
		end
	else
		if HideUIPanel then
			HideUIPanel(AccountStoreFrame);
		else
			AccountStoreFrame:Hide();
		end
	end
end

function AccountStoreUtil.ToggleAccountStore()
	AccountStoreUtil.SetAccountStoreShown(not AccountStoreFrame:IsShown());
end

function AccountStoreUtil.FormatCurrencyDisplay(currencyAmount, accountStoreCurrencyID)
	local currencyInfo = C_AccountStore.GetCurrencyInfo(accountStoreCurrencyID);
	return BreakUpLargeNumbers(currencyAmount) .. " " .. CreateSimpleTextureMarkup(currencyInfo.icon, 12, 12);
end

function AccountStoreUtil.IsCurrencyAtWarningThreshold(accountStoreCurrencyID)
	local currencyInfo = C_AccountStore.GetCurrencyInfo(accountStoreCurrencyID);
	if currencyInfo and currencyInfo.maxQuantity then
		return currencyInfo.amount >= (currencyInfo.maxQuantity * AccountStoreWarningThresholdPercentage);
	end

	return false;
end

function AccountStoreUtil.FormatCurrencyDisplayWithWarning(accountStoreCurrencyID, currencyAmount, hideIcon)
	local currencyInfo = C_AccountStore.GetCurrencyInfo(accountStoreCurrencyID);
	if not currencyInfo then
		return "";
	end

	local function AppendIcon(text)
		return text .. " " .. CreateSimpleTextureMarkup(currencyInfo.icon, 12, 12);
	end

	currencyAmount = BreakUpLargeNumbers(currencyAmount or currencyInfo.amount);
	local showWarning = false;
	if currencyInfo.maxQuantity then
		if currencyInfo.amount >= currencyInfo.maxQuantity then
			currencyAmount = RED_FONT_COLOR:WrapTextInColorCode(currencyAmount);
			showWarning = true;
		elseif currencyInfo.amount >= (currencyInfo.maxQuantity * AccountStoreWarningThresholdPercentage) then
			currencyAmount = NORMAL_FONT_COLOR:WrapTextInColorCode(currencyAmount);
			showWarning = true;
		end
	end
	
	local currencyText = currencyAmount;
	if not hideIcon then
		currencyText = AppendIcon(currencyText);
	end

	if showWarning then
		currencyText = PrependWarning(currencyText);
	end

	return currencyText;
end

function AccountStoreUtil.AddCurrencyTotalTooltip(tooltip, accountStoreCurrencyID)
	local currencyInfo = C_AccountStore.GetCurrencyInfo(accountStoreCurrencyID);
	if not currencyInfo then
		return false;
	end

	GameTooltip_AddNormalLine(tooltip, currencyInfo.name);

	if currencyInfo.maxQuantity then
		if currencyInfo.amount >= currencyInfo.maxQuantity then
			local text = PrependWarning(ACCOUNT_STORE_CURRENCY_MAX_TOOLTIP_FORMAT:format(currencyInfo.name));
			GameTooltip_AddNormalLine(tooltip, text);
		elseif currencyInfo.amount >= (currencyInfo.maxQuantity * AccountStoreWarningThresholdPercentage) then
			local text = PrependWarning(ACCOUNT_STORE_CURRENCY_APPROACHING_MAX_TOOLTIP_FORMAT:format(currencyInfo.name));
			GameTooltip_AddNormalLine(tooltip, text);
		end

		GameTooltip_AddHighlightLine(tooltip, ACCOUNT_STORE_CURRENCY_TOTAL_TOOLTIP_FORMAT:format(BreakUpLargeNumbers(currencyInfo.amount), BreakUpLargeNumbers(currencyInfo.maxQuantity)));
		return true;
	end

	-- No tooltip needed.
	return false;
end

function AccountStoreUtil.ShowDisabledItemInfoTooltip(frame, itemInfo)
	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(frame, "ANCHOR_RIGHT");

	if itemInfo.status == Enum.AccountStoreItemStatus.Refundable then
		tooltip:SetText(PLUNDERSTORE_REFUNDABLE_TOOLTIP);
	elseif itemInfo.status == Enum.AccountStoreItemStatus.Owned then
		tooltip:SetText(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(AccountStoreUtil.FormatCurrencyDisplay(itemInfo.price, itemInfo.currencyID)));
	else
		tooltip:SetText(PLUNDERSTORE_INSUFFICIENT_FUNDS_TOOLTIP);
	end
end
