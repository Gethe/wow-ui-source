-- The timeline view frame manager implements a very small state machine for
-- tracking the association of timeline event IDs to their primary display
-- frame.
--
-- Event frames can be marked as orphaned or detached. An orphaned event frame
-- maintains graph connectivity to its owning event. This allows the frame to
-- be queried and re-assigned back to the event if later needed. Detached
-- event frames are similar, but don't maintain the link to their event ID.
--
-- An example of when you'll want to use these states is with outro animations
-- for event frames that can potentially be reversed. Putting a frame into an
-- orphaned state allows you to re-obtain the frame if, during animating out,
-- you need to reverse the transition. If the animation can't be reversed then
-- it makes more sense to fully detach the frame and then release it when your
-- animation completes.

EncounterTimelineViewFrameManagerMixin = {};

function EncounterTimelineViewFrameManagerMixin:OnLoad()
	self.eventFramesByID = {};
	self.eventFramesOrphaned = {};
	self.eventFramesActive = {};
end

function EncounterTimelineViewFrameManagerMixin:GetEventFramePool(_eventID)
	-- Override in a derived mixin to provide access to a frame pool for an event.
end

function EncounterTimelineViewFrameManagerMixin:AcquireEventFrame(eventID)
	local eventFramePool = self:GetEventFramePool(eventID);

	if not eventFramePool then
		assertsafe(false, "attempted to acquire an event frame that has no valid pool")
		return;
	end

	local eventFrame, isNewObject = eventFramePool:Acquire();

	EventRegistry:TriggerEvent("EncounterTimeline.OnEventFrameAcquired", self, eventFrame, isNewObject);

	self:AssignEventFrame(eventID, eventFrame);
	self:InitializeEventFrame(eventFrame, eventID);

	EventRegistry:TriggerEvent("EncounterTimeline.OnEventFrameInitialized", self, eventFrame);

	return eventFrame;
end

function EncounterTimelineViewFrameManagerMixin:InitializeEventFrame(_eventFrame, _eventID)
	-- Override in a derived mixin to apply post-acquire initialization tasks
	-- on your event frame.
end

function EncounterTimelineViewFrameManagerMixin:GetEventFrame(eventID)
	return self.eventFramesByID[eventID];
end

function EncounterTimelineViewFrameManagerMixin:GetOrAcquireEventFrame(eventID)
	local eventFrame = self:GetEventFrame(eventID);

	if not eventFrame then
		eventFrame = self:AcquireEventFrame(eventID);
	elseif self:IsEventFrameOrphaned(eventFrame) then
		self:AssignEventFrame(eventID, eventFrame);
	end

	return eventFrame;
end

function EncounterTimelineViewFrameManagerMixin:HasEventFrame(eventID)
	return self.eventFramesByID[eventID] ~= nil;
end

function EncounterTimelineViewFrameManagerMixin:EnumerateEventFrames()
	return pairs(self.eventFramesActive);
end

function EncounterTimelineViewFrameManagerMixin:IsEventFrameAssigned(eventFrame)
	local eventID = eventFrame:GetID();
	return self.eventFramesByID[eventID] == eventFrame;
end

function EncounterTimelineViewFrameManagerMixin:IsEventFrameOrphaned(eventFrame)
	return self.eventFramesOrphaned[eventFrame] == true;
end

function EncounterTimelineViewFrameManagerMixin:IsEventFrameDetached(eventFrame)
	return self:IsEventFrameOrphaned(eventFrame) and not self:IsEventFrameAssigned(eventFrame);
end

function EncounterTimelineViewFrameManagerMixin:AssignEventFrame(eventID, eventFrame)
	self.eventFramesByID[eventID] = eventFrame;
	self.eventFramesOrphaned[eventFrame] = nil;
	self.eventFramesActive[eventFrame] = true;
	eventFrame:SetID(eventID);
end

function EncounterTimelineViewFrameManagerMixin:OrphanEventFrame(eventFrame)
	self.eventFramesOrphaned[eventFrame] = true;
end

function EncounterTimelineViewFrameManagerMixin:DetachEventFrame(eventFrame)
	local eventID = eventFrame:GetID();

	self.eventFramesOrphaned[eventFrame] = true;

	if self.eventFramesByID[eventID] == eventFrame then
		self.eventFramesByID[eventID] = nil;
	end
end

function EncounterTimelineViewFrameManagerMixin:ReleaseEventFrame(eventFrame)
	local eventID = eventFrame:GetID();
	local eventFramePool = self:GetEventFramePool(eventID);

	if not eventFramePool then
		assertsafe(false, "attempted to release an event frame that has no valid pool")
		return;
	end

	eventFramePool:Release(eventFrame);

	eventFrame:SetID(0);
	self.eventFramesOrphaned[eventFrame] = nil;
	self.eventFramesActive[eventFrame] = nil;

	if self.eventFramesByID[eventID] == eventFrame then
		self.eventFramesByID[eventID] = nil;
	end

	EventRegistry:TriggerEvent("EncounterTimeline.OnEventFrameReleased", self, eventFrame);
end

-- The view anchoring mixin provides an abstraction around frame anchor
-- points, offsets, and sizes in an axis-agnostic manner. The orientation
-- can be configured through an orientation setup table which defines point
-- mappings, direction multipliers, and whether or not the timeline is in
-- a vertical or horizontal state.

EncounterTimelineViewAnchoringMixin = {};

