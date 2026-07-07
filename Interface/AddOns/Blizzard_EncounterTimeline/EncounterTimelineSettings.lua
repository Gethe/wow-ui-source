-- Settings common to all view types and event frames.

EncounterTimelineSettingsMixin = {};

function EncounterTimelineSettingsMixin:OnLoad()
	self.flipHorizontally = EncounterTimelineSettingDefaults.FlipHorizontally;
	self.highlightTime = EncounterTimelineSettingDefaults.HighlightTime;
	self.iconScale = EncounterTimelineSettingDefaults.IconScale;
	self.indicatorIconMask = EncounterTimelineSettingDefaults.IndicatorIconMask;
	self.showCountdown = EncounterTimelineSettingDefaults.ShowCountdown;
	self.showText = EncounterTimelineSettingDefaults.ShowText;
	self.tooltipAnchor = EncounterTimelineSettingDefaults.TooltipAnchor;
end

function EncounterTimelineSettingsMixin:OnFlipHorizontallyChanged(_flipHorizontally)
	-- Implement in a derived mixin.
end

function EncounterTimelineSettingsMixin:OnHighlightTimeChanged(_highlightTime)
	-- Implement in a derived mixin.
end

function EncounterTimelineSettingsMixin:OnIconScaleChanged(_iconScale)
	-- Implement in a derived mixin.
end

function EncounterTimelineSettingsMixin:OnIndicatorIconMaskChanged(_indicatorIconMask)
	-- Implement in a derived mixin.
end

function EncounterTimelineSettingsMixin:OnShowCountdownChanged(_showCountdown)
	-- Implement in a derived mixin.
end

function EncounterTimelineSettingsMixin:OnShowTextChanged(_showText)
	-- Implement in a derived mixin.
end

function EncounterTimelineSettingsMixin:OnTooltipAnchorChanged(_tooltipAnchor)
	-- Implement in a derived mixin.
end

function EncounterTimelineSettingsMixin:GetHighlightTime()
	return self.highlightTime;
end

function EncounterTimelineSettingsMixin:GetIconScale()
	return self.iconScale;
end

function EncounterTimelineSettingsMixin:GetIndicatorIconMask()
	return self.indicatorIconMask;
end

function EncounterTimelineSettingsMixin:GetTooltipAnchor()
	return self.tooltipAnchor;
end

function EncounterTimelineSettingsMixin:ShouldShowCountdown()
	return self.showCountdown == true;
end

function EncounterTimelineSettingsMixin:ShouldFlipHorizontally()
	return self.flipHorizontally == true;
end

function EncounterTimelineSettingsMixin:ShouldShowText()
	return self.showText == true;
end

function EncounterTimelineSettingsMixin:SetFlipHorizontally(flipHorizontally)
	if self.flipHorizontally ~= flipHorizontally then
		self.flipHorizontally = flipHorizontally;
		self:OnFlipHorizontallyChanged(flipHorizontally);
	end
end

function EncounterTimelineSettingsMixin:SetHighlightTime(highlightTime)
	if self.highlightTime ~= highlightTime then
		self.highlightTime = highlightTime;
		self:OnHighlightTimeChanged(highlightTime);
	end
end

function EncounterTimelineSettingsMixin:SetIconScale(iconScale)
	if self.iconScale ~= iconScale then
		self.iconScale = iconScale;
		self:OnIconScaleChanged(iconScale);
	end
end

function EncounterTimelineSettingsMixin:SetIndicatorIconMask(indicatorIconMask)
	if self.indicatorIconMask ~= indicatorIconMask then
		self.indicatorIconMask = indicatorIconMask;
		self:OnIndicatorIconMaskChanged(indicatorIconMask);
	end
end

function EncounterTimelineSettingsMixin:SetShowCountdown(showCountdown)
	if self.showCountdown ~= showCountdown then
		self.showCountdown = showCountdown;
		self:OnShowCountdownChanged(showCountdown);
	end
end

function EncounterTimelineSettingsMixin:SetShowText(showText)
	if self.showText ~= showText then
		self.showText = showText;
		self:OnShowTextChanged(showText);
	end
end

function EncounterTimelineSettingsMixin:SetTooltipAnchor(tooltipAnchor)
	if self.tooltipAnchor ~= tooltipAnchor then
		self.tooltipAnchor = tooltipAnchor;
		self:OnTooltipAnchorChanged(tooltipAnchor);
	end
end

-- Settings common to all view types, but not event frames.

EncounterTimelineViewSettingsMixin = CreateFromMixins(EncounterTimelineSettingsMixin);

function EncounterTimelineViewSettingsMixin:OnLoad()
	EncounterTimelineSettingsMixin.OnLoad(self);

	self.backgroundAlpha = EncounterTimelineViewSettingDefaults.BackgroundAlpha;
