STYLE_HAIR_STYLE = 1;
STYLE_HAIR_COLOR = 2;
STYLE_FACIAL_HAIR = 3;
STYLE_SKIN = 4;
STYLE_FACE = 5;
STYLE_CUSTOM_DISPLAY1 = 6;
STYLE_CUSTOM_DISPLAY2 = 7;
STYLE_CUSTOM_DISPLAY3 = 8;
STYLE_CUSTOM_DISPLAY4 = 9;
STYLE_NUM_CUSTOM_DISPLAY = 4;

function BarberShop_OnLoad(self)
	BarberShop_UpdateHairCustomization(self);
	BarberShop_UpdateFacialHairCustomization(self);
	self:RegisterEvent("BARBER_SHOP_APPEARANCE_APPLIED");
	self:RegisterEvent("BARBER_SHOP_SUCCESS");
	
	if ( IsBarberShopStyleValid(STYLE_SKIN) ) then
		if ( IsBarberShopStyleValid(STYLE_HAIR_COLOR) ) then
			-- tauren, worgen, female pandaren
			self.SkinColorSelector:Show();
		else
			-- male pandaren
			self.HairColorSelector:Hide();
			self.SkinColorSelector:Show();
		end
	end
	
	BarberShop_UpdateCustomDisplays(self)
end

function BarberShop_OnShow(self)
	CloseAllBags();
	BarberShop_ResetLabelColors();
	BarberShop_UpdateCost(self);
	if ( BarberShopBannerFrame ) then
		BarberShopBannerFrame:Show();
		BarberShopBannerFrame.caption:SetText(BARBERSHOP);
	end
	self:ClearAllPoints();
	self:SetPoint("RIGHT", min(-50, -CONTAINER_OFFSET_X), -50);
	if ( HasAlternateForm() ) then
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
		SetBarberShopAlternateFormFrame("BarberShopAltFormFrame");
	else
		BarberShopAltFormFrame:Hide();
	end

	PlaySound("BarberShop_Sit");
	
	ObjectiveTrackerFrame:Hide();
end

function BarberShop_OnHide(self)
	BarberShopBannerFrame:Hide();

	ObjectiveTrackerFrame:Show();
end

function BarberShop_OnEvent(self, event, ...)
	if(event == "BARBER_SHOP_SUCCESS") then
		PlaySound("Barbershop_Haircut");
	end
	BarberShop_Update(self);
end

function BarberShop_UpdateCost(self)
	MoneyFrame_Update(BarberShopFrameMoneyFrame:GetName(), GetBarberShopTotalCost());
	-- The 4th return from GetBarberShopStyleInfo is whether the selected style is the active character style
	-- Enable the okay and reset buttons if anything has changed
	for i=1, #self.Selector do
		if ( self.Selector[i]:IsShown() ) then
			if ( not select(4, GetBarberShopStyleInfo( self.Selector[i]:GetID() ) ) ) then
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

function BarberShop_Update(self)
	BarberShop_UpdateCost(self);
	for i=1, #self.Selector do
		BarberShop_UpdateSelector(self.Selector[i]);
	end
end

function BarberShop_UpdateSelector(self)
	local name, _, _, isCurrent = GetBarberShopStyleInfo(self:GetID());
	BarberShop_UpdateBanner(name);
	BarberShop_SetLabelColor(self.Category, isCurrent);
	BarberShop_UpdateCustomDisplays(self:GetParent());
end

function BarberShop_UpdateHairCustomization(self)
	local hairCustomization = GetHairCustomization();
	self.HairStyleSelector.Category:SetText(_G["HAIR_"..hairCustomization.."_STYLE"]);
	self.HairColorSelector.Category:SetText(_G["HAIR_"..hairCustomization.."_COLOR"]);
end

function BarberShop_UpdateFacialHairCustomization(self)
	self.FacialHairSelector.Category:SetText(_G["FACIAL_HAIR_"..GetFacialHairCustomization()]);
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

function BarberShop_UpdateCustomDisplays(self)
	for i = STYLE_CUSTOM_DISPLAY1, (STYLE_CUSTOM_DISPLAY1 + STYLE_NUM_CUSTOM_DISPLAY - 1) do
		self.Selector[i]:SetShown(IsBarberShopStyleValid(i));
	end
	self:Layout();
end