function EncounterTimelineViewAnchoringMixin:OnLoad()
	self.orientationPointMappings = { START = "LEFT", END = "RIGHT" };
	self.orientationPrimaryAxisVertical = false;
	self.orientationPrimaryAxisDirection = 1;
	self.orientationCrossAxisDirection = 1;
	self.orientationTextureRotation = 0;
end

function EncounterTimelineViewAnchoringMixin:IsVertical()
	return self.orientationPrimaryAxisVertical;
end

function EncounterTimelineViewAnchoringMixin:GetTranslatedAnchorPoint(point)
	return self.orientationPointMappings[point] or point;
end

function EncounterTimelineViewAnchoringMixin:GetTranslatedOffsets(primaryAxisOffset, crossAxisOffset)
	primaryAxisOffset = primaryAxisOffset * self.orientationPrimaryAxisDirection;
	crossAxisOffset = crossAxisOffset * self.orientationCrossAxisDirection;

	if self.orientationPrimaryAxisVertical then
		return crossAxisOffset, primaryAxisOffset;
	else
		return primaryAxisOffset, crossAxisOffset;
	end
end

function EncounterTimelineViewAnchoringMixin:GetTranslatedExtents(primaryAxisExtent, crossAxisExtent)
	if self.orientationPrimaryAxisVertical then
		return crossAxisExtent, primaryAxisExtent;
	else
		return primaryAxisExtent, crossAxisExtent;
	end
end

function EncounterTimelineViewAnchoringMixin:SetRegionPoint(region, point, relativeTo, relativePoint, primaryAxisOffset, crossAxisOffset)
	point = self:GetTranslatedAnchorPoint(point);
	relativePoint = self:GetTranslatedAnchorPoint(relativePoint or point);
	primaryAxisOffset, crossAxisOffset = self:GetTranslatedOffsets(primaryAxisOffset or 0, crossAxisOffset or 0);

	region:SetPoint(point, relativeTo, relativePoint, primaryAxisOffset, crossAxisOffset);
end

function EncounterTimelineViewAnchoringMixin:SetRegionPointsOffset(region, primaryAxisOffset, crossAxisOffset)
	region:SetPointsOffset(self:GetTranslatedOffsets(primaryAxisOffset, crossAxisOffset));
end

function EncounterTimelineViewAnchoringMixin:SetRegionSize(region, primaryAxisExtent, crossAxisExtent)
	region:SetSize(self:GetTranslatedExtents(primaryAxisExtent, crossAxisExtent));
end

function EncounterTimelineViewAnchoringMixin:SetRegionTextureRotation(region)
	if not region.originalCoords then
		region.originalCoords = { region:GetTexCoord() };
	end

	if not region.originalSize then
		region.originalSize = { region:GetSize() };
	end

	region:SetTexCoord(self.orientationTexCoordTranslator(unpack(region.originalCoords)));
	self:SetRegionSize(region, unpack(region.originalSize));
end

function EncounterTimelineViewAnchoringMixin:UpdateViewAnchoring(orientationInfo)
	self.orientationPointMappings = orientationInfo.pointMappings;
	self.orientationPrimaryAxisVertical = orientationInfo.primaryAxisVertical;
	self.orientationPrimaryAxisDirection = orientationInfo.primaryAxisDirection;
	self.orientationCrossAxisDirection = orientationInfo.crossAxisDirection;
	self.orientationTexCoordTranslator = orientationInfo.texCoordTranslator;
end

EncounterTimelineViewDynamicEventCallbacks = {
	ENCOUNTER_TIMELINE_EVENT_ADDED = "OnEncounterTimelineEventAdded",
	ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED = "OnEncounterTimelineEventStateChanged",
	ENCOUNTER_TIMELINE_EVENT_POSITION_CHANGED = "OnEncounterTimelineEventPositionChanged",
	ENCOUNTER_TIMELINE_EVENT_REMOVED = "OnEncounterTimelineEventRemoved",
	ENCOUNTER_TIMELINE_LAYOUT_UPDATED = "OnEncounterTimelineLayoutUpdated",
};

EncounterTimelineViewMixin = CreateFromMixins(EncounterTimelineViewSettingsAccessorMixin, EncounterTimelineViewSettingsMutatorMixin, EncounterTimelineViewAnchoringMixin, EncounterTimelineViewFrameManagerMixin, EncounterTimelineViewTrackContainerMixin);

function EncounterTimelineViewMixin:OnLoad()
	EncounterTimelineViewAnchoringMixin.OnLoad(self);
	EncounterTimelineViewFrameManagerMixin.OnLoad(self);
	EncounterTimelineViewTrackContainerMixin.OnLoad(self);

	local function ResetEventFrame(_pool, eventFrame)
		self:ResetEventFrame(eventFrame);
	end

	self.dirtyFlags = CreateFlags();

	self.eventFramePools = CreateFramePoolCollection();
	self.eventFramePools:CreatePool("Frame", self, "EncounterTimelineViewElementTemplate", ResetEventFrame);

	self.eventInstances = {};
	self.eventPositions = {};

	EncounterTimelineUtil.ApplyViewSettings(self, EncounterTimelineUtil.GetDefaultViewSettings());
end

