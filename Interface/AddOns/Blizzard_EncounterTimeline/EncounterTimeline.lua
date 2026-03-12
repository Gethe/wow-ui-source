EncounterTimelineScriptedAnimation = {
	FadeIn = 1,
	FadeOut = 2,
};

EncounterTimelineDirtyFlag = {
	Visibility = bit.lshift(1, 0),
};

EncounterTimelineDirtyFlag.All = Flags_CreateMaskFromTable(EncounterTimelineDirtyFlag);

EncounterTimelineMixin = CreateFromMixins(EditModeEncounterEventsSystemMixin, EncounterTimelineScriptedAnimatableMixin);

function EncounterTimelineMixin:OnLoad()
	EditModeEncounterEventsSystemMixin.OnSystemLoad(self);
	EncounterTimelineScriptedAnimatableMixin.OnLoad(self);

	self.activeView = nil;
	self.dirtyFlags = CreateFlags(EncounterTimelineDirtyFlag.All);
	self.dirtyUpdateTimer = nil;
	self.editModeEventTimer = nil;

	self:RegisterEvent("ENCOUNTER_STATE_CHANGED");
	self:RegisterEvent("ENCOUNTER_TIMELINE_STATE_UPDATED");
	self:RegisterEvent("SETTINGS_LOADED");

	EventRegistry:RegisterCallback("EncounterTimeline.OnEventFrameAcquired", self.OnEventFrameAcquired, self);
	EventRegistry:RegisterCallback("EncounterTimeline.OnEventFrameReleased", self.OnEventFrameReleased, self);
	EventRegistry:RegisterCallback("EncounterTimeline.OnViewActivated", self.OnViewActivated, self);
	EventRegistry:RegisterCallback("EncounterTimeline.OnViewSizeChanged", self.OnViewSizeChanged, self);
	EventRegistry:RegisterCallback("EncounterTimeline.OnViewDeactivated", self.OnViewDeactivated, self);

	for _, cvarName in pairs(EncounterTimelineVisibilityCVars) do
		CVarCallbackRegistry:SetCVarCachable(cvarName);
		CVarCallbackRegistry:RegisterCallback(cvarName, function() self:OnVisibilityCVarChanged(cvarName); end, self);
	end

	for _, cvarName in pairs(EncounterTimelineIndicatorIconCVars) do
		CVarCallbackRegistry:SetCVarCachable(cvarName);
		CVarCallbackRegistry:RegisterCallback(cvarName, function() self:OnIndicatorIconCVarChanged(cvarName); end, self);
	end

	local highlightTimeCVar = "encounterTimelineHighlightDuration";
	CVarCallbackRegistry:SetCVarCachable(highlightTimeCVar);
	CVarCallbackRegistry:RegisterCallback(highlightTimeCVar, function() self:UpdateHighlightTime(); end, self);
end

function EncounterTimelineMixin:OnHide()
	self:CancelScriptedAnimation();
end

function EncounterTimelineMixin:OnEvent(event, ...)
	if event == "ENCOUNTER_STATE_CHANGED" then
		self:MarkDirty(EncounterTimelineDirtyFlag.Visibility);
	elseif event == "ENCOUNTER_TIMELINE_STATE_UPDATED" then
		self:MarkDirty(EncounterTimelineDirtyFlag.Visibility);
	elseif event == "SETTINGS_LOADED" then
		self:UpdateEventIndicatorIconMask();
		self:UpdateHighlightTime();
	end
end

function EncounterTimelineMixin:OnDirtyUpdate()
	if self:IsDirty(EncounterTimelineDirtyFlag.Visibility) then
		self:UpdateVisibility();
	end

	if not self:IsDirty() and self.dirtyUpdateTimer ~= nil then
		self.dirtyUpdateTimer:Cancel();
		self.dirtyUpdateTimer = nil;
	end
end

function EncounterTimelineMixin:OnIndicatorIconCVarChanged(_cvarName)
	self:UpdateEventIndicatorIconMask();
end

