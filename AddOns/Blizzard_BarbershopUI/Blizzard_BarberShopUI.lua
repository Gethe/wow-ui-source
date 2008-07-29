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