function EncounterTimelineViewMixin:OnShow()
	FrameUtil.RegisterFrameForEventCallbackFields(self, EncounterTimelineViewDynamicEventCallbacks);
	self:UpdateLayout();

	for _, eventID in ipairs(C_EncounterTimeline.GetEventList()) do
		if not self:HasEvent(eventID) then
			local eventInfo = C_EncounterTimeline.GetEventInfo(eventID);

			if eventInfo then
				self:AddEvent(eventInfo);
			end
		end
	end
end

function EncounterTimelineViewMixin:OnHide()
	FrameUtil.RegisterFrameForEventCallbacks(self, EncounterTimelineViewDynamicEventCallbacks);
end

function EncounterTimelineViewMixin:OnUpdate(_elapsedTime)
	if self:IsDirty() then
		self:OnDirtyUpdate();
	end

	-- Each client tick we walk all active event frames and update their
	-- point offsets to shift them along the timeline.

	local currentTime = C_EncounterTimeline.GetCurrentTime();
	local crossAxisOffsetFixed = self:GetCrossAxisOffset();

	for eventFrame in self:EnumerateEventFrames() do
		if eventFrame:IsShown() then
			local eventID = eventFrame:GetID();
			local eventTimeRemaining = C_EncounterTimeline.GetEventTimeRemaining(eventID);
			local trackEnum = eventFrame:GetTrack();
			local track = self:GetTrack(trackEnum);

			eventFrame:UpdateAxisTranslations(currentTime, eventTimeRemaining or 0);

			local primaryAxisOffsetNormalized = eventFrame:CalculatePrimaryAxisOffset();
			local primaryAxisOffset = track:CalculatePrimaryAxisOffset(primaryAxisOffsetNormalized);

			self:SetRegionPointsOffset(eventFrame, primaryAxisOffset, crossAxisOffsetFixed);

			local crossAxisOffset = eventFrame:CalculateCrossAxisOffset();
			eventFrame:ApplyCrossAxisTranslation(self:GetTranslatedOffsets(0, crossAxisOffset));
		end
	end
end

function EncounterTimelineViewMixin:OnEncounterTimelineEventAdded(eventInfo, initialState)
	self:AddEvent(eventInfo, initialState);
end

function EncounterTimelineViewMixin:OnEncounterTimelineEventStateChanged(eventID, _newState)
	self:UpdateEventPosition(eventID);
end

function EncounterTimelineViewMixin:OnEncounterTimelineEventPositionChanged(eventID)
	self:UpdateEventPosition(eventID);
end

function EncounterTimelineViewMixin:OnEncounterTimelineEventRemoved(eventID)
	self:RemoveEvent(eventID);
end


function EncounterTimelineViewMixin:OnEncounterTimelineLayoutUpdated()
	self.dirtyFlags:Set(EncounterTimelineViewDirtyFlag.LayoutInvalidated);
end

function EncounterTimelineViewMixin:OnDirtyUpdate()
	if self.dirtyFlags:IsSet(EncounterTimelineViewDirtyFlag.LayoutInvalidated) then
		self:UpdateLayout();
	end
end

function EncounterTimelineViewMixin:OnViewSettingChanged(key, value)
	self.dirtyFlags:Set(EncounterTimelineViewDirtyFlag.LayoutInvalidated);
end

function EncounterTimelineViewMixin:GetViewSetting(key)
	return self:GetAttribute(key);
end

function EncounterTimelineViewMixin:SetViewSetting(key, value)
	local currentValue = self:GetAttribute(key);

	if value ~= currentValue then
		self:SetAttribute(key, value);
		self:OnViewSettingChanged(key, value);
	end
end

function EncounterTimelineViewMixin:IsDirty()
	return self.dirtyFlags:IsAnySet();
end

function EncounterTimelineViewMixin:AddEvent(eventInfo, _initialState)
	local eventID = eventInfo.id;

	if self:HasEvent(eventID) then
		return;
	end

	-- Newly added events don't immediately acquire frames. Instead, we wait
	-- for a position update to occur for this event (typically at the end
	-- of the current game tick) and then based upon its state and track
	-- information, will acquire frames as part of intro transitions when
	-- an event needs to be shown.
	--
	-- The rest of the assignments here are just for old/new state caching.

	self.eventInstances[eventID] = eventInfo;
	self.eventPositions[eventID] = nil;

	self:UpdateEventPosition(eventID);
end

function EncounterTimelineViewMixin:RemoveEvent(eventID)
	if not self:HasEvent(eventID) then
		return;
	end

	-- If this event has an associated frame then we assume that a transition
	-- has occurred to put it into the cancel/finished state and begin
	-- animating out the frame. This process orphans the frame.
	--
	-- If for some reason that hasn't happened then attempt recovery here by
	-- checking if the frame hasn't been orphaned and, if so, immediately
	-- releasing it back into the pool.

	local eventFrame = self:GetEventFrame(eventID);

	if eventFrame and not self:IsEventFrameOrphaned(eventFrame) then
		self:ReleaseEventFrame(eventFrame);
	end

	-- Clear up any remaining state.

	self.eventInstances[eventID] = nil;
	self.eventPositions[eventID] = nil;
end

function EncounterTimelineViewMixin:HasEvent(eventID)
	return self.eventInstances[eventID] ~= nil;
end

function EncounterTimelineViewMixin:GetEventFramePool(_eventID)
	-- For now, don't make this a configurable setting - we don't want to
	-- allow addons to change the template name in combat as we store settings
	-- in attributes, so it would potentially allow addons to create frames
	-- inheriting protected templates in combat by laundering through the
	-- timeline.

	local eventFrameTemplate = "EncounterTimelineViewElementTemplate";
	return self.eventFramePools:GetPool(eventFrameTemplate);
