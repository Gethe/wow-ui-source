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

-- NOTE: annoyingly, barbershop style enum and char customization enum are different
-- TODO: find a shared place for this with CharacterCreate.lua
CHAR_CUSTOMIZE_SKIN_COLOR = 1;
CHAR_CUSTOMIZE_FACE = 2;
CHAR_CUSTOMIZE_HAIR_STYLE = 3;
CHAR_CUSTOMIZE_HAIR_COLOR = 4;
CHAR_CUSTOMIZE_FACIAL_HAIR = 5;
CHAR_CUSTOMIZE_TATTOO_STYLE = 6;
CHAR_CUSTOMIZE_HORNS = 7;
CHAR_CUSTOMIZE_FACEWEAR = 8;
CHAR_CUSTOMIZE_TATTOO_COLOR = 9;

CHAR_CUSTOMIZE_CUSTOM_DISPLAY_FIRST = CHAR_CUSTOMIZE_TATTOO_STYLE;

function BarberShop_OnLoad(self)
	self:RegisterEvent("BARBER_SHOP_APPEARANCE_APPLIED");
	self:RegisterEvent("BARBER_SHOP_SUCCESS");
	self:RegisterEvent("BARBER_SHOP_COST_UPDATE")
	
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
	if ( C_Scenario.IsInScenario() ) then
		-- Only reason for using CONTAINER_OFFSET_X is to be consistent in spacing from edge
		self:SetPoint("LEFT", min(50, CONTAINER_OFFSET_X), -50);
	else
		self:SetPoint("RIGHT", min(-50, -CONTAINER_OFFSET_X), -50);
		ObjectiveTrackerFrame:Hide();
	end
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

	PlaySound(SOUNDKIT.BARBERSHOP_SIT);
end

function BarberShop_OnHide(self)
	BarberShopBannerFrame:Hide();

	ObjectiveTrackerFrame:Show();
end

function BarberShop_OnEvent(self, event, ...)
	if(event == "BARBER_SHOP_SUCCESS") then
		PlaySound(SOUNDKIT.BARBERSHOP_HAIRCUT);
	end
	if (self:IsShown()) then
		BarberShop_Update(self);
	end
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
	BarberShop_UpdateCustomizationOptions(self);
end

function BarberShop_UpdateSelector(self)
	local name, _, _, isCurrent = GetBarberShopStyleInfo(self:GetID());
	BarberShop_UpdateBanner(name);
	BarberShop_SetLabelColor(self.Category, isCurrent);
end

function BarberShop_UpdateCustomizationOptions(self)
	self.HairStyleSelector.Category:SetText(GetCustomizationDetails(CHAR_CUSTOMIZE_HAIR_STYLE));
	self.HairColorSelector.Category:SetText(GetCustomizationDetails(CHAR_CUSTOMIZE_HAIR_COLOR));
	self.FacialHairSelector.Category:SetText(GetCustomizationDetails(CHAR_CUSTOMIZE_FACIAL_HAIR));

	for i = 1, STYLE_NUM_CUSTOM_DISPLAY do
		local barberStyle = STYLE_CUSTOM_DISPLAY1 + i - 1;
		self.Selector[barberStyle]:SetShown(IsBarberShopStyleValid(barberStyle));

		local charCustomization = CHAR_CUSTOMIZE_CUSTOM_DISPLAY_FIRST + i - 1;
		self.Selector[barberStyle].Category:SetText(GetCustomizationDetails(charCustomization));
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
