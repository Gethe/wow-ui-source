function AccountReactivate_ReactivateNow()
	StoreInterfaceUtil.OpenToSubscriptionProduct();
end

function AccountReactivate_Cancel()
	SubscriptionRequestDialog:Hide();
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT);
end

function AccountReactivate_CloseDialogs(preserveSubscription)
	ReactivateAccountDialog:Hide();
	AccountReactivationInProgressDialog:Hide();
	if (GoldReactivateConfirmationDialog:IsShown()) then
		C_WowTokenSecure.ConfirmBuyToken(false);
	end
	GoldReactivateConfirmationDialog:Hide();
	if (TokenReactivateConfirmationDialog:IsShown()) then
		C_WowTokenSecure.CancelRedeem();
	end
	TokenReactivateConfirmationDialog:Hide();
	if (not preserveSubscription) then
		SubscriptionRequestDialog:Hide();
	end
	CharacterSelect_UpdateButtonState();
end

function ReactivateAccountDialog_OnLoad(self)
	self:RegisterEvent("TOKEN_BUY_CONFIRM_REQUIRED");
	self:RegisterEvent("TOKEN_REDEEM_CONFIRM_REQUIRED");
	self:RegisterEvent("TOKEN_STATUS_CHANGED");
	self:RegisterEvent("TOKEN_REDEEM_RESULT");
	self:RegisterEvent("TOKEN_BUY_RESULT");
	self:RegisterEvent("TOKEN_MARKET_PRICE_UPDATED");
	self:RegisterEvent("TRIAL_STATUS_UPDATE");
end

function GetTimeLeftMinuteString(minutes)
	local weeks = 7 * 24 * 60; -- 7 days, 24 hours, 60 minutes
	local days = 24 * 60; -- 24 hours, 60 minutes
	local hours = 60; -- 60 minutes

	local str = "";
	if (math.floor(minutes / weeks) > 0) then
		local wks = math.floor(minutes / weeks);

		minutes = minutes - (wks * weeks);
		str = str .. format(WEEKS_ABBR, wks);
	end

	if (math.floor(minutes / days) > 0) then
		local dys = math.floor(minutes / days);

		minutes = minutes - (dys * days);
		str = str .. " " .. format(DAYS_ABBR, dys);
	end

	if (math.floor(minutes / hours) > 0) then
		local hrs = math.floor(minutes / hours);

		minutes = minutes - (hrs * hours);
		str = str .. " " .. format(HOURS_ABBR, hrs);
	end

	if (minutes > 0) then
		str = str .. " " .. format(MINUTES_ABBR, minutes);
	end

	return str;
end

GlueDialogTypes["TOKEN_ERROR_HAS_OCCURRED"] = {
	text = BLIZZARD_STORE_ERROR_MESSAGE_BATTLEPAY_DISABLED,
	button1 = OKAY,
	escapeHides = true,
}

GlueDialogTypes["TOKEN_NONE_FOR_SALE"] = {
	text = TOKEN_NONE_FOR_SALE,
	button1 = OKAY,
	escapeHides = true,
}