end

function EncounterTimelineViewMixin:CalculateEventFrameExtents()
	return self:GetIconSize() * (self:GetIconSizeMultiplier() / 100);
end

function EncounterTimelineViewMixin:InitializeEventFrame(eventFrame, eventID)
	local eventInfo = self.eventInstances[eventID];
	local eventFrameExtent = self:CalculateEventFrameExtents();

	self:SetRegionPoint(eventFrame, "CENTER", self, "START", 0, 0);
	eventFrame:SetSize(eventFrameExtent, eventFrameExtent);
	eventFrame:Init(self, eventInfo);
end

function EncounterTimelineViewMixin:ResetEventFrame(eventFrame)
	eventFrame:Reset();
	eventFrame:ClearCrossAxisTranslation();
	eventFrame:ClearPrimaryAxisTranslation();
	eventFrame:ClearAllPoints();
	eventFrame:SetScript("OnHide", nil);
	eventFrame:Hide();
end

function EncounterTimelineViewMixin:GetCachedEventPosition(eventID)
	return self.eventPositions[eventID];
end

function EncounterTimelineViewMixin:SetCachedEventPosition(eventID, eventPosition)
	self.eventPositions[eventID] = eventPosition;
end

function EncounterTimelineViewMixin:UpdateEventPosition(eventID)
	local oldEventPosition = self:GetCachedEventPosition(eventID);
	local newEventPosition = C_EncounterTimeline.GetEventPosition(eventID);

	-- Firstly, if we have no event position data returns from the API then
	-- this means the event is in an indeterminate location. There's two
	-- scenarios where this can happen.
	--
	-- The first is newly added events if UpdateEventPosition is called for
	-- the event before the end of the same game tick in which it was added;
	-- this is expected to be a temporary state that'll usually correct itself
	-- later in the same game tick.
	--
	-- The second are cases where an event no longer meets the requirements of
	-- its desired track to remain visible. This will happen if we've
	-- previously added an event the Long track with a large duration, and
	-- then multiple events with shorter durations in the same track were
	-- added - effectively pushing the event out of the Long track.

	if oldEventPosition ~= nil and newEventPosition == nil then
		self:ApplyDistantTrackTransition(eventID);
		self:SetCachedEventPosition(eventID, nil);
		return;
	elseif newEventPosition == nil then
		return;
	end

	-- The rest of this is an extremely ugly transition table. Ideally, we'd
	-- probably derive the timeline track mixins on a per-track basis rather
	-- than per-type and then have them communicate back to us a description
	-- of the translation that should occur - but for now, it's simpler to
	-- keep all this in here while things are in flux at least.

	local hasChangedState = (oldEventPosition == nil or oldEventPosition.state ~= newEventPosition.state);
	local hasChangedTrack = (oldEventPosition == nil or oldEventPosition.track ~= newEventPosition.track);
	local hasChangedOrder = (oldEventPosition == nil or oldEventPosition.order ~= newEventPosition.order);
	local hasChangedSection = (oldEventPosition == nil or oldEventPosition.section ~= newEventPosition.section);

	if hasChangedState then
		if newEventPosition.state == Enum.EncounterTimelineEventState.Active then
			if newEventPosition.track == Enum.EncounterTimelineTrack.Short then
				self:ApplyShortTrackIntroTransition(eventID, newEventPosition);
			elseif newEventPosition.track == Enum.EncounterTimelineTrack.Medium then
				self:ApplyMediumTrackIntroTransition(eventID, newEventPosition);
			elseif newEventPosition.track == Enum.EncounterTimelineTrack.Long then
				self:ApplyLongTrackOrderTransition(eventID, newEventPosition, newEventPosition);
			end
		elseif newEventPosition.state == Enum.EncounterTimelineEventState.Finished then
			-- No transition; we handle this on entry into the Finishing track.
		elseif newEventPosition.state == Enum.EncounterTimelineEventState.Canceled then
			self:ApplyCancelTransition(eventID);
		elseif newEventPosition.state == Enum.EncounterTimelineEventState.Paused then
			self:ApplyPauseTransition(eventID);
		end
	elseif hasChangedTrack then
		-- Track transitions are only applied if a state change didn't occur,
		-- since these want to apply entry translations which would conflict
		-- with whatever translations an intro/outro sets up.

		if newEventPosition.track == Enum.EncounterTimelineTrack.Short then
			self:ApplyShortTrackEntryTransition(eventID, newEventPosition);
		elseif newEventPosition.track == Enum.EncounterTimelineTrack.Medium then
			self:ApplyMediumTrackEntryTransition(eventID, newEventPosition);
		elseif newEventPosition.track == Enum.EncounterTimelineTrack.Long then
			self:ApplyLongTrackOrderTransition(eventID, newEventPosition, oldEventPosition);
		end
	elseif hasChangedOrder then
		-- In-track order transitions must only occur in the absence of a state
		-- or track change.

		if newEventPosition.track == Enum.EncounterTimelineTrack.Long then
			self:ApplyLongTrackOrderTransition(eventID, newEventPosition, oldEventPosition);
		end
	end

	-- In-track section transitions can be applied independently of state/track
	-- transitions.

	if hasChangedSection then
		if newEventPosition.section == Enum.EncounterTimelineSection.Imminent then
			self:ApplyImminentSectionTransition(eventID, newEventPosition);
		elseif newEventPosition.section == Enum.EncounterTimelineSection.Finishing then
			self:ApplyFinishingSectionTransition(eventID, newEventPosition);
		end
	end

	self:SetCachedEventPosition(eventID, newEventPosition);
