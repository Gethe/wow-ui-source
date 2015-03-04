function AccountReactivate_DisplaySubscriptionRequest()
	ReactivateAccountDialog:Hide();
	AccountReactivatedDialog:Hide();
	GoldReactivateConfirmationDialog:Hide();
	TokenReactivateConfirmationDialog:Hide();
	
	SubscriptionRequestDialog:Show();
end

function AccountReactivate_ReactivateNow()
	PlaySound("gsTitleOptionOK");
	
	-- open web page
	LoadURLIndex(2);
end

function AccountReactivate_Cancel()
	SubscriptionRequestDialog:Hide();
	PlaySound("gsTitleOptionExit");
end

function AccountReactivate_CloseDialogs()
	ReactivateAccountDialog:Hide();
	AccountReactivationSuccessDialog:Hide();
	GoldReactivateConfirmationDialog:Hide();
	TokenReactivateConfirmationDialog:Hide();
	SubscriptionRequestDialog:Hide();
end

function ReactivateAccountDialog_OnLoad(self)
	self:SetHeight( 60 + self.Description:GetHeight() + 64 + self.ButtonDivider:GetHeight() + 4 + self.Reactivate:GetHeight() + 16 );
	self:RegisterEvent("TOKEN_BUY_CONFIRM_REQUIRED");
	self:RegisterEvent("TOKEN_REDEEM_CONFIRM_REQUIRED");
	self:RegisterEvent("TOKEN_REDEEM_RESULT");
end

function ReactivateAccountDialog_OnEvent(self, event, ...)
	if (event == "TOKEN_BUY_CONFIRM_REQUIRED") then
		local now = time();
		local newTime = now + (30 * 24 * 60 * 60); -- 30 days * 24 hours * 60 minutes * 60 seconds

		local newDate = date("*t", newTime);
		local dialog = GoldReactivateConfirmationDialog;
		dialog.Expires:SetText(ACCOUNT_REACTIVATE_EXPIRATION:format(newDate.month, newDate.day, newDate.year));
		dialog.Price:SetText(ACCOUNT_REACTIVATE_GOLD_PRICE:format(GetMoneyString(C_WowTokenSecure.GetGuaranteedPrice())));
		dialog:Show();
	elseif (event == "TOKEN_REDEEM_CONFIRM_REQUIRED") then
		local now = time();
		local newTime = now + (30 * 24 * 60 * 60); -- 30 days * 24 hours * 60 minutes * 60 seconds

		local newDate = date("*t", newTime);
		local dialog = TokenReactivateConfirmationDialog;
		dialog.Expires:SetText(ACCOUNT_REACTIVATE_EXPIRATION:format(newDate.month, newDate.day, newDate.year));
		dialog:Show();
	elseif (event == "TOKEN_REDEEM_RESULT") then
		local result = ...;
		-- TEMP: Error handling
		if (result == 1) then
			AccountReactivationSuccessDialog:Show();
		end
	end
end

function ReactivateAccountDialog_Open()
	local self = ReactivateAccountDialog;
	if (C_WowTokenGlue.GetTokenCount() > 0) then
		self.redeem = true;
		self.Accept:SetText(ACCOUNT_REACTIVATE_TOKEN_ACCEPT);
		self:Show();
	elseif (C_WowTokenGlue.CanVeteranBuy()) then
		self.redeem = false;
		self.Accept:SetText(ACCOUNT_REACTIVATE_ACCEPT:format(GetMoneyString(C_WowTokenPublic.GetCurrentMarketPrice())));
		self:Show();
	else
		self:Hide();
	end
end

function ReactivateAccountDialog_OnAccept(self)
	PlaySound("gsTitleOptionOK");
	if (self:GetParent().redeem) then
		C_WowTokenSecure.RedeemToken();
	else
		C_WowTokenPublic.BuyToken();
	end
	self:GetParent():Hide();
end

function SubscriptionRequestDialog_Open()
	AccountReactivate_CloseDialogs();
	SubscriptionRequestDialog:Show();
end