function EncounterTimelineMixin:OnVisibilityCVarChanged(_cvarName)
	self:MarkDirty(EncounterTimelineDirtyFlag.Visibility);
end

function EncounterTimelineMixin:OnEventFrameAcquired(viewFrame, _eventFrame, _eventID, _isNewObject)
	if self:GetActiveView() == viewFrame then
		self:MarkDirty(EncounterTimelineDirtyFlag.Visibility);
	end
end

function EncounterTimelineMixin:OnEventFrameReleased(viewFrame, _eventFrame)
	if self:GetActiveView() == viewFrame then
		self:MarkDirty(EncounterTimelineDirtyFlag.Visibility);
	end
end

function EncounterTimelineMixin:OnEditingChanged(isEditing)
	self:MarkDirty(EncounterTimelineDirtyFlag.Visibility);

	if isEditing then
		self:StartEditModeEvents();
	else
		self:CancelEditModeEvents();
		self:Hide();
	end
end

function EncounterTimelineMixin:OnViewActivated(viewFrame)
	if self:GetActiveView() == nil then
		self.activeView = viewFrame;
		self:UpdateSize();
	end
end

function EncounterTimelineMixin:OnViewSizeChanged(viewFrame, _width, _height)
	if self:GetActiveView() == viewFrame then
		self:UpdateSize();
	end
end

function EncounterTimelineMixin:OnViewDeactivated(viewFrame)
	if self:GetActiveView() == viewFrame then
		self.activeView = nil;
	end
end

function EncounterTimelineMixin:MarkDirty(flag)
	self.dirtyFlags:Set(flag);

	if self.dirtyUpdateTimer == nil then
		self.dirtyUpdateTimer = C_Timer.NewTimer(0, function() self:OnDirtyUpdate(); end);
	end
end

function EncounterTimelineMixin:MarkClean(flag)
	self.dirtyFlags:Clear(flag);
end

function EncounterTimelineMixin:IsDirty(flag)
	if flag ~= nil then
		return self.dirtyFlags:IsSet(flag);
	else
		return self.dirtyFlags:IsAnySet();
	end
end

function EncounterTimelineMixin:HasEventFrames()
	local viewFrame = self:GetActiveView();

	if viewFrame ~= nil then
		return viewFrame:HasAnyActiveEventFrames();
	else
		return false;
	end
end

function EncounterTimelineMixin:GetActiveView()
	return self.activeView;
end

function EncounterTimelineMixin:GetTimerView()
	return self.TimerView;
end

function EncounterTimelineMixin:GetTrackView()
	return self.TrackView;
end

function EncounterTimelineMixin:EnumerateViews()
	return ipairs(self.Views);
end

function EncounterTimelineMixin:IsExplicitlyShown()
	return self.isExplicitlyShown == true;
end

function EncounterTimelineMixin:SetExplicitlyShown(explicitlyShown)
	if self.isExplicitlyShown == explicitlyShown then
		return;
	end

	self.isExplicitlyShown = explicitlyShown;
	self:MarkDirty(EncounterTimelineDirtyFlag.Visibility);
end

function EncounterTimelineMixin:IsEditing()
	return self.isEditing;
end

function EncounterTimelineMixin:SetIsEditing(isEditing)
	if self.isEditing == isEditing then
		return;
	end

	self.isEditing = isEditing;
	self:OnEditingChanged(self.isEditing);
end

function EncounterTimelineMixin:UpdateSize()
	local viewFrame = self:GetActiveView();

	if viewFrame ~= nil then
		-- Ensure an minimum size of 1x1 so that views have valid rects.
		local width, height = viewFrame:GetSize();
		width = math.max(width, 1);
		height = math.max(height, 1);

		self:SetSize(width, height);
	end
end