end

function EncounterTimelineViewMixin:ApplyCancelTransition(eventID, _eventPosition)
	local eventFrame = self:GetEventFrame(eventID);

	if not eventFrame then
		return;
	end

	-- Canceled timeline events will report as having a zero duration,
	-- so this transition on the cross axis needs to use absolute time.

	local crossAxisOffsetFrom = self:GetCrossAxisOffset();
	local crossAxisOffsetTo = self:GetEventOutroOffsetEnd();
	local crossAxisOffsetPercentage = 0;
	local crossAxisDuration = self:GetEventOutroDuration();
	local crossAxisElapsedTime = crossAxisDuration * crossAxisOffsetPercentage;
	local crossAxisStartTime = C_EncounterTimeline.GetCurrentTime() - crossAxisElapsedTime;
	local crossAxisEndTime = crossAxisStartTime + crossAxisDuration;
	local crossAxisUseAbsoluteTime = true;

	eventFrame:StartCrossAxisTranslation(crossAxisOffsetFrom, crossAxisOffsetTo, crossAxisStartTime, crossAxisEndTime, crossAxisUseAbsoluteTime);

	-- The primary axis translation should just hold itself in a fixed place.

	local primaryAxisOffset = eventFrame:CalculatePrimaryAxisOffset();
	eventFrame:ClearPrimaryAxisTranslation(primaryAxisOffset);

	-- Canceling is a final state, so there's no chance we never need to
	-- revert this animation - therefore, fully disassociate it from the
	-- event with a Detach rather than Orphan call.

	eventFrame:PlayCancelAnimation();

	self:DetachEventFrame(eventFrame);
	self:StartOutroTransition(eventFrame);
end

function EncounterTimelineViewMixin:ApplyPauseTransition(eventID, _eventPosition)
	-- At present, pausing an event is visually the same as canceling it.
	-- This will probably change soon. Note that this transition can only
	-- occur for paused events on a linear track - paused events in a sorted
	-- track invalidate their track state entirely and forcefully hide.

	if not self:GetViewSetting("keepPausedEvents") then
		self:ApplyCancelTransition(eventID);
	end
end

function EncounterTimelineViewMixin:ApplyDistantTrackTransition(eventID)
	-- Transitioning an event to the distant track is the same transition as
	-- cancelation; this should only occur in scenarios where events have
	-- either traveled back through time substantially or for long events
	-- that have shifted their order such that they should be hidden.

	self:ApplyCancelTransition(eventID);
end

function EncounterTimelineViewMixin:ApplyLinearTrackIntroTransition(eventID, eventPosition)
	-- Introducing an event onto the timeline straight into a short track is
	-- similar to a regular entry animation, except we also need to apply a
	-- cross-axis translation to slide it down onto the timeline bar first.
	--
	-- This has implications for the primary axis translation - we don't
	-- want both translations running at the same time and moving the frame
	-- diagonally.

	local eventFrame = self:GetOrAcquireEventFrame(eventID);
	local track = self:GetTrack(eventPosition.track);
	local _normalizedOffsetStart, normalizedOffsetEnd = track:GetNormalizedOffsets();

	local crossAxisOffsetFrom = self:GetEventIntroOffsetStart();
	local crossAxisOffsetTo = self:GetCrossAxisOffset();
	local crossAxisOffsetPercentage = 0;
	local crossAxisDuration = self:GetEventIntroDuration();
	local crossAxisElapsedTime = crossAxisDuration * crossAxisOffsetPercentage;
	local crossAxisStartTime = eventPosition.timeRemaining - crossAxisElapsedTime;
	local crossAxisEndTime = crossAxisStartTime - crossAxisDuration;
	local crossAxisUseAbsoluteTime = false;

	eventFrame:StartCrossAxisTranslation(crossAxisOffsetFrom, crossAxisOffsetTo, crossAxisStartTime, crossAxisEndTime, crossAxisUseAbsoluteTime);

	local primaryAxisStartTime = eventPosition.timeRemaining - crossAxisDuration;
	local primaryAxisEndTime = track:GetMinimumEventDuration();
	local primaryAxisOffsetFrom = track:CalculateNormalizedOffsetForDuration(primaryAxisStartTime);
	local primaryAxisOffsetTo = normalizedOffsetEnd;
	local primaryAxisUseAbsoluteTime = false;

	eventFrame:StartPrimaryAxisTranslation(primaryAxisOffsetFrom, primaryAxisOffsetTo, primaryAxisStartTime, primaryAxisEndTime, primaryAxisUseAbsoluteTime);
	eventFrame:SetTrack(track:GetTrackEnum());
	eventFrame:PlayIntroAnimation();

	self:StartIntroTransition(eventFrame);
end