function ReactivateAccountDialog_OnEvent(self, event, ...)
	if (event == "TOKEN_BUY_CONFIRM_REQUIRED") then
		local dialog = GoldReactivateConfirmationDialog;
		
		local now = time();
		local newTime = now + (30 * 24 * 60 * 60); -- 30 days * 24 hours * 60 minutes * 60 seconds

		local newDate = date("*t", newTime);
		dialog.Description:SetText(ACCOUNT_REACTIVATE_DESC);
		dialog.Expires:SetText(ACCOUNT_REACTIVATE_EXPIRATION:format(newDate.month, newDate.day, newDate.year));
		dialog.Price:SetText(ACCOUNT_REACTIVATE_GOLD_PRICE:format(GetMoneyString(C_WowTokenPublic.GetGuaranteedPrice(), true)));
		dialog.Remaining:SetText(ACCOUNT_REACTIVATE_GOLD_REMAINING:format(GetMoneyString(C_WowTokenGlue.GetAccountRemainingGoldAmount(), true)));
		dialog.remainingDialogTime = C_WowTokenSecure.GetPriceLockDuration();
		dialog.CautionText:Hide();
		dialog.heightSet = false;
		if (not dialog.ticker) then
			dialog.ticker = C_Timer.NewTicker(1, function()
				if (dialog.remainingDialogTime == 0) then
					dialog.ticker:Cancel();
					dialog.ticker = nil;
					dialog:Hide();
					self:Show();
					CharacterSelect_UpdateButtonState();
				elseif (dialog.remainingDialogTime <= 20) then
					dialog.CautionText:SetText(TOKEN_PRICE_LOCK_EXPIRE:format(dialog.remainingDialogTime));
					dialog.CautionText:Show();
					if (not dialog.heightSet) then
						dialog:SetHeight(dialog:GetHeight() + dialog.CautionText:GetHeight() + 20);
						dialog.heightSet = true;
					end
				else
					dialog.CautionText:Hide();
				end
				dialog.remainingDialogTime = dialog.remainingDialogTime - 1;
			end);
		end
		dialog:Show();
		ReactivateAccountDialog:Hide();
		CharacterSelect_UpdateButtonState();
	elseif (event == "TOKEN_REDEEM_CONFIRM_REQUIRED") then
		local now = time();
		local newTime = now + (30 * 24 * 60 * 60); -- 30 days * 24 hours * 60 minutes * 60 seconds

		local newDate = date("*t", newTime);
		local dialog = TokenReactivateConfirmationDialog;
		dialog.Expires:SetText(ACCOUNT_REACTIVATE_EXPIRATION:format(newDate.month, newDate.day, newDate.year));
		dialog:Show();
		ReactivateAccountDialog:Hide();
		CharacterSelect_UpdateButtonState();
	elseif (event == "TOKEN_STATUS_CHANGED") then
		if (not C_WowTokenPublic.GetCommerceSystemStatus()) then
			AccountReactivate_CloseDialogs(true);
			if (SubscriptionRequestDialog:IsShown()) then
				SubscriptionRequestDialog_Open();
			end
		else
			AccountReactivate_RecheckEligibility();
		end
	elseif (event == "TOKEN_REDEEM_RESULT") then
		AccountReactivationInProgressDialog:Hide();
		CharacterSelect_UpdateButtonState();
	elseif (event == "TOKEN_MARKET_PRICE_UPDATED") then
		local result = ...;
		if (result == LE_TOKEN_RESULT_ERROR_DISABLED) then
			AccountReactivate_CloseDialogs(true);
			if (SubscriptionRequestDialog:IsShown()) then
				SubscriptionRequestDialog_Open();
			end
			return;
		end
		C_WowTokenGlue.CheckVeteranTokenEligibility();
		if (ReactivateAccountDialog:IsShown()) then
			ReactivateAccountDialog_Open();
		elseif (SubscriptionRequestDialog:IsShown()) then
			SubscriptionRequestDialog_Open();
		end
	elseif (event == "TOKEN_BUY_RESULT") then
		local result = ...;
		if (result ~= LE_TOKEN_RESULT_SUCCESS) then
			if (result == LE_TOKEN_RESULT_ERROR_NONE_FOR_SALE) then
				GlueDialog_Show("TOKEN_NONE_FOR_SALE");
			else
				GlueDialog_Show("TOKEN_ERROR_HAS_OCCURRED");
			end
			if (AccountReactivationInProgressDialog:IsShown()) then
				AccountReactivationInProgressDialog:Hide();
			end
			CharacterSelect_UpdateButtonState();
		end
	elseif (event == "TRIAL_STATUS_UPDATE") then
		if (not IsVeteranTrialAccount()) then
			AccountReactivate_CloseDialogs();
		end
	end
end