function EncounterTimelineMixin:EvaluateVisibility()
	if self:IsEditing() then
		return true;
	elseif self:IsExplicitlyShown() then
		return true;
	elseif not C_EncounterTimeline.IsFeatureEnabled() then
		return false;
	end

	local visibility = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.Visibility);

	if visibility == Enum.EncounterEventsVisibility.Always then
		return true;
	elseif visibility == Enum.EncounterEventsVisibility.InEncounter then
		if C_InstanceEncounter.IsEncounterInProgress() and C_InstanceEncounter.ShouldShowTimelineForEncounter() then
			return true;
		elseif C_EncounterTimeline.HasVisibleEvents() or self:HasEventFrames() then
			-- Accommodating respawn timers and the like without having to fake the
			-- in-encounter state. Also works for custom events.
			return true;
		end
	end

	return false;
end

function EncounterTimelineMixin:UpdateVisibility()
	local shouldShow = self:EvaluateVisibility();

	if shouldShow ~= self:IsShown() then
		if shouldShow then
			self:AnimateShow();
		else
			self:AnimateHide();
		end
	end

	self:MarkClean(EncounterTimelineDirtyFlag.Visibility);
end

function EncounterTimelineMixin:CancelEditModeEvents()
	if self.editModeEventTimer then
		self.editModeEventTimer:Cancel();
		self.editModeEventTimer = nil;
		C_EncounterTimeline.CancelEditModeEvents();
	end
end

function EncounterTimelineMixin:StartEditModeEvents()
	local function QueueEditModeEvents()
		-- Prefer the use of NewTimer over NewTicker here to allow the dummy
		-- spell cooldown to be adjusted without having to re-enter edit mode.
		local loopTimerDuration = C_EncounterTimeline.AddEditModeEvents();
		self.editModeEventTimer = C_Timer.NewTimer(loopTimerDuration, QueueEditModeEvents);
	end

	if not self.editModeEventTimer then
		QueueEditModeEvents();
	end
end

function EncounterTimelineMixin:AnimateShow()
	if self:IsPlayingScriptedAnimation(EncounterTimelineScriptedAnimation.FadeIn) then
		-- We're already in the process of fading in.
		return;
	end

	local function SetAnimatedAlpha(region, elapsed, duration)
		local alpha = EasingUtil.InQuadratic(elapsed / duration);
		region:SetAlpha(alpha);
	end

	local duration = 0.2;

	self:CancelScriptedAnimation();
	self:StartScriptedAnimation(EncounterTimelineScriptedAnimation.FadeIn, SetAnimatedAlpha, duration);
	self:SetAlpha(0);
	self:Show();
end

function EncounterTimelineMixin:AnimateHide()
	if not self:IsShown() or self:IsPlayingScriptedAnimation(EncounterTimelineScriptedAnimation.FadeOut) then
		-- We're already hidden or are in the process of fading out.
		return;
	end

	local function SetAnimatedAlpha(region, elapsed, duration)
		local progress = EasingUtil.OutQuadratic(elapsed / duration);
		local alpha = 1 - progress;
		region:SetAlpha(alpha);
	end

	local function OnAnimationFinish(region)
		region:Hide();
	end

	local duration = 0.2;

	self:CancelScriptedAnimation();
	self:StartScriptedAnimation(EncounterTimelineScriptedAnimation.FadeOut, SetAnimatedAlpha, duration, OnAnimationFinish);
end

function EncounterTimelineMixin:UpdateEventIndicatorIconMask()
	local visibleIconMask = EncounterTimelineUtil.GetIndicatorIconMask();

	for _, view in self:EnumerateViews() do
		view:SetIndicatorIconMask(visibleIconMask);
	end
end

function EncounterTimelineMixin:UpdateHighlightTime()
	local highlightTime = C_EncounterTimeline.GetEventHighlightTime();

	for _, view in self:EnumerateViews() do
		view:SetHighlightTime(highlightTime);
	end
end

function EncounterTimelineMixin:UpdateTrackOrientation()
	local orientationSetting = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.Orientation);
	local iconDirectionSetting = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.IconDirection);

	local orientation = EncounterTimelineUtil.CreateTrackOrientation(orientationSetting, iconDirectionSetting);
	local pipTextAnchor;

	if orientationSetting == Enum.EncounterEventsOrientation.Horizontal then
		pipTextAnchor = EncounterTimelinePipTextAnchors.Horizontal;
	elseif orientationSetting == Enum.EncounterEventsOrientation.Vertical then
		pipTextAnchor = EncounterTimelinePipTextAnchors.Vertical;
	end

	self:GetTrackView():SetTrackOrientation(orientation);
	self:GetTrackView():SetPipTextAnchor(pipTextAnchor);
