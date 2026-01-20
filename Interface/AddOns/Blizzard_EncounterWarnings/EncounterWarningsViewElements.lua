EncounterWarningsViewElementMixin = {};

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

	self:SetIconTexture(encounterWarningInfo.iconFileID);
	self:SetDeadlyOverlayShown(encounterWarningInfo.isDeadly);
end

function EncounterWarningsIconElementMixin:Reset()
	EncounterWarningsViewElementMixin.Reset(self);
	self:SetIconTexture(nil);
	self:SetDeadlyOverlayShown(false);
end

function EncounterWarningsIconElementMixin:SetIconTexture(iconFileAsset)
	self.Icon:SetTexture(iconFileAsset);
end

function EncounterWarningsIconElementMixin:SetDeadlyOverlayShown(isDeadly)
	self.NormalOverlay:SetShown(not isDeadly);
	self.DeadlyOverlay:SetShown(isDeadly);
	self.DeadlyOverlayGlow:SetShown(isDeadly);
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

	local maximumTextSize = EncounterWarningsUtil.GetMaximumTextSizeForSeverity(encounterWarningInfo.severity);
	local textFontObject = EncounterWarningsUtil.GetFontObjectForSeverity(encounterWarningInfo.severity);
	local textColor = EncounterWarningsUtil.GetTextColorForSeverity(encounterWarningInfo.severity);

	self:SetFontObject(textFontObject);
	self:SetTextColor(textColor:GetRGB());
	self:SetTextScale(1);
	self:SetTextToFit(encounterWarningInfo.text);
	self:SetHeight(maximumTextSize.height);

	if self:GetStringWidth() > maximumTextSize.width then
		self:SetWidth(maximumTextSize.width);
		self:ScaleTextToFit();
	end
end

function EncounterWarningsTextElementMixin:Reset()
	EncounterWarningsViewElementMixin.Reset(self);
	self:SetText("");
end
