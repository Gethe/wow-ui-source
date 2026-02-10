EncounterTimelineViewMixin = CreateFromMixins(EncounterTimelineFrameManagerMixin, EncounterTimelineDataProviderMixin, EncounterTimelineViewSettingsMixin);

function EncounterTimelineViewMixin:OnLoad()
	EncounterTimelineFrameManagerMixin.OnLoad(self);
	EncounterTimelineDataProviderMixin.OnLoad(self);
	EncounterTimelineViewSettingsMixin.OnLoad(self);

	self:RegisterEvent("ENCOUNTER_TIMELINE_VIEW_ACTIVATED");
	self:RegisterEvent("ENCOUNTER_TIMELINE_VIEW_DEACTIVATED");

	self.eventFramePools = CreateFramePoolCollection();
end

function EncounterTimelineViewMixin:OnShow()
	self:AddAllEvents(C_EncounterTimeline.GetEventList());
	self:SetDynamicEventsRegistered(true);
end

function EncounterTimelineViewMixin:OnHide()
	self:SetDynamicEventsRegistered(false);
	self:RemoveAllEvents();
end

function EncounterTimelineViewMixin:OnEvent(event, ...)
	EncounterTimelineDataProviderMixin.OnEvent(self, event, ...);

	if event == "ENCOUNTER_TIMELINE_VIEW_ACTIVATED" then
		local viewType = ...;

		if viewType == self:GetViewType() then
			self:ActivateView();
		end
	elseif event == "ENCOUNTER_TIMELINE_VIEW_DEACTIVATED" then
		local viewType = ...;

		if viewType == self:GetViewType() then
			self:DeactivateView();
		end
	end
end

function EncounterTimelineViewMixin:OnSizeChanged(width, height)
	EventRegistry:TriggerEvent("EncounterTimeline.OnViewSizeChanged", self, width, height);
end

function EncounterTimelineViewMixin:OnViewActivated()
	-- Override in a derived mixin to be notified when the view has activated.
end

function EncounterTimelineViewMixin:OnViewDeactivated()
	-- Override in a derived mixin to be notified when the view is about to
	-- be deactivated.
end

function EncounterTimelineViewMixin:OnEventAdded(eventInfo)
	local eventID = eventInfo.id;

	-- Newly added events don't have frames associated with them; if this
	-- event is in a state where it should do so immediately then acquire
	-- one now.

	if self:ShouldAcquireFrameForEvent(eventID) then
		self:AcquireEventFrame(eventID);
	end
end

function EncounterTimelineViewMixin:OnEventStateChanged(eventID, state)
	local eventFrame = self:GetEventFrame(eventID);

	-- Event state change transitions are permitted to attempt acquisition of
	-- event frames in case we didn't set one up when it was initially added.

	if eventFrame == nil and self:ShouldAcquireFrameForEvent(eventID) then
		eventFrame = self:AcquireEventFrame(eventID);
	end

	if eventFrame ~= nil then
		eventFrame:SetEventState(state);
	end
end

function EncounterTimelineViewMixin:OnEventTrackChanged(eventID, track, trackSortIndex)
	-- We skip track change transitions on frames that are in a terminal state
	-- as these updates are likely just going to apply movement interpolations
	-- which are pointless for frames animating out.

	if EncounterTimelineUtil.IsTerminalEventState(self:GetEventState(eventID)) then
		return;
	end

	local eventFrame = self:GetEventFrame(eventID);

	-- Event track change transitions are permitted to attempt acquisition of
	-- event frames in case we didn't set one up when it was initially added.

	if eventFrame == nil and self:ShouldAcquireFrameForEvent(eventID) then
		eventFrame = self:AcquireEventFrame(eventID);
	end

	if eventFrame ~= nil then
		eventFrame:SetEventTrack(track, trackSortIndex);
	end
end

function EncounterTimelineViewMixin:OnEventBlockStateChanged(eventID, blocked)
	-- We don't skip block state transitions on frames in terminal event
	-- states. Events in terminal states will never _enter_ a blocked state,
	-- but entering a terminal state may simultaneously (in the same tick)
	-- leave one, which is expected to require visual modifications.

	local eventFrame = self:GetEventFrame(eventID);

	if eventFrame ~= nil then
		eventFrame:SetEventBlocked(blocked);
	end
