function BarberShop_OnLoad(self)
	BarberShop_UpdateHairCustomization();
	BarberShop_UpdateFacialHairCustomization();
	self:RegisterEvent("BARBER_SHOP_APPEARANCE_APPLIED");
	self:RegisterEvent("BARBER_SHOP_SUCCESS");
	
	if ( CanAlterSkin() ) then
		BarberShop_ToFourAttributeFormat();
	end
end

function BarberShop_OnShow(self)
	CloseAllBags();
	BarberShop_ResetLabelColors();
	BarberShop_UpdateCost();
	if ( BarberShopBannerFrame ) then
		BarberShopBannerFrame:Show();
		BarberShopBannerFrame.caption:SetText(BARBERSHOP);
	end
	self:ClearAllPoints();
	self:SetPoint("RIGHT", min(-50, -CONTAINER_OFFSET_X), -50);

	PlaySound("BarberShop_Sit");
	
	WatchFrame:Hide();

	--load the texture
	BarberShopFrameBackground:SetTexture("Interface\\Barbershop\\UI-Barbershop");
end

function BarberShop_OnHide(self)
	BarberShopBannerFrame:Hide();

	WatchFrame:Show();
	
	--unload the texture to save memory
	BarberShopFrameBackground:SetTexture(nil);
end

function BarberShop_OnEvent(self, event, ...)
	if(event == "BARBER_SHOP_SUCCESS") then
		PlaySound("Barbershop_Haircut");
	end
	BarberShop_Update(self);
end

function BarberShop_UpdateCost()
	MoneyFrame_Update(BarberShopFrameMoneyFrame:GetName(), GetBarberShopTotalCost());
	-- The 4th return from GetBarberShopStyleInfo is whether the selected style is the active character style
	if ( select(4, GetBarberShopStyleInfo(1)) and select(4, GetBarberShopStyleInfo(2)) and select(4, GetBarberShopStyleInfo(3)) and ( not BarberShopFrameSelector4:IsShown() or select(4, GetBarberShopStyleInfo(4)) ) ) then
		BarberShopFrameOkayButton:Disable();
		BarberShopFrameResetButton:Disable();
	else
		BarberShopFrameOkayButton:Enable();
		BarberShopFrameResetButton:Enable();
	end
end

function BarberShop_UpdateBanner(name)
	if ( name ) then
		BarberShopBannerFrameCaption:SetText(name);
	end
end

function BarberShop_Update(self)
	BarberShop_UpdateCost();
	BarberShop_UpdateSelector(BarberShopFrameSelector4);
	BarberShop_UpdateSelector(BarberShopFrameSelector3);
	BarberShop_UpdateSelector(BarberShopFrameSelector2);
	BarberShop_UpdateSelector(BarberShopFrameSelector1);
end

function BarberShop_UpdateSelector(self)
	local name, _, _, isCurrent = GetBarberShopStyleInfo(self:GetID());
	BarberShop_UpdateBanner(name);
	local frameName = self:GetName();
	BarberShop_SetLabelColor(_G[frameName.."Category"], isCurrent);
end

function BarberShop_UpdateHairCustomization()
	local hairCustomization = GetHairCustomization();
	BarberShopFrameSelector1Category:SetText(_G["HAIR_"..hairCustomization.."_STYLE"]);
	BarberShopFrameSelector2Category:SetText(_G["HAIR_"..hairCustomization.."_COLOR"]);
end

function BarberShop_UpdateFacialHairCustomization()
	BarberShopFrameSelector3Category:SetText(_G["FACIAL_HAIR_"..GetFacialHairCustomization()]);
end

function BarberShop_SetLabelColor(label, isCurrent)
	if ( isCurrent ) then
		label:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	else
		label:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
end

function BarberShop_ResetLabelColors()
	BarberShop_SetLabelColor(BarberShopFrameSelector1Category, 1);
	BarberShop_SetLabelColor(BarberShopFrameSelector2Category, 1);
	BarberShop_SetLabelColor(BarberShopFrameSelector3Category, 1);
	BarberShop_SetLabelColor(BarberShopFrameSelector4Category, 1);
end

function BarberShop_ToFourAttributeFormat()
	BarberShopFrameSelector2:SetPoint("TOPLEFT", BarberShopFrameSelector1, "BOTTOMLEFT", 0, 3);
	BarberShopFrameSelector3:SetPoint("TOPLEFT", BarberShopFrameSelector2, "BOTTOMLEFT", 0, 3);
	BarberShopFrameSelector4:Show();
	BarberShopFrameMoneyFrame:SetPoint("TOP", BarberShopFrameSelector4, "BOTTOM", 7, -7);
	BarberShopFrameOkayButton:SetPoint("RIGHT", BarberShopFrameSelector4, "BOTTOM", -2, -36);
end
