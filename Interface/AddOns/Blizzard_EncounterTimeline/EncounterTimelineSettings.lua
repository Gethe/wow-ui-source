EncounterTimelineSettingsMixin = {};

function EncounterTimelineSettingsMixin:OnLoad()
	self.crossAxisExtent = EncounterTimelineSettingDefaults.CrossAxisExtent;
	self.crossAxisOffset = EncounterTimelineSettingDefaults.CrossAxisOffset;
	self.eventCountdownEnabled = EncounterTimelineSettingDefaults.EventCountdownEnabled;
	self.eventIconScale = EncounterTimelineSettingDefaults.EventIconScale;
	self.eventTextEnabled = EncounterTimelineSettingDefaults.EventTextEnabled;
	self.eventTooltipsEnabled = EncounterTimelineSettingDefaults.EventTooltipsEnabled;
	self.eventIndicatorIconMask = EncounterTimelineSettingDefaults.EventIndicatorIconMask;
	self.viewBackgroundAlpha = EncounterTimelineSettingDefaults.ViewBackgroundAlpha;
	self.viewOrientation = EncounterTimelineUtil.CreateOrientation(EncounterTimelineSettingDefaults.ViewOrientation, EncounterTimelineSettingDefaults.ViewDirection);
	self.pipDuration = EncounterTimelineSettingDefaults.PipDuration;
	self.pipIconShown = EncounterTimelineSettingDefaults.PipIconShown;
	self.pipTextAnchor = EncounterTimelineSettingDefaults.PipTextAnchor;
	self.pipTextShown = EncounterTimelineSettingDefaults.PipTextShown;
end

function EncounterTimelineSettingsMixin:OnCrossAxisExtentChanged(_crossAxisExtent)
	-- Implement in a derived mixin.
end

function EncounterTimelineSettingsMixin:OnCrossAxisOffsetChanged(_crossAxisOffset)
	-- Implement in a derived mixin.
end

function EncounterTimelineSettingsMixin:OnEventCountdownEnabledChanged(_countdownEnabled)
	-- Implement in a derived mixin.
end

function EncounterTimelineSettingsMixin:OnEventIconScaleChanged(_iconScale)
	-- Implement in a derived mixin.
end

function EncounterTimelineSettingsMixin:OnEventTextEnabledChanged(_textEnabled)
	-- Implement in a derived mixin.
end

function EncounterTimelineSettingsMixin:OnEventTooltipsEnabledChanged(_tooltipsEnabled)
	-- Implement in a derived mixin.
end

function EncounterTimelineSettingsMixin:OnEventIndicatorIconMaskChanged(_iconMask)
	-- Implement in a derived mixin.
end

function EncounterTimelineSettingsMixin:OnViewBackgroundAlphaChanged(_backgroundAlpha)
	-- Implement in a derived mixin.
end

function EncounterTimelineSettingsMixin:OnViewOrientationChanged(_viewOrientation)
	-- Implement in a derived mixin.
end

function EncounterTimelineSettingsMixin:OnPipDurationChanged(_pipDuration)
	-- Implement in a derived mixin.
end

function EncounterTimelineSettingsMixin:OnPipIconShownChanged(_pipIconShown)
	-- Implement in a derived mixin.
end

function EncounterTimelineSettingsMixin:OnPipTextAnchorChanged(_pipTextAnchor)
	-- Implement in a derived mixin.
end

function EncounterTimelineSettingsMixin:OnPipTextShownChanged(_pipTextShown)
	-- Implement in a derived mixin.
end

function EncounterTimelineSettingsMixin:GetCrossAxisExtent()
	return self.crossAxisExtent;
end

function EncounterTimelineSettingsMixin:GetCrossAxisOffset()
	return self.crossAxisOffset;
end

function EncounterTimelineSettingsMixin:GetEventCountdownEnabled()
	return self.eventCountdownEnabled == true;
end

function EncounterTimelineSettingsMixin:GetEventIconScale()
	return self.eventIconScale;
end

function EncounterTimelineSettingsMixin:GetEventTextEnabled()
	return self.eventTextEnabled == true;
end

function EncounterTimelineSettingsMixin:GetEventTooltipsEnabled()
	return self.eventTooltipsEnabled == true;
end

function EncounterTimelineSettingsMixin:GetEventIndicatorIconMask()
	return self.eventIndicatorIconMask;
end

function EncounterTimelineSettingsMixin:GetViewBackgroundAlpha()
	return self.viewBackgroundAlpha;
end

function EncounterTimelineSettingsMixin:GetViewOrientation()
	return self.viewOrientation;
end

function EncounterTimelineSettingsMixin:GetPipDuration()
	return self.pipDuration;
end

function EncounterTimelineSettingsMixin:GetPipIconShown()
	return self.pipIconShown == true;
end

function EncounterTimelineSettingsMixin:GetPipTextAnchor()
	return self.pipTextAnchor;
end

function EncounterTimelineSettingsMixin:GetPipTextShown()
	return self.pipTextShown == true;
end

function EncounterTimelineSettingsMixin:SetCrossAxisExtent(extent)
	assert(type(extent) == "number", "SetCrossAxisExtent: 'extent' must be a number");

	if not ApproximatelyEqual(self:GetCrossAxisExtent(), extent) then
		self.crossAxisExtent = extent;
		self:OnCrossAxisExtentChanged(extent);
	end
end

