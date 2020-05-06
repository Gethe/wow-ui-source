BarberShopMixin = CreateFromMixins(CharCustomizeParentFrameBaseMixin);

function BarberShopMixin:OnLoad()
	self:RegisterEvent("BARBER_SHOP_RESULT");
	self:RegisterEvent("BARBER_SHOP_COST_UPDATE");

	CharCustomizeFrame:AttachToParentFrame(self);
end

function BarberShopMixin:OnEvent(event, ...)
	if event == "BARBER_SHOP_RESULT" then
		local success = ...;
		if success then
			PlaySound(SOUNDKIT.BARBERSHOP_HAIRCUT);
		end
		self:UpdateCharCustomizationFrame();
	elseif event == "BARBER_SHOP_COST_UPDATE" then
		self:UpdatePrice();
	end
end

function BarberShopMixin:OnShow()
	self.oldErrorFramePointInfo = {UIErrorsFrame:GetPoint()};

	UIErrorsFrame:SetParent(self);
	UIErrorsFrame:SetFrameStrata("DIALOG");
	UIErrorsFrame:SetPoint("TOP", self.Banner, "BOTTOM", 0, 0);

	self:SetScale(UIParent:GetScale());

	local reset = true;
	self:UpdateCharCustomizationFrame(reset);

	PlaySound(SOUNDKIT.BARBERSHOP_SIT);
end

function BarberShopMixin:OnHide()
	UIErrorsFrame:SetParent(UIParent);
	UIErrorsFrame:SetFrameStrata("DIALOG");
	UIErrorsFrame:SetPoint(unpack(self.oldErrorFramePointInfo));
end

function BarberShopMixin:OnKeyDown(key)
	if key == "ESCAPE" then
		C_BarberShop.Cancel();
	end
end

function BarberShopMixin:Reset()
	C_BarberShop.ResetCustomizationChoices();
	self:UpdateCharCustomizationFrame();
end

function BarberShopMixin:ApplyChanges()
	C_BarberShop.ApplyCustomizationChoices();
end

function BarberShopMixin:UpdatePrice()
	self.PriceFrame:SetAmount(C_BarberShop.GetCurrentCost());
end

function BarberShopMixin:UpdateCharCustomizationFrame(alsoReset)
	local customizationCategoryData = C_BarberShop.GetAvailableCustomizations();
	if not customizationCategoryData then
		-- This means we are calling GetAvailableCustomizations when there is no character component set up. Do nothing
		return;
	end

	if alsoReset then
		CharCustomizeFrame:Reset();
	end

	CharCustomizeFrame:SetCustomizations(customizationCategoryData);

	self:UpdatePrice();
end

function BarberShopMixin:SetCustomizationChoice(optionID, choiceID)
	C_BarberShop.SetCustomizationChoice(optionID, choiceID);

	-- When a customization choice is made, that may force other options to change (if the current choices are no longer valid)
	-- So grab all the latest data and update CharCustomizationFrame
	self:UpdateCharCustomizationFrame();
end

function BarberShopMixin:PreviewCustomizationChoice(optionID, choiceID)
	-- It is important that we DON'T call UpdateCharCustomizationFrame here because we want to keep the current selections
	C_BarberShop.SetCustomizationChoice(optionID, choiceID);
end

BarberShopButtonMixin = {};

function BarberShopButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if self.barberShopOnClickMethod then
		BarberShopFrame[self.barberShopOnClickMethod](BarberShopFrame);
	elseif self.barberShopFunction then
		C_BarberShop[self.barberShopFunction]();
	end
end
