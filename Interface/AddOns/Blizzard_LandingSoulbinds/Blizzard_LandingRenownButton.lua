LandingPageRenownButtonMixin = {};

function LandingPageRenownButtonMixin:OnEvent(event, ...)
	if event == "CURRENCY_DISPLAY_UPDATE" then
		self:OnCurrencyUpdate(...);
	end
end

function LandingPageRenownButtonMixin:OnShow()
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");

	self:UpdateRenownLevel();
	self:UpdateButtonTextures();
end

function LandingPageRenownButtonMixin:OnHide()
	self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
end

function LandingPageRenownButtonMixin:OnClick()
	ToggleCovenantRenown();
end

function LandingPageRenownButtonMixin:OnCurrencyUpdate(currencyType, quantity, delta, gainSource, lostSource)
	if currencyType == SOULBINDS_RENOWN_CURRENCY_ID then
		self:UpdateRenownLevel();
	end
end

function LandingPageRenownButtonMixin:UpdateRenownLevel()
	self.Renown:SetText(C_CovenantSanctumUI.GetRenownLevel());
end

function LandingPageRenownButtonMixin:UpdateButtonTextures()
	local covenantData = C_Covenants.GetCovenantData(C_Covenants.GetActiveCovenantID());
	self:SetNormalAtlas(("shadowlands-landingpage-renownbutton-%s"):format(covenantData.textureKit));
	self:SetPushedAtlas(("shadowlands-landingpage-renownbutton-%s"):format(covenantData.textureKit));
	self.PushedImage:SetAtlas(("shadowlands-landingpage-renownbutton-%s-down"):format(covenantData.textureKit));
end

function LandingPageRenownButtonMixin:OnMouseDown()
	self.PushedImage:Show();
end

function LandingPageRenownButtonMixin:OnMouseUp()
	self.PushedImage:Hide();
end