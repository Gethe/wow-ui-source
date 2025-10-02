EncounterTimelineMixin = CreateFromMixins(EditModeEncounterEventsSystemMixin, EncounterTimelineViewSettingsAccessorMixin, EncounterTimelineViewSettingsMutatorMixin);

function EncounterTimelineMixin:OnLoad()
	EditModeEncounterEventsSystemMixin.OnSystemLoad(self);

	self.editModeEventTimer = nil;
	self.eventFrameCount = 0;

	self:RegisterEvent("ENCOUNTER_STATE_CHANGED");
	self:RegisterEvent("ENCOUNTER_TIMELINE_STATE_UPDATED");

	self:GetView():SetScript("OnSizeChanged", function() self:UpdateSize(); end);
	EventRegistry:RegisterCallback("EncounterTimeline.OnEventFrameAcquired", self.OnEventFrameAcquired, self);
	EventRegistry:RegisterCallback("EncounterTimeline.OnEventFrameReleased", self.OnEventFrameReleased, self);
end

function EncounterTimelineMixin:OnEvent(event, ...)
	if event == "ENCOUNTER_STATE_CHANGED" then
		self:UpdateVisibility();
	elseif event == "ENCOUNTER_TIMELINE_STATE_UPDATED" then
		self:UpdateVisibility();
	end
end

function EncounterTimelineMixin:OnEventFrameAcquired(eventView)
	if self:HasView(eventView) then
		self.eventFrameCount = self.eventFrameCount + 1;
		self:UpdateVisibility();
	end
end

function EncounterTimelineMixin:OnEventFrameReleased(eventView)
	if self:HasView(eventView) then
		self.eventFrameCount = self.eventFrameCount - 1;
		self:UpdateVisibility();
	end
end

function EncounterTimelineMixin:OnEditingChanged(isEditing)
	self:UpdateVisibility();

	if isEditing then
		self:StartEditModeEvents();
	else
		self:CancelEditModeEvents();
	end
end

function EncounterTimelineMixin:HasEventFrames()
	return self.eventFrameCount > 0;
end

function EncounterTimelineMixin:GetView()
	return self.TimelineView;
end

function EncounterTimelineMixin:HasView(view)
	return self.TimelineView == view;
end

function EncounterTimelineMixin:GetViewSetting(key)
	return self:GetView():GetViewSetting(key);
end

function EncounterTimelineMixin:SetViewSetting(key, value)
	self:GetView():SetViewSetting(key, value);

	-- This setting is a bit of a hack, since we want it applied to
	-- the container rather than the view to keep the edit mode shell
	-- synced up properly.

	if key == EncounterTimelineViewSetting.ContainerScale then
		self:SetScale(value / 100);
	end
end

function EncounterTimelineMixin:IsExplicitlyShown()
	return self.isExplicitlyShown == true;
end

function EncounterTimelineMixin:SetExplicitlyShown(explicitlyShown)
	if self.isExplicitlyShown == explicitlyShown then
		return;
	end

	self.isExplicitlyShown = explicitlyShown;
	self:UpdateVisibility();
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
	elseif not C_EncounterTimeline.IsTimelineEnabled() then
		return false;
	elseif self:GetTimelineVisibility() == Enum.EncounterEventsVisibility.Always then
		return true;
	elseif self:GetTimelineVisibility() == Enum.EncounterEventsVisibility.Hidden then
		return false;
	elseif self:GetTimelineVisibility() == Enum.EncounterEventsVisibility.InCombat then
		if C_InstanceEncounter.IsEncounterInProgress() and C_InstanceEncounter.ShouldShowTimelineForEncounter() then
			return true;
		elseif C_EncounterTimeline.HasAnyEvents() or self:HasEventFrames() then
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
