EncounterTimelineDirtyFlags = {
	Visibility = bit.lshift(1, 0),
};

EncounterTimelineMixin = CreateFromMixins(EditModeEncounterEventsSystemMixin);

function EncounterTimelineMixin:OnLoad()
	EditModeEncounterEventsSystemMixin.OnSystemLoad(self);

	self.dirtyFlags = CreateFlags();
	self.dirtyUpdateTimer = nil;
	self.editModeEventTimer = nil;

	self:RegisterEvent("ENCOUNTER_STATE_CHANGED");
	self:RegisterEvent("ENCOUNTER_TIMELINE_STATE_UPDATED");
	self:RegisterEvent("SETTINGS_LOADED");

	self:GetView():SetScript("OnSizeChanged", function() self:UpdateSize(); end);
	EventRegistry:RegisterCallback("EncounterTimeline.OnEventFrameAcquired", self.OnEventFrameAcquired, self);
	EventRegistry:RegisterCallback("EncounterTimeline.OnEventFrameReleased", self.OnEventFrameReleased, self);

	for _, cvarName in pairs(EncounterTimelineVisibilityCVars) do
		CVarCallbackRegistry:SetCVarCachable(cvarName);
		CVarCallbackRegistry:RegisterCallback(cvarName, function() self:OnVisibilityCVarChanged(cvarName); end, self);
	end

	for _, cvarName in pairs(EncounterTimelineIndicatorIconCVars) do
		CVarCallbackRegistry:SetCVarCachable(cvarName);
		CVarCallbackRegistry:RegisterCallback(cvarName, function() self:OnIndicatorIconCVarChanged(cvarName); end, self);
	end
end

function EncounterTimelineMixin:OnEvent(event, ...)
	if event == "ENCOUNTER_STATE_CHANGED" then
		self:MarkDirty(EncounterTimelineDirtyFlags.Visibility);
	elseif event == "ENCOUNTER_TIMELINE_STATE_UPDATED" then
		self:MarkDirty(EncounterTimelineDirtyFlags.Visibility);
	elseif event == "SETTINGS_LOADED" then
		self:UpdateEventIndicatorIconMask();
	end
end

function EncounterTimelineMixin:OnDirtyUpdate()
	if self:IsDirty(EncounterTimelineDirtyFlags.Visibility) then
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
	self:MarkDirty(EncounterTimelineDirtyFlags.Visibility);
end

function EncounterTimelineMixin:OnEventFrameAcquired(eventView, _eventFrame, _isNewObject)
	if self:HasView(eventView) then
		self:MarkDirty(EncounterTimelineDirtyFlags.Visibility);
	end
end

function EncounterTimelineMixin:OnEventFrameReleased(eventView, _eventFrame)
	if self:HasView(eventView) then
		self:MarkDirty(EncounterTimelineDirtyFlags.Visibility);
	end
end

function EncounterTimelineMixin:OnEditingChanged(isEditing)
	self:MarkDirty(EncounterTimelineDirtyFlags.Visibility);

	if isEditing then
		self:StartEditModeEvents();
	else
		self:CancelEditModeEvents();
		self:Hide();
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
	return self.View:HasAnyActiveEventFrames();
end

function EncounterTimelineMixin:GetView()
	return self.View;
end

function EncounterTimelineMixin:HasView(view)
	return self.View == view;
end

function EncounterTimelineMixin:IsExplicitlyShown()
	return self.isExplicitlyShown == true;
end

function EncounterTimelineMixin:SetExplicitlyShown(explicitlyShown)
	if self.isExplicitlyShown == explicitlyShown then
		return;
	end

	self.isExplicitlyShown = explicitlyShown;
	self:MarkDirty(EncounterTimelineDirtyFlags.Visibility);
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
	self:SetSize(self:GetView():GetSize());
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

	if shouldShow then
		self:BeginShow();
	else
		self:BeginHide();
	end

	self:MarkClean(EncounterTimelineDirtyFlags.Visibility);
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

