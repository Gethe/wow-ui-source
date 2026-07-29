EncounterWarningsSettingsMixin = {};

function EncounterWarningsSettingsMixin:OnLoad()
	self.iconScale = EncounterWarningsSettingDefaults.IconScale;
	self.tooltipAnchor = EncounterWarningsSettingDefaults.TooltipAnchor;
end

function EncounterWarningsSettingsMixin:OnIconScaleChanged(_iconScale)
	-- Override in a derived mixin.
end

function EncounterWarningsSettingsMixin:OnTooltipAnchorChanged(_tooltipAnchor)
	-- Override in a derived mixin.
end

function EncounterWarningsSettingsMixin:GetIconScale()
	return self.iconScale;
end

function EncounterWarningsSettingsMixin:GetTooltipAnchor()
	return self.tooltipAnchor;
end

function EncounterWarningsSettingsMixin:SetIconScale(iconScale)
	if self.iconScale ~= iconScale then
		self.iconScale = iconScale;
		self:OnIconScaleChanged(iconScale);
	end
end

function EncounterWarningsSettingsMixin:SetTooltipAnchor(tooltipAnchor)
	if self.tooltipAnchor ~= tooltipAnchor then
		self.tooltipAnchor = tooltipAnchor;
		self:OnTooltipAnchorChanged(tooltipAnchor);
	end
end
