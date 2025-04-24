WORGEN_RACE_ID = 22;
GILNEAN_RACE_ID = 23;

function BarberShop_OnLoad(self)
	self:RegisterEvent("BARBER_SHOP_RESULT");
	self:RegisterEvent("BARBER_SHOP_FORCE_CUSTOMIZATIONS_UPDATE");
	if ( C_BarberShop.IsValidCustomizationType(Enum.CharCustomizationType.Skin) ) then
		if ( C_BarberShop.IsValidCustomizationType(Enum.CharCustomizationType.HairColor) ) then
			-- tauren, worgen, female pandaren
			self.SkinColorSelector:Show();
		else
			-- male pandaren
			self.HairColorSelector:Hide();
			self.SkinColorSelector:Show();
		end
	end
	BarberShop_HandleAlternateFormButtons(true);
end

function BarberShop_SetViewingAlteredForm(viewingAlteredForm)
	if(C_BarberShop.IsViewingAlteredForm() ~= viewingAlteredForm) then
		C_BarberShop.SetViewingAlteredForm(viewingAlteredForm);
		BarberShopAlternateFormTop:SetChecked(not viewingAlteredForm);
		BarberShopAlternateFormBottom:SetChecked(viewingAlteredForm);
	end
end

function BarberShop_HandleAlternateFormButtons(initialSetup, currentSex)
	if (C_BarberShop.HasAlteredForm()) then
		if(initialSetup) then
			BarberShopAlternateFormTop:Show();
			BarberShopAlternateFormBottom:Show();
			BarberShopAlternateFormTopTop:SetRotation(1.5708);
			BarberShopAlternateFormBottomBottom:SetRotation(1.5708);
		end
		if(not currentSex) then
			currentSex = 0;
			if (C_BarberShop.IsViewingVisibleSex(1)) then
				currentSex = 1;
			end
		end
		C_BarberShop.SetPortraitTexture(BarberShopAlternateFormTopPortrait, WORGEN_RACE_ID, currentSex);
		C_BarberShop.SetPortraitTexture(BarberShopAlternateFormBottomPortrait, GILNEAN_RACE_ID, currentSex);
	end
end

function BarberShop_CheckForInvalidOptions(self)
	-- worgens for classic
	if (C_BarberShop.IsValidCustomizationType(Enum.CharCustomizationType.HairColor)) then
		self.HairColorSelector:Show();
	else
		self.HairColorSelector:Hide();
	end
end

function BarberShop_OnShow(self)
	BarberShop_UpdateCustomizationOptions(self);

	CloseAllBags();
	BarberShop_ResetLabelColors();
	BarberShop_UpdateCost(self);
	if ( BarberShopBannerFrame ) then
		BarberShopBannerFrame:Show();
		BarberShopBannerFrame.caption:SetText(BARBERSHOP);
	end
	self:ClearAllPoints();
	self:SetPoint("RIGHT", min(-50, -CONTAINER_OFFSET_X), -50);
	BarberShop_UpdateSexSelectors();
	BarberShop_HandleAlternateFormButtons(false);

	BarberShop_CheckForInvalidOptions(self);
	BarberShop_Update(self);

	local isViewingAlteredForm = C_BarberShop.IsViewingAlteredForm();
	BarberShopAlternateFormTop:SetChecked(not isViewingAlteredForm);
	BarberShopAlternateFormBottom:SetChecked(isViewingAlteredForm);
	PlaySound(SOUNDKIT.BARBERSHOP_SIT);
end

function BarberShop_UpdateSexSelectors()
	local checkMaleSex = C_BarberShop.IsViewingVisibleSex(0);
	BarberShopFrameMaleButton:SetChecked(checkMaleSex); 
	BarberShopFrameFemaleButton:SetChecked(not checkMaleSex);
end

function BarberShop_OnHide(self)
	BarberShopBannerFrame:Hide();
	BarbersChoiceConfirmFrame:Hide();
end

function BarberShop_OnEvent(self, event, ...)
	local isResult = false;
	if(event == "BARBER_SHOP_RESULT") then
		PlaySound(SOUNDKIT.BARBERSHOP_HAIRCUT);
		BarberShop_ResetAll();
		isResult = true;
	elseif(event == "BARBER_SHOP_FORCE_CUSTOMIZATIONS_UPDATE") then
	    BarberShop_ResetBanner();
		BarberShop_CheckForInvalidOptions(self);	
	end

	if (self:IsShown()) then
		BarberShop_Update(self);
		if isResult then
			BarberShopFrameOkayButton:Disable();
			BarberShopFrameResetButton:Disable();
		end
	end
end

