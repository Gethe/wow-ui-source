function GameMenuFrame_OnShow(self)
	UpdateMicroButtons();
	Disable_BagButtons();
	VoiceChat_Toggle();

	GameMenuFrame_UpdateVisibleButtons(self);
end

function GameMenuFrame_UpdateVisibleButtons(self)
	local height = 292;
	GameMenuButtonUIOptions:SetPoint("TOP", GameMenuButtonOptions, "BOTTOM", 0, -1);

	local buttonToReanchor = GameMenuButtonWhatsNew;
	local reanchorYOffset = -1;

	if (not SplashFrameCanBeShown()) then
		GameMenuButtonWhatsNew:Hide();
		height = height - 20;
		buttonToReanchor = GameMenuButtonOptions;
		reanchorYOffset = -16;
	else
		GameMenuButtonWhatsNew:Show();
		GameMenuButtonOptions:SetPoint("TOP", GameMenuButtonWhatsNew, "BOTTOM", 0, -16);
	end

	if ( C_StorePublic.IsEnabled() ) then
		height = height + 20;
		GameMenuButtonStore:Show();
		buttonToReanchor:SetPoint("TOP", GameMenuButtonStore, "BOTTOM", 0, reanchorYOffset);
	else
		GameMenuButtonStore:Hide();
		buttonToReanchor:SetPoint("TOP", GameMenuButtonHelp, "BOTTOM", 0, reanchorYOffset);
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
	
	if ( IsCharacterNewlyBoosted() ) then
		GameMenuButtonWhatsNew:SetText(GAMEMENU_BOOST_BUTTON);
	else
		GameMenuButtonWhatsNew:SetText(GAMEMENU_NEW_BUTTON);
	end

	self:SetHeight(height);
end

function GameMenuFrame_UpdateStoreButtonState(self)
	if ( GameLimitedMode_IsActive() ) then
		self.disabledTooltip = ERR_RESTRICTED_ACCOUNT_TRIAL;
		self:Disable();
	elseif ( C_StorePublic.IsDisabledByParentalControls() ) then
		self.disabledTooltip = BLIZZARD_STORE_ERROR_PARENTAL_CONTROLS;
		self:Disable();		
	else
		self.disabledTooltip = nil;
		self:Enable();
	end
end
