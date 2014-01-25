function GameMenuFrame_OnShow(self)
	UpdateMicroButtons();
	Disable_BagButtons();
	VoiceChat_Toggle();

	GameMenuFrame_UpdateVisibleButtons(self);
end

function GameMenuFrame_UpdateVisibleButtons(self)
	local height = 270;
	if ( IsMacClient() ) then
		height = height + 20;
		GameMenuButtonMacOptions:Show();
		GameMenuButtonUIOptions:SetPoint("TOP", GameMenuButtonMacOptions, "BOTTOM", 0, -1);
	else
		GameMenuButtonMacOptions:Hide();
		GameMenuButtonUIOptions:SetPoint("TOP", GameMenuButtonOptions, "BOTTOM", 0, -1);
	end

	if ( C_StorePublic.IsEnabled() ) then
		height = height + 20;
		GameMenuButtonStore:Show();
		GameMenuButtonOptions:SetPoint("TOP", GameMenuButtonStore, "BOTTOM", 0, -16);
	else
		GameMenuButtonStore:Hide();
		GameMenuButtonOptions:SetPoint("TOP", GameMenuButtonHelp, "BOTTOM", 0, -16);
	end

	if ( GameMenuButtonRatings:IsShown() ) then
		height = height + 20;
		GameMenuButtonLogout:SetPoint("TOP", GameMenuButtonRatings, "BOTTOM", 0, -16);
	else
		GameMenuButtonLogout:SetPoint("TOP", GameMenuButtonMacros, "BOTTOM", 0, -16);
	end

	self:SetHeight(height);
end

function GameMenuFrame_UpdateStoreButtonState(self)
	if ( IsTrialAccount() ) then
		self.disabledTooltip = ERR_GUILD_TRIAL_ACCOUNT;
		self:Disable();
	elseif ( C_StorePublic.IsDisabledByParentalControls() ) then
		self.disabledTooltip = BLIZZARD_STORE_ERROR_PARENTAL_CONTROLS;
		self:Disable();		
	else
		self.disabledTooltip = nil;
		self:Enable();
	end
end