function BarberShop_UpdateCost(self)
	-- [CLASS - 34071]: Remove Barbershop Cost code
	-- Cost is now deprecated for Classic and Mainline
	-- MoneyFrame_Update(BarberShopFrameMoneyFrame:GetName(), C_BarberShop.GetCurrentCost());

	-- The 4th return from GetBarberShopStyleInfo is whether the selected style is the active character style
	-- Enable the okay and reset buttons if anything has changed
	for i=1, #self.Selector do
		if ( self.Selector[i]:IsShown() ) then
			if ( select(3, C_BarberShop.GetCustomizationTypeInfo( self.Selector[i]:GetID() ) )  or not C_BarberShop.IsViewingNativeSex()) then
				BarberShopFrameOkayButton:Enable();
				BarberShopFrameResetButton:Enable();
				return;
			end
		end
	end
	BarberShopFrameOkayButton:Disable();
	BarberShopFrameResetButton:Disable();
end

function BarberShop_UpdateBanner(name)
	if ( name and name ~= "" ) then
		BarberShopBannerFrameCaption:SetText(name);
	end
end

function BarberShop_ResetBanner()
	BarberShopBannerFrameCaption:SetText(BARBERSHOP);
end

function BarberShop_Update(self, updateBanner)
	updateBanner = updateBanner or 1;
	BarberShop_UpdateCost(self);
	BarbersChoiceConfirmFrame:Hide();
	for i=1, #self.Selector do
		BarberShop_UpdateSelector(self.Selector[i], updateBanner);
	end
	BarberShop_UpdateCustomizationOptions(self);
end

-- Returns true if the Banner Name was updated.
function BarberShop_UpdateSelector(self, updateBanner)
	updateBanner = updateBanner or 1;
	local customName, name, isCurrent = C_BarberShop.GetCustomizationTypeInfo(self:GetID());
	if updateBanner == 1 then
		BarberShop_UpdateBanner(name);
		BarberShop_SetLabelColor(self.Category, not isCurrent);

		if ( name and name ~= "" ) then
			return true;
		end
	end

	return false;
end

function BarberShop_UpdateCustomizationOptions(self)
	self.HairStyleSelector.Category:SetText(C_BarberShop.GetCustomizationTypeInfo(Enum.CharCustomizationType.Hair));
	self.HairColorSelector.Category:SetText(C_BarberShop.GetCustomizationTypeInfo(Enum.CharCustomizationType.HairColor));
	self.FacialHairSelector.Category:SetText(C_BarberShop.GetCustomizationTypeInfo(Enum.CharCustomizationType.FacialHair));

	for i = 1, Constants.CharCustomizationConstants.NUM_CUSTOM_DISPLAY do
		local barberStyle = Constants.CharCustomizationConstants.CHAR_CUSTOMIZE_CUSTOM_DISPLAY_OPTION_FIRST + i;
		self.Selector[barberStyle]:SetShown(select(3, C_BarberShop.GetCustomizationTypeInfo(barberStyle)));

		local charCustomization = Constants.CharCustomizationConstants.CHAR_CUSTOMIZE_CUSTOM_DISPLAY_OPTION_FIRST + i;
		self.Selector[barberStyle].Category:SetText(C_BarberShop.GetCustomizationTypeInfo(charCustomization));
	end

	self:Layout();
end

function BarberShop_SetLabelColor(label, isCurrent)
	if ( isCurrent ) then
		label:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	else
		label:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
end

function BarberShop_ResetLabelColors()
	for i=1, #BarberShopFrame.Selector do
		BarberShop_SetLabelColor(BarberShopFrame.Selector[i].Category, i);
	end
end

function BarberShop_ResetAll()
	C_BarberShop.ResetCustomizationChoices();
	BarberShop_ResetLabelColors();
	BarberShop_ResetBanner();
	BarberShop_UpdateSexSelectors()
	BarberShop_HandleAlternateFormButtons(false);
end

function BarberShop_SetSelectedSex(self, sex)
	if not C_BarberShop.IsViewingVisibleSex(sex) then
		C_BarberShop.SetSelectedSex(sex);
		if sex == 0 then
			BarberShopFrameMaleButton:SetChecked(1);
			BarberShopFrameFemaleButton:SetChecked(nil);
		else
			BarberShopFrameMaleButton:SetChecked(nil);
			BarberShopFrameFemaleButton:SetChecked(1);
		end
	end
	self.FacialHairSelector.Category:SetText(C_BarberShop.GetCustomizationTypeInfo(Enum.CharCustomizationType.FacialHair));
	BarberShop_HandleAlternateFormButtons(false, sex);
end
