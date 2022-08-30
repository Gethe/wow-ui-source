function BarberShop_OnLoad(self)
	self:RegisterEvent("BARBER_SHOP_RESULT");
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
	if ( C_PlayerInfo.GetAlternateFormInfo() ) then
		local model = BarberShopAltFormFrame;
		model:Show();
		model:SetRotation(-0.4);
		model.rotation = -0.4;
		if (UnitSex("player") == 2) then
			model:SetPosition(0, 0.05, -0.03);
		else
			model:SetPosition(0, 0, -0.05);
		end
		model:SetPortraitZoom(0.9);
	else
		BarberShopAltFormFrame:Hide();
	end
	BarberShop_UpdateSexSelectors() 
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
	MoneyFrame_Update(BarberShopFrameMoneyFrame:GetName(), C_BarberShop.GetCurrentCost());
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

function BarberShop_UpdateSelector(self, updateBanner)
	updateBanner = updateBanner or 1;
	local customName, name, isCurrent = C_BarberShop.GetCustomizationTypeInfo(self:GetID());
	if updateBanner == 1 then
		BarberShop_UpdateBanner(name);
		BarberShop_SetLabelColor(self.Category, not isCurrent);
	end
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
end

function BarberShop_SetSelectedSex(self, sex)
	if not C_BarberShop.IsViewingVisibleSex(sex) then
		BarberShop_ResetBanner();
		C_BarberShop.SetSelectedSex(sex);
		if sex == 0 then
			BarberShopFrameMaleButton:SetChecked(1);
			BarberShopFrameFemaleButton:SetChecked(nil);
		else
			BarberShopFrameMaleButton:SetChecked(nil);
			BarberShopFrameFemaleButton:SetChecked(1);
		end
		BarberShop_Update(self);
	else
		BarberShop_Update(self, 0);
	end
	self.FacialHairSelector.Category:SetText(C_BarberShop.GetCustomizationTypeInfo(Enum.CharCustomizationType.FacialHair));
end