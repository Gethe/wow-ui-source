function GameMenuFrame_OnShow(self)
	UpdateMicroButtons();
	Disable_BagButtons();
	if (CanAutoSetGamePadCursorControl(true)) then
		SetGamePadCursorControl(true);
	end

	GameMenuFrame_UpdateVisibleButtons(self);
end

function GameMenuFrame_UpdateVisibleButtons(self)
	local height = 292;
	GameMenuButtonUIOptions:SetPoint("TOP", GameMenuButtonOptions, "BOTTOM", 0, -1);

	local buttonToReanchor = GameMenuButtonWhatsNew;
	local reanchorYOffset = -1;

	if IsCharacterNewlyBoosted() or not C_SplashScreen.CanViewSplashScreen()  then
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

	self:SetHeight(height);
end

function GameMenuFrame_UpdateStoreButtonState(self)
	if ( C_StorePublic.IsDisabledByParentalControls() ) then
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