function EncounterTimelineSettingsMixin:SetCrossAxisOffset(offset)
	assert(type(offset) == "number", "SetCrossAxisOffset: 'offset' must be a number");

	if not ApproximatelyEqual(self:GetCrossAxisOffset(), offset) then
		self.crossAxisOffset = offset;
		self:OnCrossAxisOffsetChanged(offset);
	end
end

function EncounterTimelineSettingsMixin:SetEventCountdownEnabled(countdownEnabled)
	assert(type(countdownEnabled) == "boolean", "SetEventCountdownEnabled: 'countdownEnabled' must be a boolean");

	if self:GetEventCountdownEnabled() ~= countdownEnabled then
		self.eventCountdownEnabled = countdownEnabled;
		self:OnEventCountdownEnabledChanged(countdownEnabled);
	end
end

function EncounterTimelineSettingsMixin:SetEventIconScale(iconScale)
	assert(type(iconScale) == "number", "SetEventIconScale: 'iconScale' must be a number");
	assert(iconScale > 0);

	if not ApproximatelyEqual(self:GetEventIconScale(), iconScale) then
		self.eventIconScale = iconScale;
		self:OnEventIconScaleChanged(iconScale);
	end
end

function EncounterTimelineSettingsMixin:SetEventTextEnabled(textEnabled)
	assert(type(textEnabled) == "boolean", "SetEventTextEnabled: 'textEnabled' must be a boolean");

	if self:GetEventTextEnabled() ~= textEnabled then
		self.eventTextEnabled = textEnabled;
		self:OnEventTextEnabledChanged(textEnabled);
	end
end

function EncounterTimelineSettingsMixin:SetEventTooltipsEnabled(tooltipsEnabled)
	assert(type(tooltipsEnabled) == "boolean", "SetEventTooltipsEnabled: 'tooltipsEnabled' must be a boolean");

	if self:GetEventTooltipsEnabled() ~= tooltipsEnabled then
		self.eventTooltipsEnabled = tooltipsEnabled;
		self:OnEventTooltipsEnabledChanged(tooltipsEnabled);
	end
end

function EncounterTimelineSettingsMixin:SetEventIndicatorIconMask(iconMask)
	assert(type(iconMask) == "number", "SetEventIndicatorIconMask: 'iconMask' must be a bitmask");

	if self:GetEventIndicatorIconMask() ~= iconMask then
		self.eventIndicatorIconMask = iconMask;
		self:OnEventIndicatorIconMaskChanged(iconMask);
	end
end

function EncounterTimelineSettingsMixin:SetViewBackgroundAlpha(backgroundAlpha)
	assert(type(backgroundAlpha) == "number", "SetViewBackgroundAlpha: 'backgroundAlpha' must be a number");
	assert(backgroundAlpha >= 0 and backgroundAlpha <= 1);

	if not ApproximatelyEqual(self:GetViewBackgroundAlpha(), backgroundAlpha) then
		self.viewBackgroundAlpha = backgroundAlpha;
		self:OnViewBackgroundAlphaChanged(backgroundAlpha);
	end
end

function EncounterTimelineSettingsMixin:SetViewOrientation(orientation)
	-- Skipping non-trivial assert; 'orientation' should be an EncounterTimelineOrientationMixin.
	-- As we can't trivially compare, setting always invokes the on-change func.

	self.viewOrientation = orientation;
	self:OnViewOrientationChanged(orientation);
end

function EncounterTimelineSettingsMixin:SetPipDuration(pipDuration)
	assert(type(pipDuration) == "number", "SetPipDuration: 'pipDuration' must be a number");

	if self:GetPipDuration() ~= pipDuration then
		self.pipDuration = pipDuration;
		self:OnPipDurationChanged(pipDuration);
	end
end

function EncounterTimelineSettingsMixin:SetPipIconShown(pipIconShown)
	assert(type(pipIconShown) == "boolean", "SetPipIconShown: 'pipIconShown' must be a boolean");

	if self:GetPipIconShown() ~= pipIconShown then
		self.pipIconShown = pipIconShown;
		self:OnPipIconShownChanged(pipIconShown);
	end
end

function EncounterTimelineSettingsMixin:SetPipTextAnchor(pipTextAnchor)
	assert(type(pipTextAnchor) == "table", "SetPipTextAnchor: 'pipTextAnchor' must be an anchor description");
	assert(type(pipTextAnchor.point) == "string", "SetPipTextAnchor: 'pipTextAnchor' must be an anchor description");
	assert(type(pipTextAnchor.relativePoint) == "string", "SetPipTextAnchor: 'pipTextAnchor' must be an anchor description");
	assert(type(pipTextAnchor.x) == "number", "SetPipTextAnchor: 'pipTextAnchor' must be an anchor description");
	assert(type(pipTextAnchor.y) == "number", "SetPipTextAnchor: 'pipTextAnchor' must be an anchor description");

	self.pipTextAnchor = pipTextAnchor;
	self:OnPipTextAnchorChanged(pipTextAnchor);
end

function EncounterTimelineSettingsMixin:SetPipTextShown(pipTextShown)
	assert(type(pipTextShown) == "boolean", "SetPipTextShown: 'pipTextShown' must be a boolean");

	if self:GetPipTextShown() ~= pipTextShown then
		self.pipTextShown = pipTextShown;
		self:OnPipTextShownChanged(pipTextShown);
	end
end
