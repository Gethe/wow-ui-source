function GameMenuFrame_OnShow(self)
	UpdateMicroButtons();
	Disable_BagButtons();

	GameMenuFrame_UpdateVisibleButtons(self);
end

function GameMenuFrame_UpdateVisibleButtons(self)
	local height = 272;
	GameMenuButtonUIOptions:SetPoint("TOP", GameMenuButtonOptions, "BOTTOM", 0, -1);

	local storeIsRestricted = IsTrialAccount();
	if ( C_StorePublic.IsEnabled() and C_StorePublic.HasPurchaseableProducts() and not storeIsRestricted ) then
		height = height + 20;
		GameMenuButtonStore:Show();
	else
		GameMenuButtonStore:Hide();
		GameMenuButtonOptions:SetPoint("TOP", GameMenuButtonHelp, "BOTTOM", 0, -16);
	end

	if ( not GameMenuButtonRatings:IsShown() and GetNumAddOns() == 0 ) then
		GameMenuButtonLogout:SetPoint("TOP", GameMenuButtonMacros, "BOTTOM", 0, -16);
	else
		if ( GetNumAddOns() ~= 0 ) then
			height = height + 20;
			GameMenuButtonLogout:SetPoint("TOP", GameMenuButtonAddons, "BOTTOM", 0, -16);
		end

		if ( GameMenuButtonRatings:IsShown() ) then
			height = height + 20;
			GameMenuButtonLogout:SetPoint("TOP", GameMenuButtonRatings, "BOTTOM", 0, -16);
		end
	end

	self:SetHeight(height);
end

function GameMenuFrame_UpdateStoreButtonState(self)
	if ( IsVeteranTrialAccount() ) then
		self.disabledTooltip = ERR_RESTRICTED_ACCOUNT_TRIAL;
		self:Disable();
	elseif ( C_StorePublic.IsDisabledByParentalControls() ) then
		self.disabledTooltip = BLIZZARD_STORE_ERROR_PARENTAL_CONTROLS;
		self:Disable();
	elseif ( Kiosk.IsEnabled() ) then
		self.disabledTooltip = nil;
		self:Disable();
	else
		self.disabledTooltip = nil;
		self:Enable();
	end
end