function EncounterTimelineViewMixin:ApplyLinearTrackEntryTransition(eventID, eventPosition)
	-- Entering any linear track snaps the event to a fixed range of normalized
	-- offsets based off the relative remaining duration of the event.

	local eventFrame = self:GetOrAcquireEventFrame(eventID);
	local track = self:GetTrack(eventPosition.track);
	local normalizedOffsetStart, normalizedOffsetEnd = track:GetNormalizedOffsets();

	local primaryAxisStartTime = track:GetMaximumEventDuration();
	local primaryAxisEndTime = track:GetMinimumEventDuration();
	local primaryAxisOffsetFrom = normalizedOffsetStart;
	local primaryAxisOffsetTo = normalizedOffsetEnd
	local primaryAxisUseAbsoluteTime = false;

	eventFrame:StartPrimaryAxisTranslation(primaryAxisOffsetFrom, primaryAxisOffsetTo, primaryAxisStartTime, primaryAxisEndTime, primaryAxisUseAbsoluteTime);
	eventFrame:SetTrack(track:GetTrackEnum());
end

function EncounterTimelineViewMixin:ApplyShortTrackIntroTransition(eventID, eventPosition)
	self:ApplyLinearTrackIntroTransition(eventID, eventPosition);
end

function EncounterTimelineViewMixin:ApplyShortTrackEntryTransition(eventID, eventPosition)
	self:ApplyLinearTrackEntryTransition(eventID, eventPosition);
end

function EncounterTimelineViewMixin:ApplyMediumTrackIntroTransition(eventID, eventPosition)
	self:ApplyLinearTrackIntroTransition(eventID, eventPosition);
end

function EncounterTimelineViewMixin:ApplyMediumTrackEntryTransition(eventID, eventPosition)
	self:ApplyLinearTrackEntryTransition(eventID, eventPosition);
end

function EncounterTimelineViewMixin:ApplyLongTrackOrderTransition(eventID, eventPosition, oldEventPosition)
	local track = self:GetTrack(eventPosition.track);

	-- If we don't have existing position data, then pretend that this event
	-- is coming from one place to the side of its new spot in the track.
	--
	-- This is expected to be the case for newly added events. We also
	-- want to run this logic if there's no current frame for the event,
	-- which will be the case where this event was added to the long track
	-- in the timeline but wasn't given a frame because of our above logic
	-- for clamping the event count.

	local isIntroTransition = not self:HasEventFrame(eventID);
	local isEntryTransition = not oldEventPosition;

	if isIntroTransition or isEntryTransition then
		oldEventPosition = CreateFromMixins(eventPosition);
		oldEventPosition.order = eventPosition.order + 1;
	end

	-- The translation itself is always just a primary axis one - we don't do
	-- anything on the cross axis. A couple of issues to consider here;
	--
	-- Firstly, this is a sorted track - and the one right after is a linear
	-- one. The linear track must accurately track event time, so when an
	-- event moves there it'll snap the start offset of the primary axis to
	-- that of the event duration. This means we need to clamp the end time
	-- of our own translations to ensure that they don't exceed the minimum
	-- duration of our own track to avoid the event jumping if, for some
	-- horrible reason, it would take longer to slide in than it'd take to
	-- get to the adjacent linear track.
	--
	-- Secondly, it's possible for an event to move multiple places while
	-- still translating between two slots. As such, if this isn't an entry
	-- or intro translation we'll use the existing offset to maintain some
	-- level of continuity. We don't adjust the duration, since we hope this
	-- will be an edge case.

	local eventFrame = self:GetOrAcquireEventFrame(eventID);

	local primaryAxisDuration = self:GetLongTrackOrderDuration();
	local primaryAxisStartTime = eventPosition.timeRemaining;
	local primaryAxisEndTime = math.max(primaryAxisStartTime - primaryAxisDuration, track:GetMinimumEventDuration());
	local primaryAxisOffsetFrom;
	local primaryAxisOffsetTo = track:CalculateNormalizedOffsetForEvent(eventPosition);
	local primaryAxisUseAbsoluteTime = false;

	if isIntroTransition or isEntryTransition then
		primaryAxisOffsetFrom = track:CalculateNormalizedOffsetForEvent(oldEventPosition);
	else
		primaryAxisOffsetFrom = eventFrame:CalculatePrimaryAxisOffset();
	end

	eventFrame:ClearCrossAxisTranslation(self:GetCrossAxisOffset());
	eventFrame:StartPrimaryAxisTranslation(primaryAxisOffsetFrom, primaryAxisOffsetTo, primaryAxisStartTime, primaryAxisEndTime, primaryAxisUseAbsoluteTime);
	eventFrame:SetTrack(track:GetTrackEnum());

	if isIntroTransition or isEntryTransition then
		eventFrame:PlayIntroAnimation();
		self:StartIntroTransition(eventFrame);
	end
end

function EncounterTimelineViewMixin:ApplyFinishingSectionTransition(eventID, _eventPosition)
	local eventFrame = self:GetEventFrame(eventID);

	if not eventFrame then
		return;
	end

	-- Transitioning into the finishing track starts the final animation
	-- for this event. This is separate from the Finished state in case
	-- design wants animations to play a bit earlier than the event actually
	-- reaching the end of the timeline.
	--
	-- Note that we don't touch the translations here - the translation from
	-- the parent track should still be applied while animating out.

	eventFrame:PlayFinishAnimation();

	self:DetachEventFrame(eventFrame);
	self:StartOutroTransition(eventFrame);
end

function EncounterTimelineViewMixin:ApplyImminentSectionTransition(eventID, _eventPosition)
	local eventFrame = self:GetEventFrame(eventID);

	if not eventFrame then
		return;
	end

	-- Transitioning into the finishing track starts the highlight animation
	-- on the event frame.

	eventFrame:PlayHighlightAnimation();