function ReactivateAccountDialog_CanOpen()
	if (AccountReactivationInProgressDialog:IsShown()) then
		return false;
	elseif (not C_WowTokenPublic.GetCommerceSystemStatus()) then
		return false;
	elseif (SubscriptionRequestDialog:IsShown()) then
		return false;
	elseif (TokenReactivateConfirmationDialog:IsShown()) then
		return false;
	elseif (GoldReactivateConfirmationDialog:IsShown()) then
		return false;
	elseif (CharacterSelect.undeleting) then
		return false;
	elseif (not CharacterSelect_HasVeteranEligibilityInfo()) then
		return false;
	elseif (GlueDialog:IsShown()) then
		return false;
	end

	return true;
end

function ReactivateAccountDialog_Open()
	local self = ReactivateAccountDialog;
	if (not ReactivateAccountDialog_CanOpen()) then
		self:Hide();
		return;
	end
	AccountReactivate_CloseDialogs();
	if (C_WowTokenGlue.GetTokenCount() > 0) then
		self.redeem = true;
		self.Title:SetText(ACCOUNT_REACTIVATE_TOKEN_TITLE);
		self.Description:SetText(ACCOUNT_REACTIVATE_TOKEN_DESC);
		self.Accept:SetText(ACCOUNT_REACTIVATE_TOKEN_ACCEPT);
		self:Show();
	elseif (C_WowTokenGlue.CanVeteranBuy() or CAN_BUY_RESULT_FOUND == LE_TOKEN_RESULT_ERROR_NONE_FOR_SALE) then
		self.redeem = false;
		self.Title:SetText(ACCOUNT_REACTIVATE_GOLD_TITLE);
		self.Description:SetText(ACCOUNT_REACTIVATE_GOLD_DESC);
		self.Accept:SetText(ACCOUNT_REACTIVATE_ACCEPT:format(GetMoneyString(C_WowTokenPublic.GetCurrentMarketPrice(), true)));
		ReactivateAccount_CreatePriceUpdateTicker();
		self.Accept:SetEnabled(C_WowTokenPublic.GetCurrentMarketPrice() > 0 and CAN_BUY_RESULT_FOUND == LE_TOKEN_RESULT_SUCCESS);
		if (CAN_BUY_RESULT_FOUND == LE_TOKEN_RESULT_ERROR_NONE_FOR_SALE) then
			self.Accept.tooltip = TOKEN_NONE_FOR_SALE;
		else
			self.Accept.tooltip = nil;
		end
		self:Show();
	else
		self:Hide();
	end
	self:SetHeight( 60 + self.Description:GetHeight() + 70 );
	CharacterSelect_UpdateButtonState();
end

function SubscriptionRequestDialog_Open()
	if (AccountReactivationInProgressDialog:IsShown()) then
		return;
	end
	AccountReactivate_CloseDialogs(true);
	local self = SubscriptionRequestDialog;
	local enabled = C_WowTokenPublic.GetCommerceSystemStatus();

	if (C_WowTokenGlue.GetTokenCount() > 0 and enabled) then
		self.redeem = true;
		self.Reactivate:SetText(ACCOUNT_REACTIVATE_TOKEN_ACCEPT);
		self.ButtonDivider:Show();
		self.Reactivate:Show();
		self.Reactivate:Enable();
		self:SetHeight(self.Text:GetHeight() + 16 + self.ButtonDivider:GetHeight() + self.Accept:GetHeight() + 50 + self.Reactivate:GetHeight());
	elseif (C_WowTokenGlue.CanVeteranBuy() and C_WowTokenPublic.GetCurrentMarketPrice() and enabled) then	
		self.redeem = false;
		self.Reactivate:SetText(ACCOUNT_REACTIVATE_ACCEPT:format(GetMoneyString(C_WowTokenPublic.GetCurrentMarketPrice(), true)));
		self.ButtonDivider:Show();
		self.Reactivate:Show();
		self.Reactivate:SetEnabled(C_WowTokenPublic.GetCurrentMarketPrice() > 0);
		self:SetHeight(self.Text:GetHeight() + 16 + self.ButtonDivider:GetHeight() + self.Accept:GetHeight() + 50 + self.Reactivate:GetHeight());
	elseif (CAN_BUY_RESULT_FOUND == LE_TOKEN_RESULT_SUCCESS_NO and enabled) then
		self.Reactivate.tooltip = ERR_NOT_ENOUGH_GOLD;
		self.Reactivate:SetText(ACCOUNT_REACTIVATE_ACCEPT:format(GetMoneyString(C_WowTokenPublic.GetCurrentMarketPrice(), true)));
		self.ButtonDivider:Show();
		self.Reactivate:Show();
		self.Reactivate:Disable();
		self:SetHeight(self.Text:GetHeight() + 16 + self.ButtonDivider:GetHeight() + self.Accept:GetHeight() + 50 + self.Reactivate:GetHeight());
	else
		self.ButtonDivider:Hide();
		self.Reactivate:Hide();
		self:SetHeight(self.Text:GetHeight() + 16 + self.Accept:GetHeight() + 50);
	end
	
	
	self:Show();
	if (not C_WowTokenPublic.GetCurrentMarketPrice()) then
		ReactivateAccount_UpdateMarketPrice();
	end
	CharacterSelect_UpdateButtonState();
