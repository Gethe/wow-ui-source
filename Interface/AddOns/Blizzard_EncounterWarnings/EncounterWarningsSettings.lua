EncounterWarningsSettingsMixin = {};

function EncounterWarningsSettingsMixin:OnLoad()
	self.iconScale = EncounterWarningsSettingDefaults.IconScale;
	self.tooltipsEnabled = EncounterWarningsSettingDefaults.TooltipsEnabled;
end

function EncounterWarningsSettingsMixin:OnIconScaleChanged(_iconScale)
	-- Override in a derived mixin.
end

function EncounterWarningsSettingsMixin:OnTooltipsEnabledChanged(_tooltipsEnabled)
	-- Override in a derived mixin.
end

function EncounterWarningsSettingsMixin:GetIconScale()
	return self.iconScale;
end

function EncounterWarningsSettingsMixin:GetTooltipsEnabled()
	return self.tooltipsEnabled == true;
end

function EncounterWarningsSettingsMixin:SetIconScale(iconScale)
	assert(type(iconScale) == "number", "SetIconScale: 'iconScale' must be a number");
	assert(iconScale > 0, "SetIconScale: 'iconScale' must be > 0");

	if not ApproximatelyEqual(self:GetIconScale(), iconScale) then
		self.iconScale = iconScale;
		self:OnIconScaleChanged(iconScale);
	end
end

function EncounterWarningsSettingsMixin:SetTooltipsEnabled(tooltipsEnabled)
	assert(type(tooltipsEnabled) == "boolean", "SetTooltipsEnabled: 'tooltipsEnabled' must be a boolean");

	if self:GetTooltipsEnabled() ~= tooltipsEnabled then
		self.tooltipsEnabled = tooltipsEnabled;
		self:OnTooltipsEnabledChanged(tooltipsEnabled);
	end
end