end

function EncounterTimelineViewMixin:OnEventHighlight(eventID)
	-- Skip highlight animations on frames that are in a terminal state, as
	-- they'll be in the process of animating out anyway.

	if EncounterTimelineUtil.IsTerminalEventState(self:GetEventState(eventID)) then
		return;
	end

	local eventFrame = self:GetEventFrame(eventID);

	if eventFrame ~= nil then
		eventFrame:HighlightFrame();
	end
end

function EncounterTimelineViewMixin:OnEventRemoved(eventID)
	-- When removing an event we only want to release event frames if they're
	-- actively attached to this event still. Detached event frames shouldn't
	-- be released - frames in such a state are assumed to be animating out
	-- and will release themselves when finished.

	local eventFrame = self:GetEventFrame(eventID);

	if self:IsEventFrameAttached(eventFrame, eventID) then
		self:ReleaseEventFrame(eventFrame);
	end
end

function EncounterTimelineViewMixin:OnEventFrameAcquired(eventFrame, eventID, isNewObject)
	self:InitializeEventFrame(eventID, eventFrame);

	EventRegistry:TriggerEvent("EncounterTimeline.OnEventFrameAcquired", self, eventFrame, eventID, isNewObject);
end

function EncounterTimelineViewMixin:OnEventFrameReleased(eventFrame)
	EventRegistry:TriggerEvent("EncounterTimeline.OnEventFrameReleased", self, eventFrame);
end

function EncounterTimelineViewMixin:OnFlipHorizontallyChanged(flipHorizontally)
	for eventFrame in self:EnumerateEventFrames() do
		eventFrame:SetFlipHorizontally(flipHorizontally);
	end
end

function EncounterTimelineViewMixin:OnHighlightTimeChanged(highlightTime)
	for eventFrame in self:EnumerateEventFrames() do
		eventFrame:SetHighlightTime(highlightTime);
	end
end

function EncounterTimelineViewMixin:OnIconScaleChanged(iconScale)
	for eventFrame in self:EnumerateEventFrames() do
		eventFrame:SetIconScale(iconScale);
	end
end

function EncounterTimelineViewMixin:OnIndicatorIconMaskChanged(indicatorIconMask)
	for eventFrame in self:EnumerateEventFrames() do
		eventFrame:SetIndicatorIconMask(indicatorIconMask);
	end
end

function EncounterTimelineViewMixin:OnShowCountdownChanged(showCountdown)
	for eventFrame in self:EnumerateEventFrames() do
		eventFrame:SetShowCountdown(showCountdown);
	end
end

function EncounterTimelineViewMixin:OnShowTextChanged(showText)
	for eventFrame in self:EnumerateEventFrames() do
		eventFrame:SetShowText(showText);
	end
end

function EncounterTimelineViewMixin:OnTooltipAnchorChanged(tooltipAnchor)
	for eventFrame in self:EnumerateEventFrames() do
		eventFrame:SetTooltipAnchor(tooltipAnchor);
	end
end

function EncounterTimelineViewMixin:ActivateView()
	if self:IsViewActive() then
		return;
	end

	if not self:CanActivateView() then
		return;
	end

	-- Activation of a view just shows this frame and notifies the parent
	-- container. We don't register for dynamic events or add events directly
	-- here as the parent container may not be visible - instead, allow the
	-- OnShow script to fire and handle that for us.

	self:Show();
	self:OnViewActivated();

	EventRegistry:TriggerEvent("EncounterTimeline.OnViewActivated", self);
end

function EncounterTimelineViewMixin:DeactivateView()
	if not self:IsViewActive() then
		return;
	end

	-- Deactivation is the inverse of activation with the added wrinkle that
	-- for safety reasons we deactivate all dynamic event registrations and
	-- remove all events before hiding to guard against scenarios where
	-- deferred script execution for OnHide might be in effect.

	self:OnViewDeactivated();
	self:SetDynamicEventsRegistered(false);
	self:RemoveAllEvents();
	self:Hide();

	EventRegistry:TriggerEvent("EncounterTimeline.OnViewDeactivated", self);