end

function ReactivateAccountDialog_OnReactivate(self)
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
	if (self:GetParent().redeem) then
		C_WowTokenSecure.RedeemToken(LE_TOKEN_REDEEM_TYPE_GAME_TIME);
	else
		C_WowTokenPublic.BuyToken();
	end
	self:GetParent():Hide();
end
 
function ReactivateAccount_CreatePriceUpdateTicker()
	local self = ReactivateAccountDialog;
	local _, pollTimeSeconds = C_WowTokenPublic.GetCommerceSystemStatus();
	if (not self.priceUpdateTimer or pollTimeSeconds ~= self.priceUpdateTimer.pollTimeSeconds) then
		if (self.priceUpdateTimer) then
			self.priceUpdateTimer:Cancel();
		end
		self.priceUpdateTimer = C_Timer.NewTicker(pollTimeSeconds, ReactivateAccount_UpdateMarketPrice);
		self.priceUpdateTimer.pollTimeSeconds = pollTimeSeconds;
	end
end

function ReactivateAccount_UpdateMarketPrice()
	C_WowTokenPublic.UpdateMarketPrice();
	local self = ReactivateAccountDialog;
	if (SubscriptionRequestDialog:IsShown() or ReactivateAccountDialog:IsShown()) then
		local _, pollTimeSeconds = C_WowTokenPublic.GetCommerceSystemStatus();
		if (not self.priceUpdateTimer or pollTimeSeconds ~= self.priceUpdateTimer.pollTimeSeconds) then
			if (self.priceUpdateTimer) then
				self.priceUpdateTimer:Cancel();
			end
			self.priceUpdateTimer = C_Timer.NewTicker(pollTimeSeconds, ReactivateAccount_UpdateMarketPrice);
			self.priceUpdateTimer.pollTimeSeconds = pollTimeSeconds;
		end
	else
		if (self.priceUpdateTimer) then
			self.priceUpdateTimer:Cancel();
			self.priceUpdateTimer = nil;
		end
	end
end

function AccountReactivate_RecheckEligibility()
	if (MARKET_PRICE_UPDATED == LE_TOKEN_RESULT_SUCCESS and (CAN_BUY_RESULT_FOUND == LE_TOKEN_RESULT_SUCCESS or CAN_BUY_RESULT_FOUND == LE_TOKEN_RESULT_SUCCESS_NO) and TOKEN_COUNT_UPDATED) then
		if (SubscriptionRequestDialog:IsShown()) then
			SubscriptionRequestDialog_Open();
		else
			ReactivateAccountDialog_Open();
		end
		return;
	end
	CAN_BUY_RESULT_FOUND = false;
	TOKEN_COUNT_UPDATED = false;
	CharacterSelect_CheckVeteranStatus();
end