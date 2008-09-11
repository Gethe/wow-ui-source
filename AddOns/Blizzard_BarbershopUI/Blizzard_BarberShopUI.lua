function BarberShop_OnLoad(self)
	BarberShop_UpdateHairCustomization();
	BarberShop_UpdateFacialHairCustomization();
	self:RegisterEvent("BARBER_SHOP_APPEARANCE_APPLIED");
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
	
	QuestWatchFrame:Hide();
	AchievementWatchFrame:Hide();
end

function BarberShop_OnHide(self)
	BarberShopBannerFrame:Hide();
	QuestWatch_Update();
	AchievementWatch_Update();
end

function BarberShop_OnEvent(self, event, ...)
	if(event == "BARBER_SHOP_APPEARANCE_APPLIED") then
		BarberShop_UpdateCost();
	end
end

function BarberShop_UpdateCost()
	MoneyFrame_Update(BarberShopFrameMoneyFrame:GetName(), GetBarberShopTotalCost());
end

function BarberShop_UpdateBanner(name)
	if ( name ) then
		BarberShopBannerFrameCaption:SetText(name);
	end
end

function BarberShop_Update(self)
	BarberShop_UpdateCost();
	local name, _, _, isCurrent = GetBarberShopStyleInfo(self:GetParent():GetID());
	BarberShop_UpdateBanner(name);
	BarberShop_SetLabelColor(getglobal(self:GetParent():GetName().."Category"), isCurrent);
end

function BarberShop_UpdateHairCustomization()
	BarberShopFrameSelector1Category:SetText(getglobal("HAIR_"..GetHairCustomization().."_STYLE"));
	BarberShopFrameSelector2Category:SetText(getglobal("HAIR_"..GetHairCustomization().."_COLOR"));
end

function BarberShop_UpdateFacialHairCustomization()
	BarberShopFrameSelector3Category:SetText(getglobal("FACIAL_HAIR_"..GetFacialHairCustomization()));		
end

function BarberShop_SetLabelColor(label, isCurrent)
	if ( isCurrent ) then
		label:SetVertexColor(1, 1, 1);
	else
		label:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
end

function BarberShop_ResetLabelColors()
	BarberShop_SetLabelColor(BarberShopFrameSelector1Category, 1);
	BarberShop_SetLabelColor(BarberShopFrameSelector2Category, 1);
	BarberShop_SetLabelColor(BarberShopFrameSelector3Category, 1);
end