end

function EncounterTimelineViewSettingsMixin:OnBackgroundAlphaChanged(_backgroundAlpha)
	-- Implement in a derived mixin.
end

function EncounterTimelineViewSettingsMixin:GetBackgroundAlpha()
	return self.backgroundAlpha;
end

function EncounterTimelineViewSettingsMixin:SetBackgroundAlpha(backgroundAlpha)
	if self.backgroundAlpha ~= backgroundAlpha then
		self.backgroundAlpha = backgroundAlpha;
		self:OnBackgroundAlphaChanged(backgroundAlpha);
	end
end

-- Settings shared between track views and event frames.

EncounterTimelineTrackSettingsMixin = {};

function EncounterTimelineTrackSettingsMixin:OnLoad()
	self.crossAxisOffset = EncounterTimelineTrackSettingDefaults.CrossAxisOffset;
	self.trackOrientation = EncounterTimelineUtil.CreateTrackOrientation(EncounterTimelineTrackSettingDefaults.Orientation, EncounterTimelineTrackSettingDefaults.IconDirection);
end

function EncounterTimelineTrackSettingsMixin:OnCrossAxisOffsetChanged(_crossAxisOffset)
	-- Implement in a derived mixin.
end

function EncounterTimelineTrackSettingsMixin:OnTrackOrientationChanged(_trackOrientation)
	-- Implement in a derived mixin.
end

function EncounterTimelineTrackSettingsMixin:GetCrossAxisOffset()
	return self.crossAxisOffset;
end

function EncounterTimelineTrackSettingsMixin:GetTrackOrientation()
	return self.trackOrientation;
end

function EncounterTimelineTrackSettingsMixin:SetCrossAxisOffset(offset)
	if self.crossAxisOffset ~= offset then
		self.crossAxisOffset = offset;
		self:OnCrossAxisOffsetChanged(offset);
	end
end

function EncounterTimelineTrackSettingsMixin:SetTrackOrientation(orientation)
	if self.trackOrientation ~= orientation then
		self.trackOrientation = orientation;
		self:OnTrackOrientationChanged(orientation);
	end
end

-- Settings specific to track views.

EncounterTimelineTrackViewSettingsMixin = CreateFromMixins(EncounterTimelineTrackSettingsMixin);

function EncounterTimelineTrackViewSettingsMixin:OnLoad()
	EncounterTimelineTrackSettingsMixin.OnLoad(self);

	self.crossAxisExtent = EncounterTimelineTrackViewSettingDefaults.CrossAxisExtent;
	self.pipTextAnchor = EncounterTimelineTrackViewSettingDefaults.PipTextAnchor;
	self.showPipIcon = EncounterTimelineTrackViewSettingDefaults.ShowPipIcon;
	self.showPipText = EncounterTimelineTrackViewSettingDefaults.ShowPipText;
end

function EncounterTimelineTrackViewSettingsMixin:OnCrossAxisExtentChanged(_crossAxisExtent)
	-- Implement in a derived mixin.
end

function EncounterTimelineTrackViewSettingsMixin:OnPipTextAnchorChanged(_pipTextAnchor)
	-- Implement in a derived mixin.
end

function EncounterTimelineTrackViewSettingsMixin:OnShowPipIconChanged(_showPipIcon)
	-- Implement in a derived mixin.
end

function EncounterTimelineTrackViewSettingsMixin:OnShowPipTextChanged(_showPipText)
	-- Implement in a derived mixin.
end

function EncounterTimelineTrackViewSettingsMixin:GetCrossAxisExtent()
	return self.crossAxisExtent;
end

function EncounterTimelineTrackViewSettingsMixin:GetPipTextAnchor()
	return self.pipTextAnchor;
end

function EncounterTimelineTrackViewSettingsMixin:ShouldShowPipIcon()
	return self.showPipIcon == true;
end

function EncounterTimelineTrackViewSettingsMixin:ShouldShowPipText()
	return self.showPipText == true;
end

function EncounterTimelineTrackViewSettingsMixin:SetCrossAxisExtent(extent)
	if self.crossAxisExtent ~= extent then
		self.crossAxisExtent = extent;
		self:OnCrossAxisExtentChanged(extent);
	end
end

function EncounterTimelineTrackViewSettingsMixin:SetPipTextAnchor(pipTextAnchor)
	self.pipTextAnchor = pipTextAnchor;
	self:OnPipTextAnchorChanged(pipTextAnchor);
end

function EncounterTimelineTrackViewSettingsMixin:SetShowPipIcon(showPipIcon)
	if self.showPipIcon ~= showPipIcon then
		self.showPipIcon = showPipIcon;
		self:OnShowPipIconChanged(showPipIcon);
	end