end

function EncounterTimelineViewMixin:CanActivateView()
	-- Override if there are additional reasons that this view shouldn't
	-- attempt to self-activate. Note that deactivation of a view is never
	-- blocked.

	return C_EncounterTimeline.GetViewType() == self:GetViewType();
end

function EncounterTimelineViewMixin:GetViewType()
	-- Override in a derived mixin to return an appropriate view type enumerant.
	assertsafe(false, "GetViewType must be implemented in a derived mixin");
	return nil;
end

function EncounterTimelineViewMixin:IsViewActive()
	return self:IsShown();
end

function EncounterTimelineViewMixin:SetViewActive(active)
	if active then
		self:ActivateView();
	else
		self:DeactivateView();
	end
end

function EncounterTimelineViewMixin:GetEventFramePoolCollection()
	return self.eventFramePools;
end

function EncounterTimelineViewMixin:InitializeEventFrameSettings(eventFrame)
	-- Override in a derived mixin to copy down appropriate settings to event
	-- frames and set up an initial anchor point.

	eventFrame:SetFlipHorizontally(self:ShouldFlipHorizontally());
	eventFrame:SetIconScale(self:GetIconScale());
	eventFrame:SetIndicatorIconMask(self:GetIndicatorIconMask());
	eventFrame:SetShowCountdown(self:ShouldShowCountdown());
	eventFrame:SetShowText(self:ShouldShowText());
	eventFrame:SetTooltipAnchor(self:GetTooltipAnchor());
end

function EncounterTimelineViewMixin:InitializeEventFrame(eventID, eventFrame)
	local eventInfo = self:GetEventInfo(eventID);
	local timer = self:GetEventTimer(eventID);
	local state = self:GetEventState(eventID);
	local track, trackSortIndex = self:GetEventTrack(eventID);
	local blocked = self:IsEventBlocked(eventID);

	self:InitializeEventFrameSettings(eventFrame);

	eventFrame:Init(eventInfo, timer, state, track, trackSortIndex, blocked);

	if self:ShouldShowEventFrameOnInitialization(eventFrame) then
		eventFrame:Show();
	end
end

function EncounterTimelineViewMixin:RegisterEventFramePool(frameType, templateName)
	local function ResetEventFrame(eventFramePool, eventFrame)
		self:ResetEventFrame(eventFramePool, eventFrame);
	end

	local eventFramePools = self:GetEventFramePoolCollection();
	eventFramePools:CreatePool(frameType, self, templateName, ResetEventFrame);
end

function EncounterTimelineViewMixin:ReinitializeAllEventFrames()
	self:ReleaseAllEventFrames();

	for eventID in self:EnumerateEvents() do
		if self:ShouldAcquireFrameForEvent(eventID) then
			self:AcquireEventFrame(eventID);
		end
	end
end

function EncounterTimelineViewMixin:ResetEventFrame(_eventFramePool, eventFrame)
	eventFrame:Reset();
	eventFrame:ClearAllPoints();
	eventFrame:Hide();
end

function EncounterTimelineViewMixin:SetDynamicEventsRegistered(registered)
	local dynamicEvents = self:GetDynamicEventRegistrations();

	if registered then
		FrameUtil.RegisterFrameForEvents(self, dynamicEvents);
	else
		FrameUtil.UnregisterFrameForEvents(self, dynamicEvents);
	end
end

function EncounterTimelineViewMixin:ShouldAcquireFrameForEvent(eventID)
	local state = self:GetEventState(eventID);

	if EncounterTimelineUtil.IsTerminalEventState(state) then
		-- Event is in a terminal state; don't acquire a frame.
		return false;
	end

	local track = self:GetEventTrack(eventID);

	if track == Enum.EncounterTimelineTrack.Indeterminate then
		-- Event isn't on a visible track; don't acquire a frame.
		return false;
	end

	return true;
end

function EncounterTimelineViewMixin:ShouldShowEventFrameOnInitialization(_eventFrame)
	-- Override if event frames shouldn't be automatically shown upon
	-- acquisition and initialization.
	return true;
end
