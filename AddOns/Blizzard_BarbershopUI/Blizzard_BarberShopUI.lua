function BarberShop_OnLoad(self)
	BarberShop_UpdateHairCustomization();
	BarberShop_UpdateFacialHairCustomization();
	self:RegisterEvent("BARBER_SHOP_APPEARANCE_APPLIED");
end

function BarberShop_OnShow(self)
	BarberShop_UpdateCost();
	if ( BarberShopBannerFrame ) then
		BarberShopBannerFrame:Show();
	end
	self:ClearAllPoints();
	self:SetPoint("RIGHT", min(-50, -CONTAINER_OFFSET_X), -50);
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
	 local name = GetBarberShopStyleInfo(self:GetParent():GetID());
	 BarberShop_UpdateBanner(name);
end

function BarberShop_UpdateHairCustomization()
	BarberShopFrameSelector1Category:SetText(getglobal("HAIR_"..GetHairCustomization().."_STYLE"));
	BarberShopFrameSelector2Category:SetText(getglobal("HAIR_"..GetHairCustomization().."_COLOR"));
end

function BarberShop_UpdateFacialHairCustomization()
	BarberShopFrameSelector3Category:SetText(getglobal("FACIAL_HAIR_"..GetFacialHairCustomization()));		
end