function EncounterTimelineMixin:BeginShow()
	self.HideAnimation:Stop();

	if self:IsShown() then
		return;
	end

	-- Ordering here is important for subtle reasons. We need to show first
	-- so that the view can invoke UpdateLayout, which applies alpha values
	-- to various child texture regions. Then, we need to start the alpha
	-- animation.
	--
	-- If we do this the other way around the Play call will cause the alpha
	-- currently used by texture regions to be cached in animdata and the
	-- SetAlpha calls effectively ignored.

	self:SetShown(true);
	self.ShowAnimation:Play();
end

function EncounterTimelineMixin:BeginHide()
	local isFadingIn = self.ShowAnimation:IsPlaying();
	self.ShowAnimation:Stop();

	if not self:IsShown() then
		return;
	end

	-- If we're in the process of fading in then hiding should skip the
	-- initial hold delay.

	if isFadingIn then
		self.HideAnimation.Alpha:SetStartDelay(0);
	else
		self.HideAnimation.Alpha:SetStartDelay(0.3);
	end

	self.HideAnimation:Play();
end

function EncounterTimelineMixin:UpdateEventIndicatorIconMask()
	local visibleIconMask = EncounterTimelineUtil.GetEventIndicatorIconMask();
	self:GetView():SetEventIndicatorIconMask(visibleIconMask);
end

function EncounterTimelineMixin:UpdateViewOrientation()
	local orientationSetting = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.Orientation);
	local iconDirectionSetting = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.IconDirection);

	local orientation = EncounterTimelineUtil.CreateOrientation(orientationSetting, iconDirectionSetting);
	self:GetView():SetViewOrientation(orientation);

	local pipTextAnchor;

	if orientationSetting == Enum.EncounterEventsOrientation.Horizontal then
		pipTextAnchor = EncounterTimelinePipTextAnchors.Horizontal;
	elseif orientationSetting == Enum.EncounterEventsOrientation.Vertical then
		pipTextAnchor = EncounterTimelinePipTextAnchors.Vertical;
	end

	self:GetView():SetPipTextAnchor(pipTextAnchor);
end

function EncounterTimelineMixin:UpdateSystemSettingOrientation()
	self:UpdateViewOrientation();
end

function EncounterTimelineMixin:UpdateSystemSettingIconDirection()
	self:UpdateViewOrientation();
end

function EncounterTimelineMixin:UpdateSystemSettingIconSize()
	local iconScale = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.IconSize) * EncounterTimelineConstants.SizeToScaleMultiplier;
	self:GetView():SetEventIconScale(iconScale);
end

function EncounterTimelineMixin:UpdateSystemSettingOverallSize()
	local frameScale = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.OverallSize) * EncounterTimelineConstants.SizeToScaleMultiplier;
	self:SetScale(frameScale);
end

function EncounterTimelineMixin:UpdateSystemSettingBackgroundTransparency()
	local backgroundAlpha = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.BackgroundTransparency) * EncounterTimelineConstants.TransparencyToAlphaMultiplier;
	self:GetView():SetViewBackgroundAlpha(backgroundAlpha);
end

function EncounterTimelineMixin:UpdateSystemSettingTransparency()
	local frameAlpha = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.Transparency) * EncounterTimelineConstants.TransparencyToAlphaMultiplier;
	self:GetView():SetAlpha(frameAlpha);
end

function EncounterTimelineMixin:UpdateSystemSettingVisibility()
	self:MarkDirty(EncounterTimelineDirtyFlags.Visibility);
end

function EncounterTimelineMixin:UpdateSystemSettingShowSpellName()
	local textEnabled = self:GetSettingValueBool(Enum.EditModeEncounterEventsSetting.ShowSpellName);
	self:GetView():SetEventTextEnabled(textEnabled);
end

function EncounterTimelineMixin:UpdateSystemSettingShowTooltips()
	local tooltipsEnabled = self:GetSettingValueBool(Enum.EditModeEncounterEventsSetting.ShowTooltips);
	self:GetView():SetEventTooltipsEnabled(tooltipsEnabled);
end

function EncounterTimelineMixin:UpdateSystemSettingShowTimer()
	local countdownEnabled = self:GetSettingValueBool(Enum.EditModeEncounterEventsSetting.ShowTimer);
	self:GetView():SetEventCountdownEnabled(countdownEnabled);
end
