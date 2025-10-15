EncounterWarningsViewElementMixin = CreateFromMixins(EncounterWarningsViewSettingsAccessorMixin);

function EncounterWarningsViewElementMixin:Init(encounterWarningInfo, parentView)
	self.parentView = parentView;
	self.currentWarningInfo = encounterWarningInfo;
end

function EncounterWarningsViewElementMixin:Reset()
	self.currentWarningInfo = nil;
	self.parentView = nil;
end

function EncounterWarningsViewElementMixin:GetView()
	return self.parentView;
end

function EncounterWarningsViewElementMixin:GetViewSetting(setting)
	return self:GetView():GetViewSetting(setting);
end

function EncounterWarningsViewElementMixin:GetCurrentWarning()
	return self.currentWarningInfo;
end

function EncounterWarningsViewElementMixin:GetCurrentSeverity()
	local currentWarningInfo = self:GetCurrentWarning();
	return currentWarningInfo and currentWarningInfo.severity or nil;
end

EncounterWarningsSwingAnimationGroupMixin = CreateFromMixins(EncounterWarningsViewElementMixin);

EncounterWarningsIconElementMixin = CreateFromMixins(EncounterWarningsViewElementMixin);

function EncounterWarningsIconElementMixin:Init(encounterWarningInfo, parentView)
	EncounterWarningsViewElementMixin.Init(self, encounterWarningInfo, parentView);

	self:SetMouseClickEnabled(false);
	self:SetIconTexture(encounterWarningInfo.iconFileID);
	self:SetDeadlyOverlayShown(encounterWarningInfo.isDeadly);
end

function EncounterWarningsIconElementMixin:OnEnter()
	local shouldShowTooltip = EncounterWarningsViewSettings.AreTooltipsEnabled(self);
	self:SetTooltipShown(shouldShowTooltip);
end

function EncounterWarningsIconElementMixin:OnLeave()
	self:SetTooltipShown(false);
end

function EncounterWarningsIconElementMixin:Reset()
	EncounterWarningsViewElementMixin.Reset(self);
	self:SetIconTexture(nil);
	self:SetDeadlyOverlayShown(false);
end

function EncounterWarningsIconElementMixin:GetTooltipFrame()
	return self.tooltipFrame or GameTooltip;
end

function EncounterWarningsIconElementMixin:SetIconTexture(iconFileAsset)
	self.Icon:SetTexture(iconFileAsset);
end

function EncounterWarningsIconElementMixin:SetDeadlyOverlayShown(isDeadly)
	self.NormalOverlay:SetShown(not isDeadly);
	self.DeadlyOverlay:SetShown(isDeadly);
	self.DeadlyOverlayGlow:SetShown(isDeadly);
end

function EncounterWarningsIconElementMixin:SetTooltipShown(shown)
	local tooltip = self:GetTooltipFrame();
	local encounterWarningInfo = self:GetCurrentWarning();

	if shown and encounterWarningInfo ~= nil and encounterWarningInfo.tooltipSpellID ~= nil then
		GameTooltip_SetDefaultAnchor(tooltip, self);
		tooltip:SetSpellByID(encounterWarningInfo.tooltipSpellID);
	elseif tooltip:IsOwned(self) then
		tooltip:Hide();
	end
end

EncounterWarningsTextElementMixin = CreateFromMixins(EncounterWarningsViewElementMixin, AutoScalingFontStringMixin);

function EncounterWarningsTextElementMixin:Init(encounterWarningInfo, parentView)
	EncounterWarningsViewElementMixin.Init(self, encounterWarningInfo, parentView);

	-- Attempt to display the text at the default scale and automatically
	-- sized first. If the width of the string exceeds what we'd like, clamp
	-- the size of the region and re-scale the text to fit.
	--
	-- The reason for not just enforcing a static width is that we don't want
	-- small alert messages to have their icons anchored too far away.

	local maximumTextHeight = EncounterWarningsViewSettings.GetMaximumTextHeight(self, encounterWarningInfo.severity);
	local maximumTextWidth = EncounterWarningsViewSettings.GetMaximumTextWidth(self, encounterWarningInfo.severity);
	local textFontObject = EncounterWarningsViewSettings.GetTextFontObject(self, encounterWarningInfo.severity);
	local textColor = EncounterWarningsViewSettings.GetTextColor(self, encounterWarningInfo.severity);

	self:SetFontObject(textFontObject);
	self:SetTextColor(textColor:GetRGB());
	self:SetTextScale(1);
	self:SetTextToFit(encounterWarningInfo.text);
	self:SetHeight(maximumTextHeight);

	if self:GetStringWidth() > maximumTextWidth then
		self:SetWidth(maximumTextWidth);
		self:ScaleTextToFit();
	end
end

function EncounterWarningsTextElementMixin:Reset()
	EncounterWarningsViewElementMixin.Reset(self);
	self:SetText("");
end