end

function EncounterTimelineViewMixin:StartOutroTransition(eventFrame)
	-- Starting an outro transition should be accompanied by the caller
	-- putting the frame into either an orphaned or disowned state. When
	-- the outro completes, we assume the frame will transition to a hidden
	-- state - at which point, we'll double check that it's orphaned and if
	-- so, release it back into the frame pool.
	--
	-- If the frame is already hidden then someone's been a bit naughty;
	-- we'll always defer releasing the event frame just so as to make it
	-- reasonable that callers can expect the event frame handle won't be
	-- invalidated immediately after calling this function if needed.

	local function OnEventFrameHidden()
		if self:IsEventFrameOrphaned(eventFrame) then
			self:ReleaseEventFrame(eventFrame);
		end
	end

	if eventFrame:IsShown() then
		eventFrame:SetScript("OnHide", function() self:ReleaseEventFrame(eventFrame); end);
	else
		RunNextFrame(OnEventFrameHidden);
	end
end

function EncounterTimelineViewMixin:StartIntroTransition(eventFrame)
	-- Starting an intro transition should cancel the effects of any prior
	-- StartOutroTransition call. We assume that the caller supplied us an
	-- event frame as obtained through GetOrAcquireEventFrame, which will
	-- have already un-orphaned the event frame, but we do still need to
	-- clean up the OnHide script handler ideally.

	eventFrame:SetScript("OnHide", nil);
	eventFrame:Show();
end

