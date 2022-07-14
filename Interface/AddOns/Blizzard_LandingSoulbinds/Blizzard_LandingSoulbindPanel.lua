LandingPageSoulbindPanelMixin = {};

function LandingPageSoulbindPanelMixin:Update()
	local showRenown = self:UpdateRenown();
	local showSoulbind = self:UpdateSoulbind();
	self:SetShown(showRenown or showSoulbind);
	self:Layout();
end

function LandingPageSoulbindPanelMixin:UpdateRenown()
	local displayRenownLevel = C_Covenants.GetActiveCovenantID() ~= 0;
	self.RenownButton:SetShown(displayRenownLevel);

	self.RenownButton:ClearAllPoints();
	self.RenownButton:SetPoint("TOP", self.Spacer, "BOTTOM");

	return displayRenownLevel;
end

function LandingPageSoulbindPanelMixin:UpdateSoulbind()
	local displaySoulbind = C_Soulbinds.GetActiveSoulbindID() > 0;
	self.SoulbindButton:SetShown(displaySoulbind);

	self.SoulbindButton:ClearAllPoints();
	self.SoulbindButton:SetPoint("TOP", self.RenownButton, "BOTTOM", 0, -5);

	return displaySoulbind;
end

LandingSoulbind = {};

function LandingSoulbind.Create(parent)
	return CreateFrame("Frame", nil, parent, "LandingPageSoulbindPanelTemplate");
end