end

function EncounterTimelineTrackViewSettingsMixin:SetShowPipText(showPipText)
	if self.showPipText ~= showPipText then
		self.showPipText = showPipText;
		self:OnShowPipTextChanged(showPipText);
	end
end

-- Settings shared between timer views and event frames.

EncounterTimelineTimerSettingsMixin = {};

function EncounterTimelineTimerSettingsMixin:OnLoad()
	self.showIcon = EncounterTimelineTimerSettingDefaults.ShowIcon;
	self.showTimerSpark = EncounterTimelineTimerSettingDefaults.ShowTimerSpark;
	self.timerFillDirection = EncounterTimelineTimerSettingDefaults.TimerFillDirection;
end

function EncounterTimelineTimerSettingsMixin:OnShowIconChanged(_showIcon)
	-- Implement in a derived mixin.
end

function EncounterTimelineTimerSettingsMixin:OnShowTimerSparkChanged(_showTimerSpark)
	-- Implement in a derived mixin.
end

function EncounterTimelineTimerSettingsMixin:OnTimerFillDirectionChanged(_timerFillDirection)
	-- Implement in a derived mixin.
end

function EncounterTimelineTimerSettingsMixin:GetTimerFillDirection()
	return self.timerFillDirection;
end

function EncounterTimelineTimerSettingsMixin:ShouldShowIcon()
	return self.showIcon == true;
end

function EncounterTimelineTimerSettingsMixin:ShouldShowTimerSpark()
	return self.showTimerSpark == true;
end

function EncounterTimelineTimerSettingsMixin:SetShowIcon(showIcon)
	if self.showIcon ~= showIcon then
		self.showIcon = showIcon;
		self:OnShowIconChanged(showIcon);
	end
end

function EncounterTimelineTimerSettingsMixin:SetShowTimerSpark(showTimerSpark)
	if self.showTimerSpark ~= showTimerSpark then
		self.showTimerSpark = showTimerSpark;
		self:OnShowTimerSparkChanged(showTimerSpark);
	end
end

function EncounterTimelineTimerSettingsMixin:SetTimerFillDirection(timerFillDirection)
	if self.timerFillDirection ~= timerFillDirection then
		self.timerFillDirection = timerFillDirection;
		self:OnTimerFillDirectionChanged(timerFillDirection);
	end
end

-- Settings shared specific to timer views.

EncounterTimelineTimerViewSettingsMixin = CreateFromMixins(EncounterTimelineTimerSettingsMixin);

function EncounterTimelineTimerViewSettingsMixin:OnLoad()
	EncounterTimelineTimerSettingsMixin.OnLoad(self);

	self.timerLayoutDirection = EncounterTimelineTimerViewSettingDefaults.TimerLayoutDirection;
	self.timerSpacing = EncounterTimelineTimerViewSettingDefaults.TimerSpacing;
	self.timerWidthScale = EncounterTimelineTimerViewSettingDefaults.TimerWidthScale;
end

function EncounterTimelineTimerViewSettingsMixin:OnTimerLayoutDirectionChanged(_timerLayoutDirection)
	-- Implement in a derived mixin.
end

function EncounterTimelineTimerViewSettingsMixin:OnTimerSpacingChanged(_timerSpacing)
	-- Implement in a derived mixin.
end

function EncounterTimelineTimerViewSettingsMixin:OnTimerWidthScaleChanged(_timerWidthScale)
	-- Implement in a derived mixin.
end

function EncounterTimelineTimerViewSettingsMixin:GetTimerLayoutDirection()
	return self.timerLayoutDirection;
end

function EncounterTimelineTimerViewSettingsMixin:GetTimerSpacing()
	return self.timerSpacing;
end

function EncounterTimelineTimerViewSettingsMixin:GetTimerWidthScale()
	return self.timerWidthScale;
end

function EncounterTimelineTimerViewSettingsMixin:SetTimerLayoutDirection(timerLayoutDirection)
	if self.timerLayoutDirection ~= timerLayoutDirection then
		self.timerLayoutDirection = timerLayoutDirection;
		self:OnTimerLayoutDirectionChanged(timerLayoutDirection);
	end
end

function EncounterTimelineTimerViewSettingsMixin:SetTimerSpacing(timerSpacing)
	if self.timerSpacing ~= timerSpacing then
		self.timerSpacing = timerSpacing;
		self:OnTimerSpacingChanged(timerSpacing);
	end
end

function EncounterTimelineTimerViewSettingsMixin:SetTimerWidthScale(timerWidthScale)
	if self.timerWidthScale ~= timerWidthScale then
		self.timerWidthScale = timerWidthScale;
		self:OnTimerWidthScaleChanged(timerWidthScale);
	end
end