end

function EncounterTimelineMixin:UpdateSystemSettingViewType()
	-- We allow user addons to override the view type separate from edit mode
	-- to make it easier for them to lock the view type to None if they
	-- want to outright replace the timeline display.

	local editModeViewType = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.ViewType);
	local overrideViewType = EncounterTimeline:GetAttribute("overrideViewType");
	local viewType = overrideViewType or EncounterTimelineUtil.GetViewTypeFromEditMode(editModeViewType);

	C_EncounterTimeline.SetViewType(viewType);
end

function EncounterTimelineMixin:UpdateSystemSettingOrientation()
	self:UpdateTrackOrientation();
end

function EncounterTimelineMixin:UpdateSystemSettingIconDirection()
	self:UpdateTrackOrientation();
end

function EncounterTimelineMixin:UpdateSystemSettingIconSize()
	local iconScale = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.IconSize) * EncounterTimelineConstants.SizeToScaleMultiplier;

	for _, view in self:EnumerateViews() do
		view:SetIconScale(iconScale);
	end
end

function EncounterTimelineMixin:UpdateSystemSettingOverallSize()
	local frameScale = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.OverallSize) * EncounterTimelineConstants.SizeToScaleMultiplier;
	self:SetScale(frameScale);
end

function EncounterTimelineMixin:UpdateSystemSettingPadding()
	local timerSpacing = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.Padding);
	self:GetTimerView():SetTimerSpacing(timerSpacing);
end

function EncounterTimelineMixin:UpdateSystemSettingBarWidth()
	local timerWidthScale = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.BarWidth) * EncounterTimelineConstants.SizeToScaleMultiplier;
	self:GetTimerView():SetTimerWidthScale(timerWidthScale);
end

function EncounterTimelineMixin:UpdateSystemSettingBackgroundTransparency()
	local backgroundAlpha = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.BackgroundTransparency) * EncounterTimelineConstants.TransparencyToAlphaMultiplier;

	for _, view in self:EnumerateViews() do
		view:SetBackgroundAlpha(backgroundAlpha);
	end
end

function EncounterTimelineMixin:UpdateSystemSettingTransparency()
	local frameAlpha = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.Transparency) * EncounterTimelineConstants.TransparencyToAlphaMultiplier;

	for _, view in self:EnumerateViews() do
		view:SetAlpha(frameAlpha);
	end
end

function EncounterTimelineMixin:UpdateSystemSettingVisibility()
	self:MarkDirty(EncounterTimelineDirtyFlag.Visibility);
end

function EncounterTimelineMixin:UpdateSystemSettingTooltipAnchor()
	local tooltipAnchor = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.TooltipAnchor);

	for _, view in self:EnumerateViews() do
		view:SetTooltipAnchor(tooltipAnchor);
	end
end

function EncounterTimelineMixin:UpdateSystemSettingFlipHorizontally()
	local flipHorizontally = self:GetSettingValueBool(Enum.EditModeEncounterEventsSetting.FlipHorizontally);

	for _, view in self:EnumerateViews() do
		view:SetFlipHorizontally(flipHorizontally);
	end
end

function EncounterTimelineMixin:UpdateSystemSettingShowSpellName()
	local showText = self:GetSettingValueBool(Enum.EditModeEncounterEventsSetting.ShowSpellName);

	for _, view in self:EnumerateViews() do
		view:SetShowText(showText);
	end
end

function EncounterTimelineMixin:UpdateSystemSettingShowTimer()
	local showCountdown = self:GetSettingValueBool(Enum.EditModeEncounterEventsSetting.ShowTimer);

	for _, view in self:EnumerateViews() do
		view:SetShowCountdown(showCountdown);
	end
end