function EncounterTimelineViewMixin:UpdateLayout()
	-- Layout information is dependent upon us having locally cached full
	-- information on track layout.

	self:UpdateViewAnchoring(EncounterTimelineUtil.GetViewOrientationSetup(self:GetViewOrientation(), self:GetIconDirection()));
	self:UpdateTracks();

	local maxLongTrackEventCount = self:GetLongTrackEventLimit();

	-- The next work we need to do in a layout update is calculate the full
	-- primary axis extent of the timeline, and within that the points at
	-- which tracks of the timeline are situated.
	--
	-- The following makes assumptions on track orders; if adding new
	-- track sections you'll need to adjust this logic and add settings
	-- to configure extents/padding/etc.

	local offset = CreateAccumulator();

	offset:Add(self:GetPrimaryAxisStartPadding());
	offset:Add(self:GetLongTrackStartPadding());

	-- The Distant starts a bit outside the range of the view as-if there
	-- was one extra long event in the view.

	local distantTrackOffset = offset:Count();
	distantTrackOffset = distantTrackOffset - self:GetLongTrackEventExtent();
	distantTrackOffset = distantTrackOffset - (maxLongTrackEventCount >= 1 and self:GetLongTrackEventSpacing() or 0);

	local longTrackEndOffset = offset:Count();

	offset:Add(self:GetLongTrackEventExtent() * maxLongTrackEventCount);
	offset:Add(self:GetLongTrackEventSpacing() * (maxLongTrackEventCount - 1));

	local longTrackStartOffset = offset:Count();
	local mediumTrackStartOffset = offset:Count();

	offset:Add(self:GetMediumTrackExtent());

	local mediumTrackEndOffset = offset:Count();
	local shortTrackStartOffset = offset:Count();

	offset:Add(self:GetShortTrackExtent());

	local shortTrackEndOffset = offset:Count();

	offset:Add(self:GetShortTrackEndPadding());
	offset:Add(self:GetPrimaryAxisEndPadding());

	local primaryAxisExtent = offset:Count();

	-- With the full extents and all offsets calculated, go back and update
	-- our track mapping with both normalized and absolute offset ranges.
	--
	-- The reasoning for the normalized offsets is to make layout updates for
	-- the timeline easier to implement - we define interpolations in terms
	-- of normalized offsets, and then map them to physical point offsets
	-- at the point of updating timeline frame positions.

	self:SetTrackNormalizedOffsets(Enum.EncounterTimelineTrack.Indeterminate, EncounterTimelineViewNormalizedOffsets.PrimaryAxisStart, EncounterTimelineViewNormalizedOffsets.PrimaryAxisStart);
	self:SetTrackNormalizedOffsets(Enum.EncounterTimelineTrack.Long, EncounterTimelineViewNormalizedOffsets.PrimaryAxisStartMedium, EncounterTimelineViewNormalizedOffsets.PrimaryAxisStartMedium - maxLongTrackEventCount);
	self:SetTrackNormalizedOffsets(Enum.EncounterTimelineTrack.Medium, EncounterTimelineViewNormalizedOffsets.PrimaryAxisStartMedium, EncounterTimelineViewNormalizedOffsets.PrimaryAxisStartShort);
	self:SetTrackNormalizedOffsets(Enum.EncounterTimelineTrack.Short, EncounterTimelineViewNormalizedOffsets.PrimaryAxisStartShort, EncounterTimelineViewNormalizedOffsets.PrimaryAxisEnd);

	self:SetTrackPrimaryAxisOffsets(Enum.EncounterTimelineTrack.Indeterminate, distantTrackOffset, distantTrackOffset);
	self:SetTrackPrimaryAxisOffsets(Enum.EncounterTimelineTrack.Long, longTrackStartOffset, longTrackEndOffset);
	self:SetTrackPrimaryAxisOffsets(Enum.EncounterTimelineTrack.Medium, mediumTrackStartOffset, mediumTrackEndOffset);
	self:SetTrackPrimaryAxisOffsets(Enum.EncounterTimelineTrack.Short, shortTrackStartOffset, shortTrackEndOffset);

	self:GetTrack(Enum.EncounterTimelineTrack.Long):SetMaximumEventCount(maxLongTrackEventCount + 1);

	-- Once track sections are calculated fix up our art...

	self:SetAlpha(self:GetViewTransparency() / 100);
	self.Background:SetAlpha(self:GetBackgroundTransparency() / 100);

	local crossAxisOffset = self:GetCrossAxisOffset();

	self.Divider:ClearAllPoints();
	self:SetRegionPoint(self.Divider, "END", self, "START", self:GetDividerOffset(), crossAxisOffset);

	self.LineEnd:ClearAllPoints();
	self:SetRegionPoint(self.LineEnd, "END", self, "START", shortTrackEndOffset, crossAxisOffset);

	self.LineStart:ClearAllPoints();
	self:SetRegionPoint(self.LineStart, "END", self.LineEnd, "START", 0, 0);

	if self:GetPipShown() then
		self.Pip:ClearAllPoints();
		self:SetRegionPoint(self.Pip, "CENTER", self, "START", self:CalculatePrimaryAxisOffsetForDuration(self:GetPipDuration()), crossAxisOffset);
		self.Pip:Show();
	else
		self.Pip:Hide();
	end

	-- The pip text requires some manual work since the default duration
	-- number is thinner than it is tall, which makes the offsets a bit
	-- hard to apply from a single number.
	--
	-- We allow customizing the anchor point too, so an addon can swap it
	-- to the other side if they so want.

	if self:GetPipTextShown() then
		self.PipText:ClearAllPoints();
		self.PipText:SetFormattedText("%d", self:GetPipDuration());

		if self:IsVertical() then
			local point = self:GetPipTextVerticalAnchorPoint();
			local relativePoint = self:GetPipTextVerticalRelativePoint();
			local offsetX = self:GetPipTextVerticalOffsetX();
			local offsetY = self:GetPipTextVerticalOffsetY();

			self.PipText:SetPoint(point, self.Pip, relativePoint, offsetX, offsetY);
		else
			local point = self:GetPipTextHorizontalAnchorPoint();
			local relativePoint = self:GetPipTextHorizontalRelativePoint();
			local offsetX = self:GetPipTextHorizontalOffsetX();
			local offsetY = self:GetPipTextHorizontalOffsetY();

			self.PipText:SetPoint(point, self.Pip, relativePoint, offsetX, offsetY);
		end

		self.PipText:Show();
	else
		self.PipText:Hide();
	end

	-- The timeline line is broken up by small masks at specific durations.

	local shortTrackDuration = self:GetTrack(Enum.EncounterTimelineTrack.Short):GetTrackDuration();

	for _index, maskTexture in ipairs(self.lineBreakMasks) do
		local seconds = maskTexture.seconds;

		self.LineStart:RemoveMaskTexture(maskTexture);
		self.LineEnd:RemoveMaskTexture(maskTexture);

		if seconds <= (shortTrackDuration / 2) then
			self.LineEnd:AddMaskTexture(maskTexture);
		else
			self.LineStart:AddMaskTexture(maskTexture);
		end

		maskTexture:ClearAllPoints();
		self:SetRegionPoint(maskTexture, "CENTER", self, "START", self:CalculatePrimaryAxisOffsetForDuration(seconds), crossAxisOffset);

		-- We can't use SetRegionTextureRotation here because changing texcoords
		-- of a texture used as a mask isn't supported. Thankfully, this asset
		-- is a regular square with just a small cutout - so we can use normal
		-- rotation APIs instead.

		if self:IsVertical() then
			maskTexture:SetRotation(90);
		else
			maskTexture:SetRotation(0);
		end
	end

	-- It's intentional that we don't apply rotation to the pip texture;
	-- art wants the shiny bit at the top.

	self:SetRegionTextureRotation(self.Divider);
	self:SetRegionTextureRotation(self.LineStart);
	self:SetRegionTextureRotation(self.LineEnd);

	-- We also need to walk all event frames and fix up their anchor points.
	-- It's assumed we can clear the offsets here; these will be updated in
	-- the OnUpdate loop anyway.
	--
	-- We also use this as an opportunity to tell the frames that the settings
	-- have changed, though really this should be a CBR event...

	local eventFrameExtent = self:CalculateEventFrameExtents();

	for eventFrame in self:EnumerateEventFrames() do
		self:SetRegionPoint(eventFrame, "CENTER", self, "START", 0, 0);
		eventFrame:SetSize(eventFrameExtent, eventFrameExtent);
		eventFrame:OnViewSettingsUpdated();
	end

	self:SetRegionSize(self, primaryAxisExtent, self:GetCrossAxisExtent());
	self.dirtyFlags:Clear(EncounterTimelineViewDirtyFlag.LayoutInvalidated);
end

-- We promote the OnViewSettingChanged method to a secure mixin so as to
-- allow SetViewSetting to be called by tainted code without tainting the
-- whole timeline. This is reasonably important, since we don't want small
-- visual tweaks like padding or offset changes to explode the timeline when
-- it touches any secret values.

EncounterTimelineViewSecureMixin = {};

function EncounterTimelineViewSecureMixin:OnViewSettingChanged(key, value)
	EncounterTimelineViewMixin.OnViewSettingChanged(self, key, value);
end
